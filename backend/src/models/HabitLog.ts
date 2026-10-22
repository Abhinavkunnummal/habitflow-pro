import mongoose, { Schema, Document, Model } from 'mongoose';

export interface IHabitLog extends Document {
  userId: mongoose.Types.ObjectId;
  habitId: mongoose.Types.ObjectId;
  date: string; // Format: YYYY-MM-DD
  completed: boolean;
  progressValue: number;
  note?: string;
  createdAt: Date;
  updatedAt: Date;
}

const HabitLogSchema = new Schema<IHabitLog>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Owner userId is required'],
      index: true,
    },
    habitId: {
      type: Schema.Types.ObjectId,
      ref: 'Habit',
      required: [true, 'Habit reference habitId is required'],
      index: true,
    },
    date: {
      type: String,
      required: [true, 'Calendar date string (YYYY-MM-DD) is required'],
      match: [/^\d{4}-\d{2}-\d{2}$/, 'Date must be formatted as YYYY-MM-DD'],
      trim: true,
    },
    completed: {
      type: Boolean,
      required: true,
      default: true,
    },
    progressValue: {
      type: Number,
      default: 1,
      min: 0,
    },
    note: {
      type: String,
      trim: true,
      maxlength: [300, 'Note cannot exceed 300 characters'],
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform: (_doc, ret: Record<string, any>) => {
        ret.id = ret._id ? ret._id.toString() : undefined;
        ret.userId = ret.userId ? ret.userId.toString() : undefined;
        ret.habitId = ret.habitId ? ret.habitId.toString() : undefined;
        delete ret._id;
        delete ret.__v;
        return ret;
      },
    },
    toObject: {
      transform: (_doc, ret: Record<string, any>) => {
        ret.id = ret._id ? ret._id.toString() : undefined;
        ret.userId = ret.userId ? ret.userId.toString() : undefined;
        ret.habitId = ret.habitId ? ret.habitId.toString() : undefined;
        delete ret._id;
        delete ret.__v;
        return ret;
      },
    },
  }
);

// CRITICAL UNIQUE COMPOUND INDEX:
// Prevents duplicate completion records for the same user, habit, and calendar date
HabitLogSchema.index({ userId: 1, habitId: 1, date: 1 }, { unique: true });

// Compound index for querying a user's habits on a specific date (e.g. today dashboard)
HabitLogSchema.index({ userId: 1, date: 1 });

export const HabitLog: Model<IHabitLog> =
  mongoose.models.HabitLog || mongoose.model<IHabitLog>('HabitLog', HabitLogSchema);
