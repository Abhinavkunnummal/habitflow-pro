import { z } from 'zod';
import { objectIdSchema, calendarDateSchema, paginationQuerySchema } from './common.validator';

export const recordCompletionSchema = {
  params: z.object({
    id: objectIdSchema,
    date: calendarDateSchema,
  }),
  body: z.object({
    completed: z.boolean({ required_error: 'Completion state boolean is required' }),
    progressValue: z
      .number()
      .min(0, 'Progress value cannot be negative')
      .default(1),
    note: z.string().trim().max(300, 'Note cannot exceed 300 characters').optional(),
  }),
};

export const habitCompletionsSchema = {
  params: z.object({
    id: objectIdSchema,
  }),
  query: paginationQuerySchema.extend({
    startDate: calendarDateSchema.optional(),
    endDate: calendarDateSchema.optional(),
  }),
};

export const todayCompletionsQuerySchema = {
  query: z.object({
    date: calendarDateSchema.optional(),
  }),
};

export type RecordCompletionInput = z.infer<typeof recordCompletionSchema.body>;
export type HabitCompletionsQuery = z.infer<typeof habitCompletionsSchema.query>;
