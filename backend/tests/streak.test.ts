import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { StreakService } from '../src/services/streak.service';

describe('Streak Calculation Engine', () => {
  it('should return 0 streak for empty completion history', () => {
    const result = StreakService.computeStreakFromDates([], '2026-10-22');
    assert.equal(result.currentStreak, 0);
    assert.equal(result.longestStreak, 0);
    assert.equal(result.totalCompletions, 0);
  });

  it('should calculate streak of 1 when completed today', () => {
    const result = StreakService.computeStreakFromDates(['2026-10-22'], '2026-10-22');
    assert.equal(result.currentStreak, 1);
    assert.equal(result.longestStreak, 1);
    assert.equal(result.totalCompletions, 1);
  });

  it('should maintain streak if completed yesterday but not yet completed today', () => {
    // Today is 2026-10-22. Completed yesterday (2026-10-21) and day before (2026-10-20)
    const result = StreakService.computeStreakFromDates(
      ['2026-10-20', '2026-10-21'],
      '2026-10-22'
    );
    assert.equal(result.currentStreak, 2);
    assert.equal(result.longestStreak, 2);
  });

  it('should reset current streak to 0 if neither today nor yesterday was completed', () => {
    // Today is 2026-10-22. Last completed was 2026-10-19 (missed 2026-10-20 and 2026-10-21)
    const result = StreakService.computeStreakFromDates(
      ['2026-10-18', '2026-10-19'],
      '2026-10-22'
    );
    assert.equal(result.currentStreak, 0);
    assert.equal(result.longestStreak, 2);
  });

  it('should calculate consecutive 5-day streak correctly across weekend', () => {
    const dates = [
      '2026-10-18',
      '2026-10-19',
      '2026-10-20',
      '2026-10-21',
      '2026-10-22',
    ];
    const result = StreakService.computeStreakFromDates(dates, '2026-10-22');
    assert.equal(result.currentStreak, 5);
    assert.equal(result.longestStreak, 5);
  });

  it('should correctly handle month boundaries (e.g. Oct 31 to Nov 1)', () => {
    const dates = ['2026-10-30', '2026-10-31', '2026-11-01', '2026-11-02'];
    const result = StreakService.computeStreakFromDates(dates, '2026-11-02');
    assert.equal(result.currentStreak, 4);
    assert.equal(result.longestStreak, 4);
  });

  it('should correctly handle leap day boundaries (2024-02-28 -> 2024-02-29 -> 2024-03-01)', () => {
    const dates = ['2024-02-28', '2024-02-29', '2024-03-01'];
    const result = StreakService.computeStreakFromDates(dates, '2024-03-01');
    assert.equal(result.currentStreak, 3);
    assert.equal(result.longestStreak, 3);
  });

  it('should preserve historical longest streak even after a gap resets current streak', () => {
    // 7-day streak in January, gap, then 3-day streak in October
    const historicalDates = [
      '2026-01-01',
      '2026-01-02',
      '2026-01-03',
      '2026-01-04',
      '2026-01-05',
      '2026-01-06',
      '2026-01-07',
      // Big gap
      '2026-10-20',
      '2026-10-21',
      '2026-10-22',
    ];
    const result = StreakService.computeStreakFromDates(historicalDates, '2026-10-22');
    assert.equal(result.currentStreak, 3);
    assert.equal(result.longestStreak, 7);
  });

  it('should absorb a 1-day missed gap when streakShieldEnabled is true', () => {
    // Missed 2026-10-20, but completed 2026-10-18, 2026-10-19, 2026-10-21, 2026-10-22
    const datesWithGap = ['2026-10-18', '2026-10-19', '2026-10-21', '2026-10-22'];

    // Without shield: current streak stops at 2026-10-21 (2 days)
    const withoutShield = StreakService.computeStreakFromDates(
      datesWithGap,
      '2026-10-22',
      false
    );
    assert.equal(withoutShield.currentStreak, 2);

    // With shield: absorbs 2026-10-20 and connects preceding 2 days (4 days)
    const withShield = StreakService.computeStreakFromDates(
      datesWithGap,
      '2026-10-22',
      true
    );
    assert.equal(withShield.currentStreak, 4);
  });
});
