import mongoose from 'mongoose';
import { Habit, IHabit } from '../models/Habit';
import { HabitLog } from '../models/HabitLog';
import { AppError } from '../middleware/errorHandler';
import { StreakService } from './streak.service';
import { CreateHabitInput, UpdateHabitInput, ListHabitsQuery } from '../validators/habit.validator';

export class HabitService {
  public static async createHabit(userId: string, input: CreateHabitInput): Promise<IHabit> {
    const habit = await Habit.create({
      ...input,
      userId: new mongoose.Types.ObjectId(userId),
      streak: 0,
      isArchived: false,
    });
    return habit;
  }

  public static async listHabits(userId: string, query: ListHabitsQuery) {
    const filter: Record<string, unknown> = {
      userId: new mongoose.Types.ObjectId(userId),
    };

    if (query.category) {
      filter.category = query.category;
    }
    if (query.type) {
      filter.type = query.type;
    }
    // Default to active habits unless explicitly requesting archived
    if (typeof query.isArchived === 'boolean') {
      filter.isArchived = query.isArchived;
    } else {
      filter.isArchived = false;
    }

    const page = query.page || 1;
    const limit = query.limit || 20;
    const skip = (page - 1) * limit;

    const [habits, total] = await Promise.all([
      Habit.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limit),
      Habit.countDocuments(filter),
    ]);

    return {
      habits: habits.map((h) => h.toJSON()),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit) || 1,
      },
    };
  }

  public static async getHabitById(userId: string, habitId: string) {
    const habit = await Habit.findOne({
      _id: new mongoose.Types.ObjectId(habitId),
      userId: new mongoose.Types.ObjectId(userId),
    });

    if (!habit) {
      throw new AppError('Habit not found or access denied', 404, 'NOT_FOUND');
    }

    // Authoritative streak computation
    const streakResult = await StreakService.calculateHabitStreak(
      userId,
      habitId,
      undefined,
      habit.streakShieldEnabled
    );

    // Synchronize streak on habit document if different
    if (habit.streak !== streakResult.currentStreak) {
      habit.streak = streakResult.currentStreak;
      await habit.save();
    }

    // Get recent 30 completion logs for heatmaps
    const recentLogs = await HabitLog.find({
      userId: new mongoose.Types.ObjectId(userId),
      habitId: new mongoose.Types.ObjectId(habitId),
    })
      .sort({ date: -1 })
      .limit(30);

    return {
      habit: habit.toJSON(),
      streakStats: streakResult,
      recentLogs: recentLogs.map((l) => l.toJSON()),
    };
  }

  public static async updateHabit(userId: string, habitId: string, input: UpdateHabitInput) {
    const habit = await Habit.findOne({
      _id: new mongoose.Types.ObjectId(habitId),
      userId: new mongoose.Types.ObjectId(userId),
    });

    if (!habit) {
      throw new AppError('Habit not found or access denied', 404, 'NOT_FOUND');
    }

    Object.assign(habit, input);
    await habit.save();

    return habit.toJSON();
  }

  public static async archiveHabit(userId: string, habitId: string) {
    const habit = await Habit.findOne({
      _id: new mongoose.Types.ObjectId(habitId),
      userId: new mongoose.Types.ObjectId(userId),
    });

    if (!habit) {
      throw new AppError('Habit not found or access denied', 404, 'NOT_FOUND');
    }

    // Soft deletion: marks isArchived = true
    habit.isArchived = true;
    await habit.save();

    return habit.toJSON();
  }
}
