import mongoose from 'mongoose';
import { Habit } from '../models/Habit';
import { HabitLog, IHabitLog } from '../models/HabitLog';
import { AppError } from '../middleware/errorHandler';
import { StreakService } from './streak.service';
import { RecordCompletionInput, HabitCompletionsQuery } from '../validators/completion.validator';

export class CompletionService {
  /**
   * Idempotent completion record creation or update
   */
  public static async recordCompletion(
    userId: string,
    habitId: string,
    date: string,
    input: RecordCompletionInput
  ) {
    // 1. Ownership & existence check
    const habit = await Habit.findOne({
      _id: new mongoose.Types.ObjectId(habitId),
      userId: new mongoose.Types.ObjectId(userId),
    });

    if (!habit) {
      throw new AppError('Habit not found or access denied', 404, 'NOT_FOUND');
    }

    // 2. Idempotent Upsert on compound key { userId, habitId, date }
    const log = await HabitLog.findOneAndUpdate(
      {
        userId: new mongoose.Types.ObjectId(userId),
        habitId: new mongoose.Types.ObjectId(habitId),
        date,
      },
      {
        $set: {
          completed: input.completed,
          progressValue: input.progressValue,
          ...(input.note !== undefined && { note: input.note }),
        },
      },
      {
        upsert: true,
        new: true,
        setDefaultsOnInsert: true,
      }
    );

    // 3. Recompute Authoritative Streak
    const streakResult = await StreakService.calculateHabitStreak(
      userId,
      habitId,
      undefined,
      habit.streakShieldEnabled
    );

    // 4. Update habit streak
    habit.streak = streakResult.currentStreak;
    await habit.save();

    return {
      log: log.toJSON(),
      streakStats: streakResult,
    };
  }

  /**
   * History of completions for a specific habit
   */
  public static async getHabitCompletions(
    userId: string,
    habitId: string,
    query: HabitCompletionsQuery
  ) {
    const habit = await Habit.findOne({
      _id: new mongoose.Types.ObjectId(habitId),
      userId: new mongoose.Types.ObjectId(userId),
    });

    if (!habit) {
      throw new AppError('Habit not found or access denied', 404, 'NOT_FOUND');
    }

    const filter: Record<string, unknown> = {
      userId: new mongoose.Types.ObjectId(userId),
      habitId: new mongoose.Types.ObjectId(habitId),
    };

    if (query.startDate || query.endDate) {
      filter.date = {};
      if (query.startDate) {
        (filter.date as Record<string, string>).$gte = query.startDate;
      }
      if (query.endDate) {
        (filter.date as Record<string, string>).$lte = query.endDate;
      }
    }

    const page = query.page || 1;
    const limit = query.limit || 30;
    const skip = (page - 1) * limit;

    const [logs, total] = await Promise.all([
      HabitLog.find(filter).sort({ date: -1 }).skip(skip).limit(limit),
      HabitLog.countDocuments(filter),
    ]);

    return {
      completions: logs.map((l: IHabitLog) => l.toJSON()),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit) || 1,
      },
    };
  }

  /**
   * Daily status for all active habits on a given date (defaults to today)
   */
  public static async getTodayCompletions(userId: string, clientDate?: string) {
    const targetDate = clientDate || new Date().toISOString().slice(0, 10);

    const habits = await Habit.find({
      userId: new mongoose.Types.ObjectId(userId),
      isArchived: false,
    }).sort({ createdAt: 1 });

    const logs = await HabitLog.find({
      userId: new mongoose.Types.ObjectId(userId),
      date: targetDate,
    });

    const logMap = new Map<string, IHabitLog>();
    logs.forEach((log) => {
      logMap.set(log.habitId.toString(), log);
    });

    let completedCount = 0;
    const habitsWithStatus = habits.map((h) => {
      const log = logMap.get(h._id.toString());
      const isCompleted = log ? log.completed : false;
      if (isCompleted) completedCount++;

      return {
        habit: h.toJSON(),
        isCompleted,
        progressValue: log ? log.progressValue : 0,
        logId: log ? log._id.toString() : null,
      };
    });

    return {
      date: targetDate,
      totalHabits: habits.length,
      completedCount,
      habits: habitsWithStatus,
    };
  }
}
