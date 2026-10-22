import { HabitLog } from '../models/HabitLog';
import mongoose from 'mongoose';

export interface StreakResult {
  currentStreak: number;
  longestStreak: number;
  totalCompletions: number;
}

export class StreakService {
  /**
   * Helper to compute previous calendar day string (YYYY-MM-DD)
   */
  public static getPreviousDay(dateStr: string): string {
    const [y, m, d] = dateStr.split('-').map((v) => parseInt(v, 10));
    const date = new Date(Date.UTC(y, m - 1, d));
    date.setUTCDate(date.getUTCDate() - 1);
    return date.toISOString().slice(0, 10);
  }

  /**
   * Helper to compute next calendar day string (YYYY-MM-DD)
   */
  public static getNextDay(dateStr: string): string {
    const [y, m, d] = dateStr.split('-').map((v) => parseInt(v, 10));
    const date = new Date(Date.UTC(y, m - 1, d));
    date.setUTCDate(date.getUTCDate() + 1);
    return date.toISOString().slice(0, 10);
  }

  /**
   * Pure streak calculation from an array of completed date strings
   * @param completedDates Array of unique YYYY-MM-DD date strings where habit was marked complete
   * @param referenceDate The anchor date (usually today in user's timezone, YYYY-MM-DD)
   * @param streakShieldEnabled Whether a 1-day missed grace is absorbed
   */
  public static computeStreakFromDates(
    completedDates: string[],
    referenceDate: string,
    streakShieldEnabled = false
  ): StreakResult {
    if (completedDates.length === 0) {
      return { currentStreak: 0, longestStreak: 0, totalCompletions: 0 };
    }

    const dateSet = new Set(completedDates);
    const sortedDates = Array.from(dateSet).sort(); // Ascending

    // 1. Calculate Longest Streak Across History
    let longestStreak = 0;
    let runningStreak = 0;
    let prevDate: string | null = null;

    for (const d of sortedDates) {
      if (!prevDate) {
        runningStreak = 1;
      } else {
        const expectedNext = this.getNextDay(prevDate);
        if (d === expectedNext) {
          runningStreak += 1;
        } else {
          runningStreak = 1;
        }
      }
      if (runningStreak > longestStreak) {
        longestStreak = runningStreak;
      }
      prevDate = d;
    }

    // 2. Calculate Current Streak
    let currentStreak = 0;
    let checkDate = referenceDate;
    const yesterday = this.getPreviousDay(referenceDate);

    // If today is completed, start from today
    // If today is NOT completed, check if yesterday was completed (streak active for today)
    if (dateSet.has(checkDate)) {
      // Completed today
      currentStreak += 1;
      checkDate = this.getPreviousDay(checkDate);
    } else if (dateSet.has(yesterday)) {
      // Today is still ongoing; yesterday was completed
      currentStreak += 1;
      checkDate = this.getPreviousDay(yesterday);
    } else {
      // Neither today nor yesterday completed
      return { currentStreak: 0, longestStreak, totalCompletions: sortedDates.length };
    }

    // Count consecutive completed preceding days
    let shieldUsed = false;
    while (true) {
      if (dateSet.has(checkDate)) {
        currentStreak += 1;
        checkDate = this.getPreviousDay(checkDate);
      } else if (streakShieldEnabled && !shieldUsed) {
        // Absorb 1 missed day with Streak Shield
        shieldUsed = true;
        checkDate = this.getPreviousDay(checkDate);
        // Next day must be completed for shield to connect
        if (!dateSet.has(checkDate)) {
          break;
        }
      } else {
        break;
      }
    }

    return {
      currentStreak,
      longestStreak: Math.max(longestStreak, currentStreak),
      totalCompletions: sortedDates.length,
    };
  }

  /**
   * Authoritative streak computation from MongoDB HabitLog records for a given habit
   */
  public static async calculateHabitStreak(
    userId: string | mongoose.Types.ObjectId,
    habitId: string | mongoose.Types.ObjectId,
    referenceDate = new Date().toISOString().slice(0, 10),
    streakShieldEnabled = false
  ): Promise<StreakResult> {
    const logs = await HabitLog.find({
      userId,
      habitId,
      completed: true,
      progressValue: { $gte: 1 },
    }).select('date');

    const completedDates = logs.map((log) => log.date);
    return this.computeStreakFromDates(completedDates, referenceDate, streakShieldEnabled);
  }
}
