import '../../../core/api/api_client.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';

class HabitRepository {
  final ApiClient _apiClient;

  HabitRepository(this._apiClient);

  Future<List<Habit>> listHabits({
    String? category,
    bool? isArchived = false,
  }) async {
    final queryParams = <String, dynamic>{
      if (category != null && category != 'All') 'category': category,
      if (isArchived != null) 'isArchived': isArchived.toString(),
      'limit': 50,
    };

    final response = await _apiClient.get(
      '/habits',
      queryParameters: queryParams,
    );

    final data = response as Map<String, dynamic>;
    final rawHabits = data['habits'] as List<dynamic>? ?? [];
    return rawHabits
        .map((item) => Habit.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<Habit> createHabit(Habit habit) async {
    final payload = {
      'title': habit.title,
      if (habit.description != null && habit.description!.isNotEmpty)
        'description': habit.description,
      'category': habit.category,
      'type': habit.type,
      'icon': habit.icon,
      'colorHex': habit.colorHex,
      'targetValue': habit.targetValue,
      'targetUnit': habit.targetUnit,
      if (habit.reminderTime != null && habit.reminderTime!.isNotEmpty)
        'reminderTime': habit.reminderTime,
      'streakShieldEnabled': habit.streakShieldEnabled,
    };

    final response = await _apiClient.post(
      '/habits',
      data: payload,
    );

    final data = response as Map<String, dynamic>;
    return Habit.fromMap(data['habit'] as Map<String, dynamic>);
  }

  Future<Habit> getHabitById(String id) async {
    final response = await _apiClient.get('/habits/$id');
    final data = response as Map<String, dynamic>;
    return Habit.fromMap(data['habit'] as Map<String, dynamic>);
  }

  Future<Habit> updateHabit(String id, Map<String, dynamic> updates) async {
    final response = await _apiClient.patch(
      '/habits/$id',
      data: updates,
    );

    final data = response as Map<String, dynamic>;
    return Habit.fromMap(data['habit'] as Map<String, dynamic>);
  }

  Future<Habit> deleteHabit(String id) async {
    final response = await _apiClient.delete('/habits/$id');
    final data = response as Map<String, dynamic>;
    return Habit.fromMap(data['habit'] as Map<String, dynamic>);
  }

  Future<({HabitLog log, int currentStreak, int longestStreak})> recordCompletion({
    required String habitId,
    required String date,
    required bool completed,
    int progressValue = 1,
    String? note,
  }) async {
    final payload = {
      'completed': completed,
      'progressValue': progressValue,
      if (note != null) 'note': note,
    };

    final response = await _apiClient.put(
      '/habits/$habitId/completions/$date',
      data: payload,
    );

    final data = response as Map<String, dynamic>;
    final log = HabitLog.fromMap(data['log'] as Map<String, dynamic>);
    final streakStats = data['streakStats'] as Map<String, dynamic>?;
    final currentStreak = (streakStats?['currentStreak'] as num?)?.toInt() ?? 0;
    final longestStreak = (streakStats?['longestStreak'] as num?)?.toInt() ?? 0;

    return (
      log: log,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
    );
  }

  Future<List<HabitLog>> getHabitCompletions(
    String habitId, {
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      'limit': 50,
    };

    final response = await _apiClient.get(
      '/habits/$habitId/completions',
      queryParameters: queryParams,
    );

    final data = response as Map<String, dynamic>;
    final rawCompletions = data['completions'] as List<dynamic>? ?? [];
    return rawCompletions
        .map((item) => HabitLog.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<HabitLog>> getTodayCompletions({String? date}) async {
    final queryParams = <String, dynamic>{
      if (date != null) 'date': date,
    };

    final response = await _apiClient.get(
      '/completions/today',
      queryParameters: queryParams,
    );

    final data = response as Map<String, dynamic>;
    final habitsWithStatus = data['habits'] as List<dynamic>? ?? [];
    final targetDate = data['date'] as String? ?? date ?? '';

    final logs = <HabitLog>[];
    for (final item in habitsWithStatus) {
      final map = item as Map<String, dynamic>;
      final habitMap = map['habit'] as Map<String, dynamic>;
      final habitId = habitMap['id']?.toString() ?? '';
      final isCompleted = map['isCompleted'] as bool? ?? false;
      final progressValue = (map['progressValue'] as num?)?.toInt() ?? 1;
      final logId = map['logId']?.toString() ?? '${habitId}_$targetDate';

      logs.add(
        HabitLog(
          id: logId,
          habitId: habitId,
          date: targetDate,
          completed: isCompleted,
          progressValue: progressValue,
          updatedAt: DateTime.now(),
        ),
      );
    }
    return logs;
  }
}
