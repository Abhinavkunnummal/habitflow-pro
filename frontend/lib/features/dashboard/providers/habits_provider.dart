import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/api/api_providers.dart';
import '../../../core/storage/local_storage.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/dashboard_summary_model.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../repositories/habit_repository.dart';
import 'theme_provider.dart';

// --- Selected Date in Today Dashboard ---
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// --- Selected Category Filter ---
final selectedCategoryFilterProvider = StateProvider<String>((ref) => 'All');

// --- Habit Repository Provider ---
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HabitRepository(apiClient);
});

// --- Habits State Notifier ---
final habitsProvider = StateNotifierProvider<HabitsNotifier, List<Habit>>((ref) {
  final storage = ref.watch(localStorageProvider);
  final repository = ref.watch(habitRepositoryProvider);
  return HabitsNotifier(storage, repository, ref);
});

/// Pure algorithm to compute consecutive calendar day streak from completion logs
int calculateStreakFromLogs(String habitId, List<HabitLog> logs, DateTime referenceDate) {
  final completedDates = logs
      .where((l) => l.habitId == habitId && l.completed)
      .map((l) => l.date)
      .toSet();

  if (completedDates.isEmpty) return 0;

  final refDateStr = DateFormat('yyyy-MM-dd').format(referenceDate);
  final yesterdayStr = DateFormat('yyyy-MM-dd').format(
    referenceDate.subtract(const Duration(days: 1)),
  );

  int streak = 0;
  DateTime checkDate;

  if (completedDates.contains(refDateStr)) {
    streak = 1;
    checkDate = referenceDate.subtract(const Duration(days: 1));
  } else if (completedDates.contains(yesterdayStr)) {
    streak = 1;
    checkDate = referenceDate.subtract(const Duration(days: 2));
  } else {
    return 0;
  }

  while (true) {
    final checkDateStr = DateFormat('yyyy-MM-dd').format(checkDate);
    if (completedDates.contains(checkDateStr)) {
      streak += 1;
      checkDate = checkDate.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }

  return streak;
}

class HabitsNotifier extends StateNotifier<List<Habit>> {
  final LocalStorage _storage;
  final HabitRepository _repository;
  final Ref _ref;

  HabitsNotifier(this._storage, this._repository, this._ref) : super([]) {
    _loadLocalHabits();
    _listenAuth();
  }

  void _loadLocalHabits() {
    final habits = _storage.getHabits();
    final logs = _storage.getLogs();
    final syncedHabits = habits.map((h) {
      final actualStreak = calculateStreakFromLogs(h.id, logs, DateTime.now());
      return h.copyWith(streak: actualStreak);
    }).toList();
    state = syncedHabits;
  }

  void _listenAuth() {
    _ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        fetchHabitsFromBackend();
      } else if (previous?.isAuthenticated == true && !next.isAuthenticated) {
        clearUserData();
      }
    });
  }

  Future<void> fetchHabitsFromBackend() async {
    try {
      final habits = await _repository.listHabits(isArchived: false);
      if (habits.isNotEmpty) {
        state = habits;
        await _storage.saveHabits(habits);
      }
    } catch (_) {
      // Retain locally stored habits on network error
    }
  }

  Future<void> addHabit(Habit habit) async {
    final authState = _ref.read(authProvider);

    if (authState.isAuthenticated) {
      try {
        final serverHabit = await _repository.createHabit(habit);
        final updated = [...state, serverHabit];
        state = updated;
        await _storage.saveHabits(updated);
        return;
      } catch (_) {
        // Fallback to local save if network fails
      }
    }

    final updated = [...state, habit];
    state = updated;
    await _storage.saveHabits(updated);
  }

  Future<void> updateHabit(Habit updatedHabit) async {
    final updated = state.map((h) => h.id == updatedHabit.id ? updatedHabit : h).toList();
    state = updated;
    await _storage.saveHabits(updated);

    final authState = _ref.read(authProvider);
    if (authState.isAuthenticated) {
      try {
        await _repository.updateHabit(updatedHabit.id, {
          'title': updatedHabit.title,
          if (updatedHabit.description != null) 'description': updatedHabit.description,
          'category': updatedHabit.category,
          'type': updatedHabit.type,
          'icon': updatedHabit.icon,
          'colorHex': updatedHabit.colorHex,
          'targetValue': updatedHabit.targetValue,
          'targetUnit': updatedHabit.targetUnit,
          if (updatedHabit.reminderTime != null) 'reminderTime': updatedHabit.reminderTime,
          'streakShieldEnabled': updatedHabit.streakShieldEnabled,
        });
      } catch (_) {}
    }
  }

  Future<void> deleteHabit(String id) async {
    final updated = state.where((h) => h.id != id).toList();
    state = updated;
    await _storage.saveHabits(updated);

    final authState = _ref.read(authProvider);
    if (authState.isAuthenticated) {
      try {
        await _repository.deleteHabit(id);
      } catch (_) {}
    }
  }

  Future<void> clearUserData() async {
    state = [];
    await _storage.saveHabits([]);
  }
}

// --- Habit Logs State Notifier ---
final habitLogsProvider = StateNotifierProvider<HabitLogsNotifier, List<HabitLog>>((ref) {
  final storage = ref.watch(localStorageProvider);
  final repository = ref.watch(habitRepositoryProvider);
  return HabitLogsNotifier(storage, repository, ref);
});

class HabitLogsNotifier extends StateNotifier<List<HabitLog>> {
  final LocalStorage _storage;
  final HabitRepository _repository;
  final Ref _ref;

  HabitLogsNotifier(this._storage, this._repository, this._ref) : super([]) {
    _loadLogs();
    _listenAuth();
  }

  void _loadLogs() {
    state = _storage.getLogs();
  }

  void _listenAuth() {
    _ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        syncTodayCompletions(DateTime.now());
      } else if (previous?.isAuthenticated == true && !next.isAuthenticated) {
        clearUserData();
      }
    });
  }

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  bool isCompleted(String habitId, DateTime date) {
    final dateStr = _formatDate(date);
    return state.any((log) =>
        log.habitId == habitId && log.date == dateStr && log.completed);
  }

  Future<void> syncTodayCompletions(DateTime date) async {
    final dateStr = _formatDate(date);
    try {
      final remoteLogs = await _repository.getTodayCompletions(date: dateStr);
      if (remoteLogs.isNotEmpty) {
        // Merge remote logs with existing local state
        final existingWithoutTargetDate = state.where((l) => l.date != dateStr).toList();
        final merged = [...existingWithoutTargetDate, ...remoteLogs];
        state = merged;
        await _storage.saveLogs(merged);
      }
    } catch (_) {}
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

    // Optimistically update habit streak locally based on consecutive days
    final habits = _ref.read(habitsProvider);
    final habitIndex = habits.indexWhere((h) => h.id == habitId);
    if (habitIndex >= 0) {
      final habit = habits[habitIndex];
      final newStreak = calculateStreakFromLogs(habitId, updatedLogs, DateTime.now());
      await _ref.read(habitsProvider.notifier).updateHabit(
            habit.copyWith(streak: newStreak),
          );
    }

    // Synchronize idempotently with backend if authenticated
    final authState = _ref.read(authProvider);
    if (authState.isAuthenticated) {
      try {
        final result = await _repository.recordCompletion(
          habitId: habitId,
          date: dateStr,
          completed: willBeCompleted,
        );

        // Update habit with authoritative backend streak
        if (habitIndex >= 0) {
          final habit = _ref.read(habitsProvider)[habitIndex];
          await _ref.read(habitsProvider.notifier).updateHabit(
                habit.copyWith(streak: result.currentStreak),
              );
        }
      } catch (_) {
        // Offline / network failure: local optimistic update is preserved
      }
    }
  }

  Future<void> clearUserData() async {
    state = [];
    await _storage.saveLogs([]);
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

// --- Dashboard Backend Summary Provider ---
final dashboardSummaryProvider = FutureProvider<DashboardSummaryModel?>((ref) async {
  final authState = ref.watch(authProvider);
  if (!authState.isAuthenticated) return null;

  try {
    final apiClient = ref.watch(apiClientProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

    final response = await apiClient.get(
      '/dashboard/summary',
      queryParameters: {'date': dateStr},
    );

    final data = response as Map<String, dynamic>;
    return DashboardSummaryModel.fromMap(data);
  } catch (_) {
    return null;
  }
});
