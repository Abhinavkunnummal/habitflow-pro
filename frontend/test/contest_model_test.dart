import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow_pro/features/contests/models/contest_model.dart';

void main() {
  group('ContestModel & GlobalLeaderboardUser serialization', () {
    test('ContestModel deserializes correctly from backend JSON', () {
      final json = {
        'id': 'contest_123',
        'title': '30-Day Consistency Championship',
        'description': 'Compete across the community!',
        'category': 'all',
        'bannerGradient': 'violet',
        'rewardBadge': '🥇 Consistency Grandmaster',
        'xpReward': 1000,
        'targetDays': 30,
        'daysRemaining': 20,
        'participantCount': 35,
        'isOfficial': true,
        'isJoined': true,
        'userScore': 500,
        'userStreak': 7,
        'userRank': 2,
        'leaderboard': [
          {
            'userId': 'usr_1',
            'name': 'Elena Rostova',
            'score': 750,
            'streak': 10,
            'rank': 1,
            'isCurrentUser': false,
          },
          {
            'userId': 'usr_2',
            'name': 'Alex Rivera',
            'score': 500,
            'streak': 7,
            'rank': 2,
            'isCurrentUser': true,
          },
        ],
      };

      final contest = ContestModel.fromMap(json);

      expect(contest.id, 'contest_123');
      expect(contest.title, '30-Day Consistency Championship');
      expect(contest.isOfficial, true);
      expect(contest.isJoined, true);
      expect(contest.userRank, 2);
      expect(contest.leaderboard.length, 2);
      expect(contest.leaderboard[1].isCurrentUser, true);
    });

    test('GlobalLeaderboardUser deserializes correctly', () {
      final userJson = {
        'id': 'usr_leader',
        'name': 'Marcus Chen',
        'level': 8,
        'xp': 2240,
        'currentStreak': 18,
        'longestStreak': 25,
        'isCurrentUser': false,
      };

      final entry = GlobalLeaderboardUser.fromMap(userJson, 1);

      expect(entry.rank, 1);
      expect(entry.name, 'Marcus Chen');
      expect(entry.xp, 2240);
      expect(entry.currentStreak, 18);
      expect(entry.isCurrentUser, false);
    });
  });
}
