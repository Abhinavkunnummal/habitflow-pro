import { z } from 'zod';
import { objectIdSchema, paginationQuerySchema } from './common.validator';

const GOAL_TIERS = ['Bronze', 'Silver', 'Gold'] as const;
const GOAL_STATUSES = ['active', 'completed', 'archived'] as const;

export const createGoalSchema = {
  body: z.object({
    title: z
      .string({ required_error: 'Goal title is required' })
      .trim()
      .min(1, 'Goal title cannot be empty')
      .max(100, 'Goal title cannot exceed 100 characters'),
    description: z.string().trim().max(500).optional(),
    tier: z.enum(GOAL_TIERS).default('Silver'),
    targetValue: z.number().min(1, 'Target value must be at least 1').default(30),
    targetUnit: z.string().trim().default('days'),
    xpReward: z.number().min(0).default(150),
    linkedHabitIds: z.array(objectIdSchema).default([]),
    startDate: z.string().datetime().or(z.string().regex(/^\d{4}-\d{2}-\d{2}$/)).optional(),
    endDate: z.string().datetime().or(z.string().regex(/^\d{4}-\d{2}-\d{2}$/)).optional(),
  }),
};

export const updateGoalSchema = {
  params: z.object({
    id: objectIdSchema,
  }),
  body: z.object({
    title: z.string().trim().min(1).max(100).optional(),
    description: z.string().trim().max(500).optional(),
    tier: z.enum(GOAL_TIERS).optional(),
    targetValue: z.number().min(1).optional(),
    targetUnit: z.string().trim().optional(),
    currentProgress: z.number().min(0).optional(),
    status: z.enum(GOAL_STATUSES).optional(),
    xpReward: z.number().min(0).optional(),
    linkedHabitIds: z.array(objectIdSchema).optional(),
    startDate: z.string().datetime().or(z.string().regex(/^\d{4}-\d{2}-\d{2}$/)).optional(),
    endDate: z.string().datetime().or(z.string().regex(/^\d{4}-\d{2}-\d{2}$/)).optional(),
  }),
};

export const goalIdParamSchema = {
  params: z.object({
    id: objectIdSchema,
  }),
};

export const listGoalsQuerySchema = {
  query: paginationQuerySchema.extend({
    status: z.enum(GOAL_STATUSES).optional(),
  }),
};

export type CreateGoalInput = z.infer<typeof createGoalSchema.body>;
export type UpdateGoalInput = z.infer<typeof updateGoalSchema.body>;
export type ListGoalsQuery = z.infer<typeof listGoalsQuerySchema.query>;
