import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/goal_model.dart';
import '../repositories/goal_repository.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GoalRepository(apiClient);
});

final goalsProvider = StateNotifierProvider<GoalsNotifier, List<GoalModel>>((ref) {
  final repository = ref.watch(goalRepositoryProvider);
  return GoalsNotifier(repository, ref);
});

class GoalsNotifier extends StateNotifier<List<GoalModel>> {
  final GoalRepository _repository;
  final Ref _ref;

  GoalsNotifier(this._repository, this._ref) : super(_getStarterGoals()) {
    _listenAuth();
  }

  void _listenAuth() {
    _ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        fetchGoals();
      } else if (previous?.isAuthenticated == true && !next.isAuthenticated) {
        clearUserData();
      }
    });
  }

  Future<void> fetchGoals() async {
    try {
      final goals = await _repository.listGoals();
      if (goals.isNotEmpty) {
        state = goals;
      }
    } catch (_) {
      // Keep existing / starter goals on failure
    }
  }

  Future<bool> addGoal(GoalModel goal) async {
    final authState = _ref.read(authProvider);
    if (authState.isAuthenticated) {
      try {
        final created = await _repository.createGoal(goal);
        state = [...state, created];
        return true;
      } catch (_) {
        state = [...state, goal];
        return false;
      }
    } else {
      state = [...state, goal];
      return true;
    }
  }

  Future<void> updateGoalProgress(String id, int addedProgress) async {
    final index = state.indexWhere((g) => g.id == id);
    if (index >= 0) {
      final goal = state[index];
      final newProgress = goal.currentProgress + addedProgress;
      final isNowCompleted = newProgress >= goal.targetValue;
      final updated = goal.copyWith(
        currentProgress: newProgress,
        status: isNowCompleted ? 'completed' : goal.status,
      );

      final updatedList = List<GoalModel>.from(state);
      updatedList[index] = updated;
      state = updatedList;

      final authState = _ref.read(authProvider);
      if (authState.isAuthenticated) {
        try {
          await _repository.updateGoal(id, {
            'currentProgress': newProgress,
            'status': isNowCompleted ? 'completed' : goal.status,
          });
        } catch (_) {}
      }
    }
  }

  void clearUserData() {
    state = _getStarterGoals();
  }

  static List<GoalModel> _getStarterGoals() {
    return [
      GoalModel(
        id: 'starter_horizon_1',
        title: '30-Day Morning Flow Mastery',
        description: 'Complete hydration and morning mindfulness consistently',
        tier: 'Silver',
        targetValue: 30,
        targetUnit: 'days',
        currentProgress: 14,
        status: 'active',
        xpReward: 250,
      ),
      GoalModel(
        id: 'starter_horizon_2',
        title: '7-Day Workout Streak',
        description: 'Zone 2 movement and calisthenics training',
        tier: 'Bronze',
        targetValue: 7,
        targetUnit: 'days',
        currentProgress: 5,
        status: 'active',
        xpReward: 100,
      ),
    ];
  }
}
