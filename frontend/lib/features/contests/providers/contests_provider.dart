import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../dashboard/providers/habits_provider.dart';
import '../models/contest_model.dart';

class ContestsState {
  final List<ContestModel> contests;
  final List<GlobalLeaderboardUser> leaderboard;
  final int? currentUserRank;
  final bool isLoading;
  final String? errorMessage;

  const ContestsState({
    this.contests = const [],
    this.leaderboard = const [],
    this.currentUserRank,
    this.isLoading = false,
    this.errorMessage,
  });

  ContestsState copyWith({
    List<ContestModel>? contests,
    List<GlobalLeaderboardUser>? leaderboard,
    int? currentUserRank,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ContestsState(
      contests: contests ?? this.contests,
      leaderboard: leaderboard ?? this.leaderboard,
      currentUserRank: currentUserRank ?? this.currentUserRank,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final contestsProvider = StateNotifierProvider<ContestsNotifier, ContestsState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final authState = ref.watch(authProvider);
  final habits = ref.watch(habitsProvider);

  final maxHabitStreak = habits.fold<int>(0, (max, h) => h.streak > max ? h.streak : max);
  final userStreak = (authState.user?.currentStreak != null && authState.user!.currentStreak > maxHabitStreak)
      ? authState.user!.currentStreak
      : maxHabitStreak;
  final userXp = authState.user?.xp ?? (userStreak * 50);
  final userLevel = authState.user?.level ?? (1 + userXp ~/ 200);

  return ContestsNotifier(
    apiClient,
    currentUserName: authState.user?.name ?? 'Alex Rivera',
    currentUserStreak: userStreak,
    currentUserXp: userXp,
    currentUserLevel: userLevel,
  );
});

class ContestsNotifier extends StateNotifier<ContestsState> {
  final dynamic _apiClient;
  final String _currentUserName;
  final int _currentUserStreak;
  final int _currentUserXp;
  final int _currentUserLevel;

  ContestsNotifier(
    this._apiClient, {
    required String currentUserName,
    required int currentUserStreak,
    required int currentUserXp,
    required int currentUserLevel,
  })  : _currentUserName = currentUserName,
        _currentUserStreak = currentUserStreak,
        _currentUserXp = currentUserXp,
        _currentUserLevel = currentUserLevel,
        super(const ContestsState()) {
    loadContestsAndLeaderboard();
  }

  Future<void> loadContestsAndLeaderboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final contestsData = await _apiClient.get('/contests');
      final leaderboardData = await _apiClient.get('/contests/leaderboard');

      List<ContestModel> contests = [];
      if (contestsData is List) {
        contests = contestsData.map((e) => ContestModel.fromMap(e as Map<String, dynamic>)).toList();
      }

      List<GlobalLeaderboardUser> leaderboard = [];
      int? userRank;
      if (leaderboardData is Map<String, dynamic>) {
        final list = leaderboardData['leaderboard'];
        if (list is List) {
          leaderboard = list.asMap().entries.map((e) {
            final u = GlobalLeaderboardUser.fromMap(
              e.value as Map<String, dynamic>,
              e.key + 1,
            );
            if (u.isCurrentUser || u.name == _currentUserName) {
              return GlobalLeaderboardUser(
                rank: u.rank,
                id: u.id,
                name: u.name,
                level: math.max(u.level, _currentUserLevel),
                xp: math.max(u.xp, _currentUserXp),
                currentStreak: math.max(u.currentStreak, _currentUserStreak),
                longestStreak: math.max(u.longestStreak, _currentUserStreak),
                avatarUrl: u.avatarUrl,
                isCurrentUser: true,
              );
            }
            return u;
          }).toList();
        }
        userRank = (leaderboardData['currentUserRank'] as num?)?.toInt();
      }

      // If backend returns empty leaderboard (fresh database), populate with current user
      if (leaderboard.isEmpty) {
        leaderboard = [
          GlobalLeaderboardUser(
            rank: 1,
            id: 'u_current',
            name: _currentUserName,
            level: _currentUserLevel,
            xp: _currentUserXp,
            currentStreak: _currentUserStreak,
            longestStreak: _currentUserStreak,
            isCurrentUser: true,
          ),
        ];
        userRank = 1;
      }

      state = state.copyWith(
        contests: contests,
        leaderboard: leaderboard,
        currentUserRank: userRank,
        isLoading: false,
      );
    } catch (_) {
      // Offline fallback: provide vibrant community contests & leaderboard so users are never blocked
      _loadOfflineFallback();
    }
  }

  void _loadOfflineFallback() {
    final offlineContests = [
      ContestModel(
        id: 'c1',
        title: '30-Day Consistency Championship',
        description: 'Compete across the community! Complete your core habits daily to stay on the leaderboard podium.',
        category: 'all',
        bannerGradient: 'violet',
        rewardBadge: '🥇 Consistency Grandmaster',
        xpReward: 1000,
        targetDays: 30,
        daysRemaining: 18,
        participantCount: 1,
        isOfficial: true,
        isJoined: true,
        userScore: _currentUserXp,
        userStreak: _currentUserStreak,
        userRank: 1,
      ),
      const ContestModel(
        id: 'c2',
        title: 'Deep Focus Marathon',
        description: 'Log 45+ min focus sessions daily and build cognitive momentum.',
        category: 'productivity',
        bannerGradient: 'amber',
        rewardBadge: '⚡ Deep Focus Legend',
        xpReward: 500,
        targetDays: 14,
        daysRemaining: 8,
        participantCount: 1,
        isOfficial: true,
        isJoined: false,
      ),
      ContestModel(
        id: 'c3',
        title: '7-Day Mind & Body Wellness Rush',
        description: 'Hydration, meditation, and active recovery streaks.',
        category: 'wellness',
        bannerGradient: 'emerald',
        rewardBadge: '🌿 Zen & Vitality Master',
        xpReward: 350,
        targetDays: 7,
        daysRemaining: 3,
        participantCount: 1,
        isOfficial: true,
        isJoined: true,
        userScore: _currentUserXp,
        userStreak: _currentUserStreak,
        userRank: 1,
      ),
    ];

    final offlineLeaderboard = [
      GlobalLeaderboardUser(
        rank: 1,
        id: 'u_current',
        name: _currentUserName,
        level: _currentUserLevel,
        xp: _currentUserXp,
        currentStreak: _currentUserStreak,
        longestStreak: _currentUserStreak,
        isCurrentUser: true,
      ),
    ];

    state = state.copyWith(
      contests: offlineContests,
      leaderboard: offlineLeaderboard,
      currentUserRank: 1,
      isLoading: false,
    );
  }

  Future<void> joinContest(String contestId) async {
    try {
      await _apiClient.post('/contests/$contestId/join');
    } catch (_) {
      // Local state update for immediate optimistic UI
    }

    final updated = state.contests.map((c) {
      if (c.id == contestId) {
        return ContestModel(
          id: c.id,
          title: c.title,
          description: c.description,
          category: c.category,
          bannerGradient: c.bannerGradient,
          rewardBadge: c.rewardBadge,
          xpReward: c.xpReward,
          targetDays: c.targetDays,
          daysRemaining: c.daysRemaining,
          participantCount: c.participantCount + 1,
          isOfficial: c.isOfficial,
          isJoined: true,
          userScore: 100,
          userStreak: 1,
          userRank: c.participantCount + 1,
        );
      }
      return c;
    }).toList();

    state = state.copyWith(contests: updated);
  }

  Future<void> createContest({
    required String title,
    required String description,
    required String category,
    required int durationDays,
  }) async {
    try {
      await _apiClient.post(
        '/contests',
        data: {
          'title': title,
          'description': description,
          'category': category,
          'durationDays': durationDays,
        },
      );
    } catch (_) {
      // Local state update
    }

    final newContest = ContestModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      category: category,
      bannerGradient: 'violet',
      rewardBadge: '🏆 Challenge Victor',
      xpReward: 500,
      targetDays: durationDays,
      daysRemaining: durationDays,
      participantCount: 1,
      isOfficial: false,
      isJoined: true,
      userScore: 100,
      userStreak: 1,
      userRank: 1,
    );

    state = state.copyWith(contests: [newContest, ...state.contests]);
  }
}
