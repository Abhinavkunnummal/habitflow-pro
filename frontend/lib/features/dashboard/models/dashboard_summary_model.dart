class DashboardMetrics {
  final int activeHabitCount;
  final int todayCompletedCount;
  final double todayCompletionRate; // e.g. 0.75 for 75%
  final int highestCurrentStreak;

  const DashboardMetrics({
    this.activeHabitCount = 0,
    this.todayCompletedCount = 0,
    this.todayCompletionRate = 0.0,
    this.highestCurrentStreak = 0,
  });

  factory DashboardMetrics.fromMap(Map<String, dynamic> map) {
    return DashboardMetrics(
      activeHabitCount: (map['activeHabitCount'] as num?)?.toInt() ?? 0,
      todayCompletedCount: (map['todayCompletedCount'] as num?)?.toInt() ?? 0,
      todayCompletionRate: (map['todayCompletionRate'] as num?)?.toDouble() ?? 0.0,
      highestCurrentStreak: (map['highestCurrentStreak'] as num?)?.toInt() ?? 0,
    );
  }
}

class DashboardRecentActivity {
  final String id;
  final String habitId;
  final String title;
  final String category;
  final String icon;
  final String colorHex;
  final String date;
  final int progressValue;

  const DashboardRecentActivity({
    required this.id,
    required this.habitId,
    required this.title,
    required this.category,
    required this.icon,
    required this.colorHex,
    required this.date,
    this.progressValue = 1,
  });

  factory DashboardRecentActivity.fromMap(Map<String, dynamic> map) {
    return DashboardRecentActivity(
      id: map['id']?.toString() ?? '',
      habitId: map['habitId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      category: map['category']?.toString() ?? 'General',
      icon: map['icon']?.toString() ?? 'bolt',
      colorHex: map['colorHex']?.toString() ?? '#5D3ADC',
      date: map['date']?.toString() ?? '',
      progressValue: (map['progressValue'] as num?)?.toInt() ?? 1,
    );
  }
}

class DashboardSummaryModel {
  final String date;
  final DashboardMetrics metrics;
  final Map<String, int> goals;
  final List<DashboardRecentActivity> recentActivity;

  const DashboardSummaryModel({
    required this.date,
    required this.metrics,
    this.goals = const {'active': 0, 'completed': 0, 'archived': 0},
    this.recentActivity = const [],
  });

  factory DashboardSummaryModel.fromMap(Map<String, dynamic> map) {
    final rawGoals = map['goals'] as Map<String, dynamic>? ?? {};
    final goalsMap = <String, int>{
      'active': (rawGoals['active'] as num?)?.toInt() ?? 0,
      'completed': (rawGoals['completed'] as num?)?.toInt() ?? 0,
      'archived': (rawGoals['archived'] as num?)?.toInt() ?? 0,
    };

    final rawActivity = map['recentActivity'] as List<dynamic>? ?? [];
    final recentActivity = rawActivity
        .map((a) => DashboardRecentActivity.fromMap(a as Map<String, dynamic>))
        .toList();

    return DashboardSummaryModel(
      date: map['date']?.toString() ?? '',
      metrics: map['metrics'] is Map<String, dynamic>
          ? DashboardMetrics.fromMap(map['metrics'] as Map<String, dynamic>)
          : const DashboardMetrics(),
      goals: goalsMap,
      recentActivity: recentActivity,
    );
  }
}
