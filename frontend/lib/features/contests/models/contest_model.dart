class ContestParticipant {
  final String userId;
  final String name;
  final String? avatarUrl;
  final int score;
  final int streak;
  final int rank;
  final bool isCurrentUser;

  const ContestParticipant({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.score,
    required this.streak,
    required this.rank,
    this.isCurrentUser = false,
  });

  factory ContestParticipant.fromMap(Map<String, dynamic> map, {int fallbackRank = 0}) {
    return ContestParticipant(
      userId: map['userId']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Habit Builder',
      avatarUrl: map['avatarUrl']?.toString(),
      score: (map['score'] as num?)?.toInt() ?? 0,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      rank: (map['rank'] as num?)?.toInt() ?? fallbackRank,
      isCurrentUser: map['isCurrentUser'] == true,
    );
  }
}

class ContestModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String bannerGradient;
  final String rewardBadge;
  final int xpReward;
  final int targetDays;
  final int daysRemaining;
  final int participantCount;
  final bool isOfficial;
  final bool isJoined;
  final int userScore;
  final int userStreak;
  final int? userRank;
  final List<ContestParticipant> leaderboard;

  const ContestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.bannerGradient = 'violet',
    this.rewardBadge = '🥇 Consistency Champion',
    this.xpReward = 500,
    this.targetDays = 30,
    this.daysRemaining = 30,
    this.participantCount = 0,
    this.isOfficial = false,
    this.isJoined = false,
    this.userScore = 0,
    this.userStreak = 0,
    this.userRank,
    this.leaderboard = const [],
  });

  factory ContestModel.fromMap(Map<String, dynamic> map) {
    final rawLeaderboard = map['leaderboard'];
    List<ContestParticipant> participants = [];
    if (rawLeaderboard is List) {
      participants = rawLeaderboard
          .asMap()
          .entries
          .map((e) => ContestParticipant.fromMap(
                e.value as Map<String, dynamic>,
                fallbackRank: e.key + 1,
              ))
          .toList();
    }

    return ContestModel(
      id: map['id']?.toString() ?? map['_id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Habit Contest',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? 'all',
      bannerGradient: map['bannerGradient']?.toString() ?? 'violet',
      rewardBadge: map['rewardBadge']?.toString() ?? '🥇 Consistency Champion',
      xpReward: (map['xpReward'] as num?)?.toInt() ?? 500,
      targetDays: (map['targetDays'] as num?)?.toInt() ?? 30,
      daysRemaining: (map['daysRemaining'] as num?)?.toInt() ?? 14,
      participantCount: (map['participantCount'] as num?)?.toInt() ?? participants.length,
      isOfficial: map['isOfficial'] == true,
      isJoined: map['isJoined'] == true,
      userScore: (map['userScore'] as num?)?.toInt() ?? 0,
      userStreak: (map['userStreak'] as num?)?.toInt() ?? 0,
      userRank: (map['userRank'] as num?)?.toInt(),
      leaderboard: participants,
    );
  }
}

class GlobalLeaderboardUser {
  final int rank;
  final String id;
  final String name;
  final String? avatarUrl;
  final int level;
  final int xp;
  final int currentStreak;
  final int longestStreak;
  final bool isCurrentUser;

  const GlobalLeaderboardUser({
    required this.rank,
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.level,
    required this.xp,
    required this.currentStreak,
    required this.longestStreak,
    this.isCurrentUser = false,
  });

  factory GlobalLeaderboardUser.fromMap(Map<String, dynamic> map, int fallbackRank) {
    return GlobalLeaderboardUser(
      rank: (map['rank'] as num?)?.toInt() ?? fallbackRank,
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Competitor',
      avatarUrl: map['avatarUrl']?.toString(),
      level: (map['level'] as num?)?.toInt() ?? 1,
      xp: (map['xp'] as num?)?.toInt() ?? 0,
      currentStreak: (map['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (map['longestStreak'] as num?)?.toInt() ?? 0,
      isCurrentUser: map['isCurrentUser'] == true,
    );
  }
}
