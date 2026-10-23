import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow_pro/features/dashboard/models/habit_log.dart';
import 'package:habitflow_pro/features/dashboard/providers/habits_provider.dart';
import 'package:intl/intl.dart';

void main() {
  group('calculateStreakFromLogs Algorithm', () {
    final refDate = DateTime(2026, 10, 23); // Friday
    final todayStr = DateFormat('yyyy-MM-dd').format(refDate);
    final yesterdayStr = DateFormat('yyyy-MM-dd').format(refDate.subtract(const Duration(days: 1)));
    final day2AgoStr = DateFormat('yyyy-MM-dd').format(refDate.subtract(const Duration(days: 2)));
    final day3AgoStr = DateFormat('yyyy-MM-dd').format(refDate.subtract(const Duration(days: 3)));

    test('should return 0 streak for empty logs', () {
      final streak = calculateStreakFromLogs('h1', [], refDate);
      expect(streak, 0);
    });

    test('should return 1 when completed today only', () {
      final logs = [
        HabitLog(id: 'l1', habitId: 'h1', date: todayStr, completed: true),
      ];
      final streak = calculateStreakFromLogs('h1', logs, refDate);
      expect(streak, 1);
    });

    test('should return 2 when completed today and yesterday', () {
      final logs = [
        HabitLog(id: 'l1', habitId: 'h1', date: todayStr, completed: true),
        HabitLog(id: 'l2', habitId: 'h1', date: yesterdayStr, completed: true),
      ];
      final streak = calculateStreakFromLogs('h1', logs, refDate);
      expect(streak, 2);
    });

    test('should return 1 when completed yesterday but not yet completed today', () {
      final logs = [
        HabitLog(id: 'l1', habitId: 'h1', date: yesterdayStr, completed: true),
      ];
      final streak = calculateStreakFromLogs('h1', logs, refDate);
      expect(streak, 1);
    });

    test('should return 0 when habit was completed 3 days ago but missed yesterday and today', () {
      final logs = [
        HabitLog(id: 'l1', habitId: 'h1', date: day3AgoStr, completed: true),
      ];
      final streak = calculateStreakFromLogs('h1', logs, refDate);
      expect(streak, 0);
    });

    test('should return 4 for 4 consecutive completed days', () {
      final logs = [
        HabitLog(id: 'l1', habitId: 'h1', date: todayStr, completed: true),
        HabitLog(id: 'l2', habitId: 'h1', date: yesterdayStr, completed: true),
        HabitLog(id: 'l3', habitId: 'h1', date: day2AgoStr, completed: true),
        HabitLog(id: 'l4', habitId: 'h1', date: day3AgoStr, completed: true),
      ];
      final streak = calculateStreakFromLogs('h1', logs, refDate);
      expect(streak, 4);
    });

    test('should ignore logs for other habits and uncompleted logs', () {
      final logs = [
        HabitLog(id: 'l1', habitId: 'h1', date: todayStr, completed: true),
        HabitLog(id: 'l2', habitId: 'h2', date: yesterdayStr, completed: true),
        HabitLog(id: 'l3', habitId: 'h1', date: yesterdayStr, completed: false),
      ];
      final streak = calculateStreakFromLogs('h1', logs, refDate);
      expect(streak, 1);
    });
  });
}
