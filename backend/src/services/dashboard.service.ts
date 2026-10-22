import mongoose from 'mongoose';
import { Habit } from '../models/Habit';
import { HabitLog } from '../models/HabitLog';
import { Goal } from '../models/Goal';

export class DashboardService {
  public static async getSummary(userId: string, clientDate?: string) {
    const userObjectId = new mongoose.Types.ObjectId(userId);
    const todayStr = clientDate || new Date().toISOString().slice(0, 10);

    // Parallel aggregations for low latency & low memory consumption
    const [activeHabits, todayLogs, goalsSummary, recentLogs] = await Promise.all([
      // 1. Active habits
      Habit.find({ userId: userObjectId, isArchived: false }).select(
        '_id title category icon colorHex streak streakShieldEnabled'
      ),

      // 2. Today's completion logs
      HabitLog.find({
        userId: userObjectId,
        date: todayStr,
        completed: true,
      }).select('habitId progressValue'),

      // 3. Goal counts by status
      Goal.aggregate([
        { $match: { userId: userObjectId } },
        { $group: { _id: '$status', count: { $sum: 1 } } },
      ]),

      // 4. Recent activity (last 7 completed habit logs)
      HabitLog.find({
        userId: userObjectId,
        completed: true,
      })
        .sort({ date: -1, createdAt: -1 })
        .limit(7)
        .populate('habitId', 'title category icon colorHex')
        .lean(),
    ]);

    const activeHabitCount = activeHabits.length;
    const completedHabitIds = new Set(todayLogs.map((l) => l.habitId.toString()));
    const todayCompletedCount = activeHabits.filter((h) =>
      completedHabitIds.has(h._id.toString())
    ).length;

    const todayCompletionRate =
      activeHabitCount > 0
        ? Math.round((todayCompletedCount / activeHabitCount) * 100) / 100
        : 0;

    // Highest current and longest streaks among active habits
    let highestCurrentStreak = 0;
    activeHabits.forEach((h) => {
      if (h.streak > highestCurrentStreak) {
        highestCurrentStreak = h.streak;
      }
    });

    const goalsMap = { active: 0, completed: 0, archived: 0 };
    goalsSummary.forEach((item: { _id: 'active' | 'completed' | 'archived'; count: number }) => {
      if (item._id in goalsMap) {
        goalsMap[item._id] = item.count;
      }
    });

    return {
      date: todayStr,
      metrics: {
        activeHabitCount,
        todayCompletedCount,
        todayCompletionRate, // e.g. 0.75 for 75%
        highestCurrentStreak,
      },
      goals: goalsMap,
      recentActivity: recentLogs.map((l: any) => ({
        id: l._id.toString(),
        habitId: l.habitId?._id ? l.habitId._id.toString() : l.habitId?.toString(),
        title: l.habitId?.title || 'Unknown Habit',
        category: l.habitId?.category || 'General',
        icon: l.habitId?.icon || 'bolt',
        colorHex: l.habitId?.colorHex || '#5D3ADC',
        date: l.date,
        progressValue: l.progressValue,
      })),
    };
  }
}
