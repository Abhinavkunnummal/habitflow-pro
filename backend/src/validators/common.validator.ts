import { z } from 'zod';

export const OBJECT_ID_REGEX = /^[0-9a-fA-F]{24}$/;

/**
 * Strict calendar date validation (YYYY-MM-DD)
 * Verifies both string format and calendar validity (e.g. rejects 2026-02-30, 2026-04-31)
 */
export function isValidCalendarDate(dateStr: string): boolean {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) return false;

  const [yearStr, monthStr, dayStr] = dateStr.split('-');
  const year = parseInt(yearStr, 10);
  const month = parseInt(monthStr, 10);
  const day = parseInt(dayStr, 10);

  if (month < 1 || month > 12) return false;
  if (day < 1 || day > 31) return false;

  const utcDate = new Date(Date.UTC(year, month - 1, day));
  return (
    utcDate.getUTCFullYear() === year &&
    utcDate.getUTCMonth() + 1 === month &&
    utcDate.getUTCDate() === day
  );
}

export const objectIdSchema = z
  .string()
  .trim()
  .regex(OBJECT_ID_REGEX, 'Invalid ObjectId format. Must be a 24-character hex string');

export const calendarDateSchema = z
  .string()
  .trim()
  .refine(
    (val) => isValidCalendarDate(val),
    'Invalid calendar date. Must be a valid date in YYYY-MM-DD format'
  );

export const paginationQuerySchema = z.object({
  page: z
    .string()
    .optional()
    .transform((val) => (val ? parseInt(val, 10) : 1))
    .pipe(z.number().min(1)),
  limit: z
    .string()
    .optional()
    .transform((val) => (val ? parseInt(val, 10) : 20))
    .pipe(z.number().min(1).max(100)),
});
