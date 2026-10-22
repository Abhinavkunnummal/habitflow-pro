import mongoose, { Schema, Document, Model } from 'mongoose';

export interface IContestParticipant {
  userId: mongoose.Types.ObjectId;
  name: string;
  avatarUrl?: string;
  score: number;
  streak: number;
  joinedAt: Date;
}

export interface IContest extends Document {
  title: string;
  description: string;
  category: 'all' | 'wellness' | 'productivity' | 'fitness' | 'mindfulness';
  bannerGradient: string;
  rewardBadge: string;
  xpReward: number;
  targetDays: number;
  startDate: Date;
  endDate: Date;
  createdBy?: mongoose.Types.ObjectId;
  isOfficial: boolean;
  participants: IContestParticipant[];
  createdAt: Date;
  updatedAt: Date;
}

const ContestParticipantSchema = new Schema<IContestParticipant>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    name: {
      type: String,
      required: true,
      trim: true,
    },
    avatarUrl: {
      type: String,
      trim: true,
    },
    score: {
      type: Number,
      default: 0,
      min: 0,
    },
    streak: {
      type: Number,
      default: 0,
      min: 0,
    },
    joinedAt: {
      type: Date,
      default: Date.now,
    },
  },
  { _id: false }
);

const ContestSchema = new Schema<IContest>(
  {
    title: {
      type: String,
      required: [true, 'Contest title is required'],
      trim: true,
      maxlength: [100, 'Title cannot exceed 100 characters'],
    },
    description: {
      type: String,
      required: [true, 'Contest description is required'],
      trim: true,
      maxlength: [500, 'Description cannot exceed 500 characters'],
    },
    category: {
      type: String,
      enum: ['all', 'wellness', 'productivity', 'fitness', 'mindfulness'],
      default: 'all',
      index: true,
    },
    bannerGradient: {
      type: String,
      default: 'violet',
    },
    rewardBadge: {
      type: String,
      default: '🥇 Consistency Champion',
      trim: true,
    },
    xpReward: {
      type: Number,
      default: 500,
      min: 0,
    },
    targetDays: {
      type: Number,
      default: 30,
      min: 1,
    },
    startDate: {
      type: Date,
      required: true,
      default: Date.now,
    },
    endDate: {
      type: Date,
      required: true,
    },
    createdBy: {
      type: Schema.Types.ObjectId,
      ref: 'User',
    },
    isOfficial: {
      type: Boolean,
      default: false,
    },
    participants: [ContestParticipantSchema],
  },
  {
    timestamps: true,
    toJSON: {
      transform: (_doc, ret: Record<string, any>) => {
        ret.id = ret._id ? ret._id.toString() : undefined;
        ret.createdBy = ret.createdBy ? ret.createdBy.toString() : undefined;
        if (Array.isArray(ret.participants)) {
          ret.participants = ret.participants.map((p: any) => ({
            ...p,
            userId: p.userId ? p.userId.toString() : undefined,
          }));
        }
        delete ret._id;
        delete ret.__v;
        return ret;
      },
    },
    toObject: {
      transform: (_doc, ret: Record<string, any>) => {
        ret.id = ret._id ? ret._id.toString() : undefined;
        ret.createdBy = ret.createdBy ? ret.createdBy.toString() : undefined;
        delete ret._id;
        delete ret.__v;
        return ret;
      },
    },
  }
);

ContestSchema.index({ endDate: 1, isOfficial: 1 });

export const Contest: Model<IContest> =
  mongoose.models.Contest || mongoose.model<IContest>('Contest', ContestSchema);
