import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow_pro/features/auth/models/user_model.dart';
import 'package:habitflow_pro/features/dashboard/models/dashboard_summary_model.dart';
import 'package:habitflow_pro/features/dashboard/models/habit.dart';
import 'package:habitflow_pro/features/dashboard/models/habit_log.dart';
import 'package:habitflow_pro/features/goals/models/goal_model.dart';

void main() {
  group('Habit Model Serialization', () {
    test('should serialize and deserialize Habit correctly', () {
      final now = DateTime(2026, 10, 22, 12, 0, 0);
      final habit = Habit(
        id: 'habit_123',
        title: 'Morning Meditation',
        description: '15 mins mindfulness',
        category: 'Mindfulness',
        type: 'build',
        icon: 'spa',
        colorHex: '#5D3ADC',
        targetValue: 15,
        targetUnit: 'minutes',
        streak: 5,
        reminderTime: '07:00',
        streakShieldEnabled: true,
        createdAt: now,
      );

      final map = habit.toMap();
      expect(map['id'], 'habit_123');
      expect(map['title'], 'Morning Meditation');
      expect(map['category'], 'Mindfulness');
      expect(map['targetValue'], 15);
      expect(map['streakShieldEnabled'], true);

      final fromMap = Habit.fromMap(map);
      expect(fromMap.id, habit.id);
      expect(fromMap.title, habit.title);
      expect(fromMap.streak, 5);
      expect(fromMap.reminderTime, '07:00');
    });

    test('should copyWith preserve unchanged values', () {
      final now = DateTime.now();
      final habit = Habit(
        id: 'h1',
        title: 'Hydration',
        createdAt: now,
      );

      final updated = habit.copyWith(streak: 10, streakShieldEnabled: true);
      expect(updated.id, 'h1');
      expect(updated.title, 'Hydration');
      expect(updated.streak, 10);
      expect(updated.streakShieldEnabled, true);
    });
  });

  group('HabitLog Model Serialization', () {
    test('should serialize and deserialize HabitLog correctly', () {
      final now = DateTime(2026, 10, 22, 8, 30, 0);
      final log = HabitLog(
        id: 'log_99',
        habitId: 'habit_123',
        date: '2026-10-22',
        completed: true,
        progressValue: 15,
        note: 'Felt very focused',
        updatedAt: now,
      );

      final map = log.toMap();
      expect(map['id'], 'log_99');
      expect(map['habitId'], 'habit_123');
      expect(map['date'], '2026-10-22');
      expect(map['completed'], true);
      expect(map['progressValue'], 15);

      final restored = HabitLog.fromMap(map);
      expect(restored.habitId, 'habit_123');
      expect(restored.date, '2026-10-22');
      expect(restored.completed, true);
      expect(restored.note, 'Felt very focused');
    });
  });

  group('GoalModel Serialization', () {
    test('should serialize and calculate progress correctly', () {
      final goal = GoalModel(
        id: 'goal_1',
        title: '30-Day Hydration',
        tier: 'Silver',
        targetValue: 30,
        currentProgress: 15,
        xpReward: 250,
      );

      expect(goal.isCompleted, false);
      expect(goal.progressPercentage, 0.5);

      final completedGoal = goal.copyWith(currentProgress: 30);
      expect(completedGoal.isCompleted, true);
      expect(completedGoal.progressPercentage, 1.0);

      final map = goal.toMap();
      final fromMap = GoalModel.fromMap(map);
      expect(fromMap.id, goal.id);
      expect(fromMap.title, goal.title);
      expect(fromMap.tier, 'Silver');
    });
  });

  group('UserModel Serialization', () {
    test('should deserialize SafeUser backend payload correctly', () {
      final backendJson = {
        'id': '6ada22ac30bfb7582380ad33',
        'email': 'alex@habitflow.pro',
        'name': 'Alex Rivera',
        'level': 6,
        'xp': 1450,
        'currentStreak': 14,
        'longestStreak': 28,
        'createdAt': '2026-10-01T00:00:00.000Z',
      };

      final user = UserModel.fromMap(backendJson);
      expect(user.id, '6ada22ac30bfb7582380ad33');
      expect(user.email, 'alex@habitflow.pro');
      expect(user.name, 'Alex Rivera');
      expect(user.level, 6);
      expect(user.xp, 1450);
      expect(user.currentStreak, 14);
      expect(user.longestStreak, 28);
    });
  });

  group('DashboardSummaryModel Serialization', () {
    test('should deserialize backend dashboard summary correctly', () {
      final summaryJson = {
        'date': '2026-10-22',
        'metrics': {
          'activeHabitCount': 4,
          'todayCompletedCount': 3,
          'todayCompletionRate': 0.75,
          'highestCurrentStreak': 14,
        },
        'goals': {
          'active': 2,
          'completed': 1,
          'archived': 0,
        },
        'recentActivity': [
          {
            'id': 'act_1',
            'habitId': 'h1',
            'title': 'Morning Water',
            'category': 'Morning',
            'icon': 'water_drop',
            'colorHex': '#79FAC2',
            'date': '2026-10-22',
            'progressValue': 8,
          }
        ],
      };

      final summary = DashboardSummaryModel.fromMap(summaryJson);
      expect(summary.date, '2026-10-22');
      expect(summary.metrics.activeHabitCount, 4);
      expect(summary.metrics.todayCompletedCount, 3);
      expect(summary.metrics.todayCompletionRate, 0.75);
      expect(summary.metrics.highestCurrentStreak, 14);
      expect(summary.goals['active'], 2);
      expect(summary.recentActivity.length, 1);
      expect(summary.recentActivity.first.title, 'Morning Water');
    });
  });
}
