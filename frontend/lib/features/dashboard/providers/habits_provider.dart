import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/storage/local_storage.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import 'theme_provider.dart';

// --- Selected Date in Today Dashboard ---
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// --- Selected Category Filter ---
final selectedCategoryFilterProvider = StateProvider<String>((ref) => 'All');

// --- Habits State Notifier ---
final habitsProvider = StateNotifierProvider<HabitsNotifier, List<Habit>>((ref) {
  final storage = ref.watch(localStorageProvider);
  return HabitsNotifier(storage);
});

class HabitsNotifier extends StateNotifier<List<Habit>> {
  final LocalStorage _storage;

  HabitsNotifier(this._storage) : super([]) {
    _loadHabits();
  }

  void _loadHabits() {
    state = _storage.getHabits();
  }

  Future<void> addHabit(Habit habit) async {
    final updated = [...state, habit];
    state = updated;
    await _storage.saveHabits(updated);
  }

  Future<void> updateHabit(Habit updatedHabit) async {
    final updated = state.map((h) => h.id == updatedHabit.id ? updatedHabit : h).toList();
    state = updated;
    await _storage.saveHabits(updated);
  }

  Future<void> deleteHabit(String id) async {
    final updated = state.where((h) => h.id != id).toList();
    state = updated;
    await _storage.saveHabits(updated);
  }
}

// --- Habit Logs State Notifier ---
final habitLogsProvider = StateNotifierProvider<HabitLogsNotifier, List<HabitLog>>((ref) {
  final storage = ref.watch(localStorageProvider);
  return HabitLogsNotifier(storage, ref);
});

class HabitLogsNotifier extends StateNotifier<List<HabitLog>> {
  final LocalStorage _storage;
  final Ref _ref;

  HabitLogsNotifier(this._storage, this._ref) : super([]) {
    _loadLogs();
  }

  void _loadLogs() {
    state = _storage.getLogs();
  }

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  bool isCompleted(String habitId, DateTime date) {
    final dateStr = _formatDate(date);
    return state.any((log) =>
        log.habitId == habitId && log.date == dateStr && log.completed);
  }

  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    final dateStr = _formatDate(date);
    final existingIndex = state.indexWhere(
      (log) => log.habitId == habitId && log.date == dateStr,
    );

    List<HabitLog> updatedLogs = List.from(state);
    bool willBeCompleted = true;

    if (existingIndex >= 0) {
      final existing = state[existingIndex];
      willBeCompleted = !existing.completed;
      updatedLogs[existingIndex] = existing.copyWith(
        completed: willBeCompleted,
        updatedAt: DateTime.now(),
      );
    } else {
      updatedLogs.add(
        HabitLog(
          id: const Uuid().v4(),
          habitId: habitId,
          date: dateStr,
          completed: true,
          updatedAt: DateTime.now(),
        ),
      );
    }

    state = updatedLogs;
    await _storage.saveLogs(updatedLogs);

    // Update streak on the habit
    final habits = _ref.read(habitsProvider);
    final habitIndex = habits.indexWhere((h) => h.id == habitId);
    if (habitIndex >= 0) {
      final habit = habits[habitIndex];
      final newStreak = willBeCompleted
          ? habit.streak + 1
          : (habit.streak > 0 ? habit.streak - 1 : 0);
      await _ref.read(habitsProvider.notifier).updateHabit(
            habit.copyWith(streak: newStreak),
          );
    }
  }
}

// --- Dashboard Daily Progress Provider ---
final dailyProgressProvider = Provider<({double progress, int completed, int total})>((ref) {
  final habits = ref.watch(habitsProvider);
  final logsNotifier = ref.watch(habitLogsProvider.notifier);
  final selectedDate = ref.watch(selectedDateProvider);

  final activeHabits = habits.where((h) => !h.isArchived).toList();
  if (activeHabits.isEmpty) {
    return (progress: 0.0, completed: 0, total: 0);
  }

  int completed = 0;
  for (final habit in activeHabits) {
    if (logsNotifier.isCompleted(habit.id, selectedDate)) {
      completed++;
    }
  }

  final double progress = completed / activeHabits.length;
  return (progress: progress, completed: completed, total: activeHabits.length);
});
