import mongoose from 'mongoose';
import { Goal } from '../models/Goal';
import { Habit } from '../models/Habit';
import { AppError } from '../middleware/errorHandler';
import { CreateGoalInput, UpdateGoalInput, ListGoalsQuery } from '../validators/goal.validator';

export class GoalService {
  public static async createGoal(userId: string, input: CreateGoalInput) {
    const userObjectId = new mongoose.Types.ObjectId(userId);

    // Verify linked habits belong to authenticated user
    if (input.linkedHabitIds && input.linkedHabitIds.length > 0) {
      const habitObjectIds = input.linkedHabitIds.map((id) => new mongoose.Types.ObjectId(id));
      const ownedCount = await Habit.countDocuments({
        _id: { $in: habitObjectIds },
        userId: userObjectId,
      });

      if (ownedCount !== input.linkedHabitIds.length) {
        throw new AppError(
          'One or more linked habits do not exist or belong to another user',
          400,
          'INVALID_LINKED_HABIT'
        );
      }
    }

    const goal = await Goal.create({
      ...input,
      userId: userObjectId,
      currentProgress: 0,
      status: 'active',
      linkedHabitIds: (input.linkedHabitIds || []).map((id) => new mongoose.Types.ObjectId(id)),
    });

    return goal.toJSON();
  }

  public static async listGoals(userId: string, query: ListGoalsQuery) {
    const filter: Record<string, unknown> = {
      userId: new mongoose.Types.ObjectId(userId),
    };

    if (query.status) {
      filter.status = query.status;
    }

    const page = query.page || 1;
    const limit = query.limit || 20;
    const skip = (page - 1) * limit;

    const [goals, total] = await Promise.all([
      Goal.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limit),
      Goal.countDocuments(filter),
    ]);

    return {
      goals: goals.map((g) => g.toJSON()),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit) || 1,
      },
    };
  }

  public static async getGoalById(userId: string, goalId: string) {
    const goal = await Goal.findOne({
      _id: new mongoose.Types.ObjectId(goalId),
      userId: new mongoose.Types.ObjectId(userId),
    });

    if (!goal) {
      throw new AppError('Goal not found or access denied', 404, 'NOT_FOUND');
    }

    return goal.toJSON();
  }

  public static async updateGoal(userId: string, goalId: string, input: UpdateGoalInput) {
    const userObjectId = new mongoose.Types.ObjectId(userId);
    const goal = await Goal.findOne({
      _id: new mongoose.Types.ObjectId(goalId),
      userId: userObjectId,
    });

    if (!goal) {
      throw new AppError('Goal not found or access denied', 404, 'NOT_FOUND');
    }

    // Verify linked habits if updated
    if (input.linkedHabitIds && input.linkedHabitIds.length > 0) {
      const habitObjectIds = input.linkedHabitIds.map((id) => new mongoose.Types.ObjectId(id));
      const ownedCount = await Habit.countDocuments({
        _id: { $in: habitObjectIds },
        userId: userObjectId,
      });

      if (ownedCount !== input.linkedHabitIds.length) {
        throw new AppError(
          'One or more linked habits do not exist or belong to another user',
          400,
          'INVALID_LINKED_HABIT'
        );
      }
      goal.linkedHabitIds = habitObjectIds;
    }

    if (input.title !== undefined) goal.title = input.title;
    if (input.description !== undefined) goal.description = input.description;
    if (input.tier !== undefined) goal.tier = input.tier;
    if (input.targetValue !== undefined) goal.targetValue = input.targetValue;
    if (input.targetUnit !== undefined) goal.targetUnit = input.targetUnit;
    if (input.status !== undefined) goal.status = input.status;
    if (input.xpReward !== undefined) goal.xpReward = input.xpReward;
    if (input.startDate !== undefined) goal.startDate = input.startDate ? new Date(input.startDate) : undefined;
    if (input.endDate !== undefined) goal.endDate = input.endDate ? new Date(input.endDate) : undefined;

    if (input.currentProgress !== undefined) {
      // Validate progress does not exceed target unless auto-completing
      goal.currentProgress = input.currentProgress;
      if (goal.currentProgress >= goal.targetValue && goal.status === 'active') {
        goal.status = 'completed';
      }
    }

    await goal.save();
    return goal.toJSON();
  }

  public static async archiveGoal(userId: string, goalId: string) {
    const goal = await Goal.findOne({
      _id: new mongoose.Types.ObjectId(goalId),
      userId: new mongoose.Types.ObjectId(userId),
    });

    if (!goal) {
      throw new AppError('Goal not found or access denied', 404, 'NOT_FOUND');
    }

    goal.status = 'archived';
    await goal.save();
    return goal.toJSON();
  }
}
