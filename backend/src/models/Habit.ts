import mongoose, { Schema, Document, Model } from 'mongoose';

export type HabitCategory =
  | 'Morning'
  | 'Health & Fitness'
  | 'Learning & Career'
  | 'Evening'
  | 'Mindfulness';

export type HabitType = 'build' | 'quit';

export interface IHabit extends Document {
  userId: mongoose.Types.ObjectId;
  title: string;
  description?: string;
  category: HabitCategory;
  type: HabitType;
  icon: string;
  colorHex: string;
  targetValue: number;
  targetUnit: string;
  streak: number;
  reminderTime?: string;
  streakShieldEnabled: boolean;
  isArchived: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const HabitSchema = new Schema<IHabit>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Owner userId is required'],
      index: true,
    },
    title: {
      type: String,
      required: [true, 'Habit title is required'],
      trim: true,
      maxlength: [100, 'Title cannot exceed 100 characters'],
    },
    description: {
      type: String,
      trim: true,
      maxlength: [500, 'Description cannot exceed 500 characters'],
    },
    category: {
      type: String,
      required: [true, 'Category is required'],
      enum: {
        values: [
          'Morning',
          'Health & Fitness',
          'Learning & Career',
          'Evening',
          'Mindfulness',
        ],
        message: '{VALUE} is not a valid habit category',
      },
      default: 'Morning',
    },
    type: {
      type: String,
      enum: ['build', 'quit'],
      default: 'build',
    },
    icon: {
      type: String,
      default: 'bolt',
      trim: true,
    },
    colorHex: {
      type: String,
      default: '#5D3ADC',
      trim: true,
    },
    targetValue: {
      type: Number,
      required: true,
      default: 1,
      min: [1, 'Target value must be at least 1'],
    },
    targetUnit: {
      type: String,
      default: 'times',
      trim: true,
    },
    streak: {
      type: Number,
      default: 0,
      min: 0,
    },
    reminderTime: {
      type: String,
      match: [/^([01]\d|2[0-3]):([0-5]\d)$/, 'Reminder time must be in HH:mm format'],
    },
    streakShieldEnabled: {
      type: Boolean,
      default: false,
    },
    isArchived: {
      type: Boolean,
      default: false,
      index: true,
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform: (_doc, ret: Record<string, any>) => {
        ret.id = ret._id ? ret._id.toString() : undefined;
        ret.userId = ret.userId ? ret.userId.toString() : undefined;
        delete ret._id;
        delete ret.__v;
        return ret;
      },
    },
    toObject: {
      transform: (_doc, ret: Record<string, any>) => {
        ret.id = ret._id ? ret._id.toString() : undefined;
        ret.userId = ret.userId ? ret.userId.toString() : undefined;
        delete ret._id;
        delete ret.__v;
        return ret;
      },
    },
  }
);

HabitSchema.index({ userId: 1, isArchived: 1 });
HabitSchema.index({ userId: 1, category: 1 });

export const Habit: Model<IHabit> =
  mongoose.models.Habit || mongoose.model<IHabit>('Habit', HabitSchema);
