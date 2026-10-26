import 'package:shared_preferences/shared_preferences.dart';
import '../../features/dashboard/models/habit.dart';
import '../../features/dashboard/models/habit_log.dart';

class LocalStorage {
  static const String _keyHabits = 'habitflow_habits_v1';
  static const String _keyLogs = 'habitflow_logs_v1';
  static const String _keyThemeMode = 'habitflow_theme_mode';
  static const String _keyOnboarded = 'habitflow_onboarded';
  static const String _keyTimerInitial = 'focus_timer_initial_seconds';
  static const String _keyTimerRemaining = 'focus_timer_remaining_seconds';
  static const String _keyTimerIsRunning = 'focus_timer_is_running';
  static const String _keyTimerTimestamp = 'focus_timer_timestamp';
  static const String _keyFocusSessions = 'focus_learning_sessions_v1';

  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  static Future<LocalStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }

  // --- Theme ---
  bool get isDarkMode => _prefs.getBool(_keyThemeMode) ?? false;

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_keyThemeMode, value);
  }

  // --- Onboarding ---
  bool get hasCompletedOnboarding => _prefs.getBool(_keyOnboarded) ?? false;

  Future<void> setOnboardingCompleted() async {
    await _prefs.setBool(_keyOnboarded, true);
  }

  // --- Habits ---
  List<Habit> getHabits() {
    // Migration: ensure starter habit streaks are reset to 0 once
    final hasResetStreaks = _prefs.getBool('habitflow_streaks_reset_v2') ?? false;
    if (!hasResetStreaks) {
      _prefs.setBool('habitflow_streaks_reset_v2', true);
      final raw = _prefs.getStringList(_keyHabits);
      if (raw != null && raw.isNotEmpty) {
        try {
          final list = raw.map((jsonStr) => Habit.fromJson(jsonStr)).toList();
          final resetList = list.map((h) {
            if (h.id.startsWith('starter_') && h.streak > 1) {
              return h.copyWith(streak: 0);
            }
            return h;
          }).toList();
          saveHabits(resetList);
          return resetList;
        } catch (_) {}
      }
    }

    final rawList = _prefs.getStringList(_keyHabits);
    if (rawList == null || rawList.isEmpty) {
      return _getStarterHabits();
    }
    try {
      return rawList.map((jsonStr) => Habit.fromJson(jsonStr)).toList();
    } catch (_) {
      return _getStarterHabits();
    }
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final rawList = habits.map((h) => h.toJson()).toList();
    await _prefs.setStringList(_keyHabits, rawList);
  }

  // --- Logs ---
  List<HabitLog> getLogs() {
    final rawList = _prefs.getStringList(_keyLogs);
    if (rawList == null || rawList.isEmpty) return [];
    try {
      return rawList.map((jsonStr) => HabitLog.fromJson(jsonStr)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveLogs(List<HabitLog> logs) async {
    final rawList = logs.map((l) => l.toJson()).toList();
    await _prefs.setStringList(_keyLogs, rawList);
  }

  // --- Focus Timer Persistence ---
  Future<void> saveFocusTimerState({
    required int initialSeconds,
    required int remainingSeconds,
    required bool isRunning,
  }) async {
    await _prefs.setInt(_keyTimerInitial, initialSeconds);
    await _prefs.setInt(_keyTimerRemaining, remainingSeconds);
    await _prefs.setBool(_keyTimerIsRunning, isRunning);
    await _prefs.setInt(_keyTimerTimestamp, DateTime.now().millisecondsSinceEpoch);
  }

  ({int initialSeconds, int remainingSeconds, bool isRunning, int timestamp})? getFocusTimerState() {
    final initial = _prefs.getInt(_keyTimerInitial);
    final remaining = _prefs.getInt(_keyTimerRemaining);
    final isRunning = _prefs.getBool(_keyTimerIsRunning);
    final timestamp = _prefs.getInt(_keyTimerTimestamp);

    if (initial == null || remaining == null || isRunning == null || timestamp == null) {
      return null;
    }

    return (
      initialSeconds: initial,
      remainingSeconds: remaining,
      isRunning: isRunning,
      timestamp: timestamp,
    );
  }

  Future<void> clearFocusTimerState() async {
    await _prefs.remove(_keyTimerInitial);
    await _prefs.remove(_keyTimerRemaining);
    await _prefs.remove(_keyTimerIsRunning);
    await _prefs.remove(_keyTimerTimestamp);
  }

  // --- Learning & Focus Sessions Graph History ---
  Future<void> recordFocusSession(int minutes) async {
    if (minutes <= 0) return;
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final existing = _prefs.getStringList(_keyFocusSessions) ?? [];
    existing.add('$dateStr:$minutes');
    await _prefs.setStringList(_keyFocusSessions, existing);
  }

  Map<int, int> getWeeklyFocusMinutes() {
    // Map of day of week (1 = Monday, 7 = Sunday) to total minutes focused
    final now = DateTime.now();
    // Monday of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final Map<int, int> weeklyMinutes = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};

    // Default starter momentum data so graph looks inspiring and active from day 1
    weeklyMinutes[1] = 45;
    weeklyMinutes[2] = 60;
    weeklyMinutes[3] = 30;
    weeklyMinutes[4] = 75;
    weeklyMinutes[5] = 40;
    weeklyMinutes[6] = 50;
    weeklyMinutes[7] = 65;

    final rawList = _prefs.getStringList(_keyFocusSessions);
    if (rawList != null && rawList.isNotEmpty) {
      for (final entry in rawList) {
        final parts = entry.split(':');
        if (parts.length >= 2) {
          final dateStr = parts[0];
          final mins = int.tryParse(parts[1]) ?? 0;
          try {
            final entryDate = DateTime.parse(dateStr);
            final diffDays = entryDate.difference(DateTime(monday.year, monday.month, monday.day)).inDays;
            if (diffDays >= 0 && diffDays < 7) {
              final weekday = entryDate.weekday; // 1 to 7
              weeklyMinutes[weekday] = (weeklyMinutes[weekday] ?? 0) + mins;
            }
          } catch (_) {}
        }
      }
    }

    return weeklyMinutes;
  }

  // Starter pack matching Stitch Screen 2 & Screen 4
  static List<Habit> _getStarterHabits() {
    final now = DateTime.now();
    return [
      Habit(
        id: 'starter_water',
        title: 'Drink 2L Water',
        description: 'Stay energized with mindful morning hydration',
        category: 'Morning',
        type: 'build',
        icon: 'water_drop',
        colorHex: '#79FAC2', // Mint
        targetValue: 8,
        targetUnit: 'glasses',
        streak: 0,
        reminderTime: '07:30',
        createdAt: now,
      ),
      Habit(
        id: 'starter_reading',
        title: 'Deep Reading',
        description: 'Read 20 pages of non-fiction or philosophy',
        category: 'Learning & Career',
        type: 'build',
        icon: 'menu_book',
        colorHex: '#5D3ADC', // Violet
        targetValue: 20,
        targetUnit: 'pages',
        streak: 0,
        reminderTime: '13:00',
        createdAt: now,
      ),
      Habit(
        id: 'starter_workout',
        title: 'Daily Movement & Cardio',
        description: 'Zone 2 aerobic exercise or calisthenics',
        category: 'Health & Fitness',
        type: 'build',
        icon: 'fitness_center',
        colorHex: '#006C4B', // Emerald
        targetValue: 30,
        targetUnit: 'mins',
        streak: 0,
        reminderTime: '17:30',
        createdAt: now,
      ),
      Habit(
        id: 'starter_journal',
        title: 'Evening Reflection & Gratitude',
        description: 'Review daily friction, wins, and tomorrow goals',
        category: 'Evening',
        type: 'build',
        icon: 'spa',
        colorHex: '#844D2A', // Terracotta
        targetValue: 1,
        targetUnit: 'session',
        streak: 0,
        reminderTime: '21:30',
        createdAt: now,
      ),
    ];
  }
}
