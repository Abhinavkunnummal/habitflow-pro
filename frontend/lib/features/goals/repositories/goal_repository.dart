import '../../../core/api/api_client.dart';
import '../models/goal_model.dart';

class GoalRepository {
  final ApiClient _apiClient;

  GoalRepository(this._apiClient);

  Future<List<GoalModel>> listGoals({String? status}) async {
    final queryParams = <String, dynamic>{
      if (status != null) 'status': status,
      'limit': 50,
    };

    final response = await _apiClient.get(
      '/goals',
      queryParameters: queryParams,
    );

    final data = response as Map<String, dynamic>;
    final rawGoals = data['goals'] as List<dynamic>? ?? [];
    return rawGoals
        .map((item) => GoalModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<GoalModel> createGoal(GoalModel goal) async {
    final payload = {
      'title': goal.title,
      if (goal.description != null && goal.description!.isNotEmpty)
        'description': goal.description,
      'tier': goal.tier,
      'targetValue': goal.targetValue,
      'targetUnit': goal.targetUnit,
      'xpReward': goal.xpReward,
      'linkedHabitIds': goal.linkedHabitIds,
    };

    final response = await _apiClient.post(
      '/goals',
      data: payload,
    );

    final data = response as Map<String, dynamic>;
    return GoalModel.fromMap(data['goal'] as Map<String, dynamic>);
  }

  Future<GoalModel> getGoalById(String id) async {
    final response = await _apiClient.get('/goals/$id');
    final data = response as Map<String, dynamic>;
    return GoalModel.fromMap(data['goal'] as Map<String, dynamic>);
  }

  Future<GoalModel> updateGoal(String id, Map<String, dynamic> updates) async {
    final response = await _apiClient.patch(
      '/goals/$id',
      data: updates,
    );

    final data = response as Map<String, dynamic>;
    return GoalModel.fromMap(data['goal'] as Map<String, dynamic>);
  }

  Future<GoalModel> deleteGoal(String id) async {
    final response = await _apiClient.delete('/goals/$id');
    final data = response as Map<String, dynamic>;
    return GoalModel.fromMap(data['goal'] as Map<String, dynamic>);
  }
}
