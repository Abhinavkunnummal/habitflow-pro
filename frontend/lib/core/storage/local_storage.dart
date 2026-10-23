import 'package:shared_preferences/shared_preferences.dart';
import '../../features/dashboard/models/habit.dart';
import '../../features/dashboard/models/habit_log.dart';

class LocalStorage {
  static const String _keyHabits = 'habitflow_habits_v1';
  static const String _keyLogs = 'habitflow_logs_v1';
  static const String _keyThemeMode = 'habitflow_theme_mode';
  static const String _keyOnboarded = 'habitflow_onboarded';

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
