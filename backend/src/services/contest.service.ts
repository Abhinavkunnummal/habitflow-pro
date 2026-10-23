import mongoose from 'mongoose';
import { Contest } from '../models/Contest';
import { User } from '../models/User';
import { AppError } from '../middleware/errorHandler';

export interface LeaderboardUserEntry {
  rank: number;
  id: string;
  name: string;
  avatarUrl?: string;
  level: number;
  xp: number;
  currentStreak: number;
  longestStreak: number;
  isCurrentUser: boolean;
}

export class ContestService {
  /**
   * Seeds default official contests if database has no active official contests.
   */
  public static async seedDefaultContests(): Promise<void> {
    const count = await Contest.countDocuments({ isOfficial: true });
    if (count > 0) return;

    const now = new Date();
    const in30Days = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);
    const in14Days = new Date(now.getTime() + 14 * 24 * 60 * 60 * 1000);
    const in7Days = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);

    await Contest.create([
      {
        title: '30-Day Consistency Championship',
        description: 'Compete with the entire HabitFlow community! Complete your core habits daily to climb the leaderboard and claim the Grandmaster Trophy.',
        category: 'all',
        bannerGradient: 'violet',
        rewardBadge: '🥇 Consistency Grandmaster',
        xpReward: 1000,
        targetDays: 30,
        startDate: now,
        endDate: in30Days,
        isOfficial: true,
        participants: [],
      },
      {
        title: 'Deep Focus Sprint',
        description: 'Level up your deep work! Log 45+ minutes of focus timer sessions daily and build unbroken cognitive momentum.',
        category: 'productivity',
        bannerGradient: 'amber',
        rewardBadge: '⚡ Deep Focus Legend',
        xpReward: 500,
        targetDays: 14,
        startDate: now,
        endDate: in14Days,
        isOfficial: true,
        participants: [],
      },
      {
        title: '7-Day Mind & Body Wellness Rush',
        description: 'Stay hydrated, meditate, and hit daily active recovery. Prove 100% completion across 7 days.',
        category: 'wellness',
        bannerGradient: 'emerald',
        rewardBadge: '🌿 Zen & Vitality Master',
        xpReward: 350,
        targetDays: 7,
        startDate: now,
        endDate: in7Days,
        isOfficial: true,
        participants: [],
      },
    ]);
  }

  /**
   * List all active contests with user participation status.
   */
  public static async getContests(currentUserId?: string): Promise<any[]> {
    await this.seedDefaultContests();

    const contests = await Contest.find({}).sort({ isOfficial: -1, createdAt: -1 });

    return contests.map((c) => {
      const json: any = c.toJSON();
      const userParticipant = currentUserId
        ? c.participants.find((p) => p.userId.toString() === currentUserId)
        : undefined;

      json.participantCount = c.participants.length;
      json.isJoined = !!userParticipant;
      json.userScore = userParticipant?.score ?? 0;
      json.userStreak = userParticipant?.streak ?? 0;

      // Calculate time remaining in days
      const msLeft = new Date(c.endDate).getTime() - Date.now();
      json.daysRemaining = Math.max(0, Math.ceil(msLeft / (1000 * 60 * 60 * 24)));

      return json;
    });
  }

  /**
   * Get single contest details with full ranked leaderboard.
   */
  public static async getContestById(contestId: string, currentUserId?: string): Promise<any> {
    if (!mongoose.Types.ObjectId.isValid(contestId)) {
      throw new AppError('Invalid contest ID', 400, 'INVALID_ID');
    }

    const contest = await Contest.findById(contestId);
    if (!contest) {
      throw new AppError('Contest not found', 404, 'NOT_FOUND');
    }

    const json: any = contest.toJSON();

    // Sort participants by score descending, then streak descending
    const sortedParticipants = [...contest.participants].sort((a, b) => {
      if (b.score !== a.score) return b.score - a.score;
      return b.streak - a.streak;
    });

    json.leaderboard = sortedParticipants.map((p, idx) => ({
      rank: idx + 1,
      userId: p.userId.toString(),
      name: p.name,
      avatarUrl: p.avatarUrl,
      score: p.score,
      streak: p.streak,
      isCurrentUser: currentUserId ? p.userId.toString() === currentUserId : false,
    }));

    const userEntry = json.leaderboard.find((e: any) => e.isCurrentUser);
    json.userRank = userEntry ? userEntry.rank : null;
    json.isJoined = !!userEntry;
    json.daysRemaining = Math.max(
      0,
      Math.ceil((new Date(contest.endDate).getTime() - Date.now()) / (1000 * 60 * 60 * 24))
    );

    return json;
  }

  /**
   * Create a new custom competition / contest.
   */
  public static async createContest(
    userId: string,
    data: {
      title: string;
      description: string;
      category?: 'all' | 'wellness' | 'productivity' | 'fitness' | 'mindfulness';
      durationDays?: number;
      rewardBadge?: string;
      xpReward?: number;
    }
  ): Promise<any> {
    const user = await User.findById(userId);
    if (!user) {
      throw new AppError('User not found', 404, 'USER_NOT_FOUND');
    }

    const durationDays = data.durationDays || 14;
    const now = new Date();
    const endDate = new Date(now.getTime() + durationDays * 24 * 60 * 60 * 1000);

    const contest = await Contest.create({
      title: data.title,
      description: data.description,
      category: data.category || 'all',
      bannerGradient: 'violet',
      rewardBadge: data.rewardBadge || '🏆 Challenge Victor',
      xpReward: data.xpReward || 500,
      targetDays: durationDays,
      startDate: now,
      endDate: endDate,
      createdBy: user._id,
      isOfficial: false,
      participants: [
        {
          userId: user._id,
          name: user.name,
          avatarUrl: user.avatarUrl,
          score: user.xp,
          streak: user.currentStreak,
          joinedAt: now,
        },
      ],
    });

    return contest.toJSON();
  }

  /**
   * Join an existing contest.
   */
  public static async joinContest(contestId: string, userId: string): Promise<any> {
    if (!mongoose.Types.ObjectId.isValid(contestId)) {
      throw new AppError('Invalid contest ID', 400, 'INVALID_ID');
    }

    const [contest, user] = await Promise.all([
      Contest.findById(contestId),
      User.findById(userId),
    ]);

    if (!contest) {
      throw new AppError('Contest not found', 404, 'NOT_FOUND');
    }
    if (!user) {
      throw new AppError('User not found', 404, 'USER_NOT_FOUND');
    }

    const alreadyJoined = contest.participants.some(
      (p) => p.userId.toString() === userId
    );

    if (alreadyJoined) {
      return contest.toJSON();
    }

    contest.participants.push({
      userId: user._id as mongoose.Types.ObjectId,
      name: user.name,
      avatarUrl: user.avatarUrl,
      score: user.xp,
      streak: user.currentStreak,
      joinedAt: new Date(),
    });

    await contest.save();
    return contest.toJSON();
  }

  /**
   * Get Global Community Leaderboard across all registered users in MongoDB Atlas.
   */
  public static async getGlobalLeaderboard(
    currentUserId?: string
  ): Promise<{ leaderboard: LeaderboardUserEntry[]; currentUserRank: number | null }> {
    const users = await User.find({})
      .select('name avatarUrl level xp currentStreak longestStreak')
      .sort({ xp: -1, currentStreak: -1 })
      .limit(50);

    const entries: LeaderboardUserEntry[] = users.map((u, idx) => ({
      rank: idx + 1,
      id: u._id.toString(),
      name: u.name,
      avatarUrl: u.avatarUrl,
      level: u.level || 1,
      xp: u.xp || 0,
      currentStreak: u.currentStreak || 0,
      longestStreak: u.longestStreak || 0,
      isCurrentUser: currentUserId ? u._id.toString() === currentUserId : false,
    }));

    const currentEntry = entries.find((e) => e.isCurrentUser);

    return {
      leaderboard: entries,
      currentUserRank: currentEntry ? currentEntry.rank : null,
    };
  }
}
