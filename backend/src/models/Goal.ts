import mongoose, { Schema, Document, Model } from 'mongoose';

export type GoalTier = 'Bronze' | 'Silver' | 'Gold';
export type GoalStatus = 'active' | 'completed' | 'archived';

export interface IGoal extends Document {
  userId: mongoose.Types.ObjectId;
  title: string;
  description?: string;
  tier: GoalTier;
  targetValue: number;
  targetUnit: string;
  currentProgress: number;
  status: GoalStatus;
  xpReward: number;
  linkedHabitIds: mongoose.Types.ObjectId[];
  startDate?: Date;
  endDate?: Date;
  createdAt: Date;
  updatedAt: Date;
}

const GoalSchema = new Schema<IGoal>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Owner userId is required'],
      index: true,
    },
    title: {
      type: String,
      required: [true, 'Goal title is required'],
      trim: true,
      maxlength: [100, 'Title cannot exceed 100 characters'],
    },
    description: {
      type: String,
      trim: true,
      maxlength: [500, 'Description cannot exceed 500 characters'],
    },
    tier: {
      type: String,
      enum: ['Bronze', 'Silver', 'Gold'],
      default: 'Silver',
    },
    targetValue: {
      type: Number,
      required: true,
      default: 30,
      min: [1, 'Target value must be at least 1'],
    },
    targetUnit: {
      type: String,
      default: 'days',
      trim: true,
    },
    currentProgress: {
      type: Number,
      default: 0,
      min: 0,
    },
    status: {
      type: String,
      enum: ['active', 'completed', 'archived'],
      default: 'active',
      index: true,
    },
    xpReward: {
      type: Number,
      default: 150,
      min: 0,
    },
    linkedHabitIds: [
      {
        type: Schema.Types.ObjectId,
        ref: 'Habit',
      },
    ],
    startDate: {
      type: Date,
    },
    endDate: {
      type: Date,
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform: (_doc, ret: Record<string, any>) => {
        ret.id = ret._id ? ret._id.toString() : undefined;
        ret.userId = ret.userId ? ret.userId.toString() : undefined;
        ret.linkedHabitIds = (ret.linkedHabitIds || []).map((id: mongoose.Types.ObjectId) =>
          id.toString()
        );
        delete ret._id;
        delete ret.__v;
        return ret;
      },
    },
    toObject: {
      transform: (_doc, ret: Record<string, any>) => {
        ret.id = ret._id ? ret._id.toString() : undefined;
        ret.userId = ret.userId ? ret.userId.toString() : undefined;
        ret.linkedHabitIds = (ret.linkedHabitIds || []).map((id: mongoose.Types.ObjectId) =>
          id.toString()
        );
        delete ret._id;
        delete ret.__v;
        return ret;
      },
    },
  }
);

GoalSchema.index({ userId: 1, status: 1 });

export const Goal: Model<IGoal> =
  mongoose.models.Goal || mongoose.model<IGoal>('Goal', GoalSchema);
