import { z } from 'zod';
import { objectIdSchema, paginationQuerySchema } from './common.validator';

const CATEGORIES = [
  'Morning',
  'Health & Fitness',
  'Learning & Career',
  'Evening',
  'Mindfulness',
] as const;

export const createHabitSchema = {
  body: z.object({
    title: z
      .string({ required_error: 'Habit title is required' })
      .trim()
      .min(1, 'Habit title cannot be empty')
      .max(100, 'Habit title cannot exceed 100 characters'),
    description: z.string().trim().max(500).optional(),
    category: z.enum(CATEGORIES, {
      errorMap: () => ({ message: `Category must be one of: ${CATEGORIES.join(', ')}` }),
    }),
    type: z.enum(['build', 'quit']).default('build'),
    icon: z.string().trim().default('bolt'),
    colorHex: z
      .string()
      .trim()
      .regex(/^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/, 'Color must be a valid hex code (e.g. #79FAC2)')
      .default('#5D3ADC'),
    targetValue: z.number().min(1, 'Target value must be at least 1').default(1),
    targetUnit: z.string().trim().default('times'),
    reminderTime: z
      .string()
      .regex(/^([01]\d|2[0-3]):([0-5]\d)$/, 'Reminder time must be in HH:mm format')
      .optional(),
    streakShieldEnabled: z.boolean().default(false),
  }),
};

export const updateHabitSchema = {
  params: z.object({
    id: objectIdSchema,
  }),
  body: z.object({
    title: z.string().trim().min(1).max(100).optional(),
    description: z.string().trim().max(500).optional(),
    category: z.enum(CATEGORIES).optional(),
    type: z.enum(['build', 'quit']).optional(),
    icon: z.string().trim().optional(),
    colorHex: z
      .string()
      .trim()
      .regex(/^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/, 'Color must be a valid hex code')
      .optional(),
    targetValue: z.number().min(1).optional(),
    targetUnit: z.string().trim().optional(),
    reminderTime: z
      .string()
      .regex(/^([01]\d|2[0-3]):([0-5]\d)$/, 'Reminder time must be in HH:mm format')
      .optional(),
    streakShieldEnabled: z.boolean().optional(),
    isArchived: z.boolean().optional(),
  }),
};

export const habitIdParamSchema = {
  params: z.object({
    id: objectIdSchema,
  }),
};

export const listHabitsQuerySchema = {
  query: paginationQuerySchema.extend({
    category: z.enum(CATEGORIES).optional(),
    type: z.enum(['build', 'quit']).optional(),
    isArchived: z
      .string()
      .optional()
      .transform((val) => val === 'true'),
  }),
};

export type CreateHabitInput = z.infer<typeof createHabitSchema.body>;
export type UpdateHabitInput = z.infer<typeof updateHabitSchema.body>;
export type ListHabitsQuery = z.infer<typeof listHabitsQuerySchema.query>;
