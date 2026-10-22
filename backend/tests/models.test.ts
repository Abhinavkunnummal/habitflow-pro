import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import mongoose from 'mongoose';
import { User } from '../src/models/User';
import { Habit } from '../src/models/Habit';
import { HabitLog } from '../src/models/HabitLog';
import { Goal } from '../src/models/Goal';
import { createApp } from '../src/app';
import request from 'supertest';

describe('Mongoose Models & Schema Constraints', () => {
  it('User model should fail validation without required fields', () => {
    const user = new User({});
    const error = user.validateSync();
    assert.ok(error);
    assert.ok(error.errors.email);
    assert.ok(error.errors.passwordHash);
    assert.ok(error.errors.name);
  });

  it('User model should reject invalid email format', () => {
    const user = new User({
      email: 'not-an-email',
      passwordHash: 'hashed_password_123',
      name: 'Alex',
    });
    const error = user.validateSync();
    assert.ok(error);
    assert.ok(error.errors.email);
  });

  it('Habit model should fail validation with invalid category', () => {
    const habit = new Habit({
      userId: new mongoose.Types.ObjectId(),
      title: 'Invalid Habit',
      category: 'Gaming', // Not in allowed categories
    });
    const error = habit.validateSync();
    assert.ok(error);
    assert.ok(error.errors.category);
  });

  it('Habit model should fail validation if targetValue is less than 1', () => {
    const habit = new Habit({
      userId: new mongoose.Types.ObjectId(),
      title: 'Daily Water',
      category: 'Morning',
      targetValue: 0,
    });
    const error = habit.validateSync();
    assert.ok(error);
    assert.ok(error.errors.targetValue);
  });

  it('HabitLog schema must define a UNIQUE compound index on (userId, habitId, date)', () => {
    const indexes = HabitLog.schema.indexes();
    const compoundUniqueIndex = indexes.find((idx) => {
      const fields = idx[0];
      const options = idx[1];
      return (
        fields.userId === 1 &&
        fields.habitId === 1 &&
        fields.date === 1 &&
        options?.unique === true
      );
    });

    assert.ok(
      compoundUniqueIndex,
      'HabitLog must have a unique compound index on { userId: 1, habitId: 1, date: 1 } to prevent duplicate completions'
    );
  });

  it('HabitLog model should reject invalid calendar date format', () => {
    const log = new HabitLog({
      userId: new mongoose.Types.ObjectId(),
      habitId: new mongoose.Types.ObjectId(),
      date: '22-10-2026', // Expected YYYY-MM-DD
      completed: true,
    });
    const error = log.validateSync();
    assert.ok(error);
    assert.ok(error.errors.date);
  });

  it('Goal model should reject invalid tier', () => {
    const goal = new Goal({
      userId: new mongoose.Types.ObjectId(),
      title: 'Invalid Goal',
      tier: 'Diamond', // Allowed: Bronze, Silver, Gold
    });
    const error = goal.validateSync();
    assert.ok(error);
    assert.ok(error.errors.tier);
  });
});

describe('System Health & Database Disconnected Handling', () => {
  it('GET /api/v1/health reports database status without failing', async () => {
    const app = createApp();
    const res = await request(app).get('/api/v1/health');

    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.equal(res.body.service, 'HabitFlow Pro Backend');
    assert.ok(res.body.database === 'connected' || res.body.database === 'disconnected');
    assert.equal(typeof res.body.uptimeSeconds, 'number');
  });
});
