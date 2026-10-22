import { describe, it, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';
import jwt from 'jsonwebtoken';
import mongoose from 'mongoose';
import { createApp } from '../src/app';
import { Habit } from '../src/models/Habit';
import { HabitLog } from '../src/models/HabitLog';
import { Goal } from '../src/models/Goal';
import { env } from '../src/config/env';

describe('Habits, Completions, Goals & Dashboard Endpoints', () => {
  const app = createApp();

  const userAId = new mongoose.Types.ObjectId().toString();
  const userBId = new mongoose.Types.ObjectId().toString();

  const tokenUserA = jwt.sign({ sub: userAId, email: 'userA@test.com' }, env.JWT_SECRET, {
    expiresIn: '1d',
  });
  const tokenUserB = jwt.sign({ sub: userBId, email: 'userB@test.com' }, env.JWT_SECRET, {
    expiresIn: '1d',
  });

  // In-memory mock stores for unit testing without live network dependency
  const habitStore = new Map<string, any>();
  const logStore = new Map<string, any>();
  const goalStore = new Map<string, any>();

  beforeEach(() => {
    habitStore.clear();
    logStore.clear();
    goalStore.clear();

    // Stub Habit.create
    Habit.create = (async (data: any) => {
      const id = new mongoose.Types.ObjectId();
      const habitDoc: any = {
        _id: id,
        id: id.toString(),
        userId: data.userId,
        title: data.title,
        description: data.description,
        category: data.category,
        type: data.type || 'build',
        icon: data.icon || 'bolt',
        colorHex: data.colorHex || '#5D3ADC',
        targetValue: data.targetValue || 1,
        targetUnit: data.targetUnit || 'times',
        streak: 0,
        reminderTime: data.reminderTime,
        streakShieldEnabled: data.streakShieldEnabled || false,
        isArchived: false,
        createdAt: new Date(),
        updatedAt: new Date(),
        save: async function () {
          return this;
        },
        toJSON: function () {
          return {
            id: this.id,
            userId: this.userId.toString(),
            title: this.title,
            description: this.description,
            category: this.category,
            type: this.type,
            icon: this.icon,
            colorHex: this.colorHex,
            targetValue: this.targetValue,
            targetUnit: this.targetUnit,
            streak: this.streak,
            reminderTime: this.reminderTime,
            streakShieldEnabled: this.streakShieldEnabled,
            isArchived: this.isArchived,
            createdAt: this.createdAt,
          };
        },
      };
      habitStore.set(id.toString(), habitDoc);
      return habitDoc;
    }) as any;

    // Stub Habit.find
    Habit.find = ((filter: any) => {
      const list = Array.from(habitStore.values()).filter((h) => {
        if (filter.userId && h.userId.toString() !== filter.userId.toString()) return false;
        if (filter.category && h.category !== filter.category) return false;
        if (filter.type && h.type !== filter.type) return false;
        if (typeof filter.isArchived === 'boolean' && h.isArchived !== filter.isArchived)
          return false;
        return true;
      });

      const chain: any = {
        sort: () => chain,
        skip: () => chain,
        limit: () => chain,
        select: () => chain,
        then: (resolve: any) => Promise.resolve(list).then(resolve),
      };
      return chain;
    }) as any;

    // Stub Habit.findOne
    Habit.findOne = ((filter: any) => {
      const h = Array.from(habitStore.values()).find((item) => {
        if (filter._id && item.id !== filter._id.toString()) return false;
        if (filter.userId && item.userId.toString() !== filter.userId.toString()) return false;
        return true;
      });
      return Promise.resolve(h || null);
    }) as any;

    // Stub Habit.countDocuments
    Habit.countDocuments = ((filter: any) => {
      if (filter._id?.$in) {
        const allowedIds = new Set(filter._id.$in.map((id: any) => id.toString()));
        const count = Array.from(habitStore.values()).filter(
          (h) => allowedIds.has(h.id) && h.userId.toString() === filter.userId.toString()
        ).length;
        return Promise.resolve(count);
      }
      return Promise.resolve(
        Array.from(habitStore.values()).filter(
          (h) => h.userId.toString() === filter.userId.toString()
        ).length
      );
    }) as any;

    // Stub HabitLog.findOneAndUpdate (Idempotent Upsert)
    HabitLog.findOneAndUpdate = (async (filter: any, update: any) => {
      const key = `${filter.userId.toString()}_${filter.habitId.toString()}_${filter.date}`;
      let logDoc = logStore.get(key);

      if (!logDoc) {
        const id = new mongoose.Types.ObjectId();
        logDoc = {
          _id: id,
          id: id.toString(),
          userId: filter.userId,
          habitId: filter.habitId,
          date: filter.date,
          completed: update.$set.completed,
          progressValue: update.$set.progressValue,
          note: update.$set.note,
          createdAt: new Date(),
          updatedAt: new Date(),
          toJSON: function () {
            return {
              id: this.id,
              userId: this.userId.toString(),
              habitId: this.habitId.toString(),
              date: this.date,
              completed: this.completed,
              progressValue: this.progressValue,
              note: this.note,
            };
          },
        };
      } else {
        logDoc.completed = update.$set.completed;
        logDoc.progressValue = update.$set.progressValue;
        if (update.$set.note !== undefined) logDoc.note = update.$set.note;
        logDoc.updatedAt = new Date();
      }

      logStore.set(key, logDoc);
      return logDoc;
    }) as any;

    // Stub HabitLog.find
    HabitLog.find = ((filter: any) => {
      const list = Array.from(logStore.values()).filter((l) => {
        if (filter.userId && l.userId.toString() !== filter.userId.toString()) return false;
        if (filter.habitId && l.habitId.toString() !== filter.habitId.toString()) return false;
        if (filter.date && l.date !== filter.date) return false;
        if (filter.completed !== undefined && l.completed !== filter.completed) return false;
        return true;
      });

      const chain: any = {
        sort: () => chain,
        limit: () => chain,
        skip: () => chain,
        select: () => chain,
        populate: () => chain,
        lean: () => Promise.resolve(list),
        then: (resolve: any) => Promise.resolve(list).then(resolve),
      };
      return chain;
    }) as any;

    HabitLog.countDocuments = ((_filter: any) => {
      return Promise.resolve(logStore.size);
    }) as any;

    // Stub Goal.create
    Goal.create = (async (data: any) => {
      const id = new mongoose.Types.ObjectId();
      const goalDoc: any = {
        _id: id,
        id: id.toString(),
        userId: data.userId,
        title: data.title,
        description: data.description,
        tier: data.tier || 'Silver',
        targetValue: data.targetValue || 30,
        targetUnit: data.targetUnit || 'days',
        currentProgress: data.currentProgress || 0,
        status: data.status || 'active',
        xpReward: data.xpReward || 150,
        linkedHabitIds: data.linkedHabitIds || [],
        createdAt: new Date(),
        updatedAt: new Date(),
        save: async function () {
          return this;
        },
        toJSON: function () {
          return {
            id: this.id,
            userId: this.userId.toString(),
            title: this.title,
            description: this.description,
            tier: this.tier,
            targetValue: this.targetValue,
            targetUnit: this.targetUnit,
            currentProgress: this.currentProgress,
            status: this.status,
            xpReward: this.xpReward,
            linkedHabitIds: this.linkedHabitIds.map((item: any) => item.toString()),
          };
        },
      };
      goalStore.set(id.toString(), goalDoc);
      return goalDoc;
    }) as any;

    Goal.find = ((filter: any) => {
      const list = Array.from(goalStore.values()).filter((g) => {
        if (filter.userId && g.userId.toString() !== filter.userId.toString()) return false;
        if (filter.status && g.status !== filter.status) return false;
        return true;
      });
      const chain: any = {
        sort: () => chain,
        skip: () => chain,
        limit: () => chain,
        then: (resolve: any) => Promise.resolve(list).then(resolve),
      };
      return chain;
    }) as any;

    Goal.findOne = ((filter: any) => {
      const g = Array.from(goalStore.values()).find((item) => {
        if (filter._id && item.id !== filter._id.toString()) return false;
        if (filter.userId && item.userId.toString() !== filter.userId.toString()) return false;
        return true;
      });
      return Promise.resolve(g || null);
    }) as any;

    Goal.countDocuments = ((_filter: any) => {
      return Promise.resolve(goalStore.size);
    }) as any;

    Goal.aggregate = (async (_pipeline: any) => {
      return [
        { _id: 'active', count: Array.from(goalStore.values()).filter((g) => g.status === 'active').length },
        { _id: 'completed', count: Array.from(goalStore.values()).filter((g) => g.status === 'completed').length },
      ];
    }) as any;
  });

  // ==========================================
  // 1. Habit CRUD Tests
  // ==========================================
  it('POST /api/v1/habits should create a habit for authenticated user', async () => {
    const res = await request(app)
      .post('/api/v1/habits')
      .set('Authorization', `Bearer ${tokenUserA}`)
      .send({
        title: 'Morning Hydration',
        category: 'Morning',
        targetValue: 8,
        targetUnit: 'glasses',
        colorHex: '#79FAC2',
      });

    assert.equal(res.status, 201);
    assert.equal(res.body.success, true);
    assert.equal(res.body.data.habit.title, 'Morning Hydration');
    assert.equal(res.body.data.habit.userId, userAId);
  });

  it('POST /api/v1/habits should reject unauthenticated request with 401', async () => {
    const res = await request(app).post('/api/v1/habits').send({
      title: 'Morning Hydration',
      category: 'Morning',
    });

    assert.equal(res.status, 401);
    assert.equal(res.body.error.code, 'UNAUTHORIZED');
  });

  it('POST /api/v1/habits should reject invalid category with 400 VALIDATION_ERROR', async () => {
    const res = await request(app)
      .post('/api/v1/habits')
      .set('Authorization', `Bearer ${tokenUserA}`)
      .send({
        title: 'Workout',
        category: 'NonExistentCategory',
      });

    assert.equal(res.status, 400);
    assert.equal(res.body.error.code, 'VALIDATION_ERROR');
  });

  it('GET /api/v1/habits should isolate data by user (User B cannot see User A habits)', async () => {
    // User A creates a habit
    await request(app)
      .post('/api/v1/habits')
      .set('Authorization', `Bearer ${tokenUserA}`)
      .send({ title: 'User A Secret Routine', category: 'Morning' });

    // User B lists habits
    const resUserB = await request(app)
      .get('/api/v1/habits')
      .set('Authorization', `Bearer ${tokenUserB}`);

    assert.equal(resUserB.status, 200);
    assert.equal(resUserB.body.data.habits.length, 0);

    // User A lists habits
    const resUserA = await request(app)
      .get('/api/v1/habits')
      .set('Authorization', `Bearer ${tokenUserA}`);

    assert.equal(resUserA.status, 200);
    assert.equal(resUserA.body.data.habits.length, 1);
    assert.equal(resUserA.body.data.habits[0].title, 'User A Secret Routine');
  });

  it('GET /api/v1/habits/:id should return 404 if habit belongs to another user', async () => {
    // User A creates habit
    const createRes = await request(app)
      .post('/api/v1/habits')
      .set('Authorization', `Bearer ${tokenUserA}`)
      .send({ title: 'Deep Reading', category: 'Learning & Career' });

    const habitId = createRes.body.data.habit.id;

    // User B attempts to access it
    const res = await request(app)
      .get(`/api/v1/habits/${habitId}`)
      .set('Authorization', `Bearer ${tokenUserB}`);

    assert.equal(res.status, 404);
    assert.equal(res.body.error.code, 'NOT_FOUND');
  });

  it('DELETE /api/v1/habits/:id should soft-archive the habit', async () => {
    const createRes = await request(app)
      .post('/api/v1/habits')
      .set('Authorization', `Bearer ${tokenUserA}`)
      .send({ title: 'Evening Walk', category: 'Evening' });

    const habitId = createRes.body.data.habit.id;

    const delRes = await request(app)
      .delete(`/api/v1/habits/${habitId}`)
      .set('Authorization', `Bearer ${tokenUserA}`);

    assert.equal(delRes.status, 200);
    assert.equal(delRes.body.data.habit.isArchived, true);
  });

  // ==========================================
  // 2. Daily Completion Tests
  // ==========================================
  it('PUT /api/v1/habits/:id/completions/:date should be idempotent and update existing record', async () => {
    const createRes = await request(app)
      .post('/api/v1/habits')
      .set('Authorization', `Bearer ${tokenUserA}`)
      .send({ title: 'Meditate', category: 'Mindfulness' });

    const habitId = createRes.body.data.habit.id;
    const date = '2026-10-22';

    // First completion call: completed = true, progress = 1
    const res1 = await request(app)
      .put(`/api/v1/habits/${habitId}/completions/${date}`)
      .set('Authorization', `Bearer ${tokenUserA}`)
      .send({ completed: true, progressValue: 1, note: 'Morning zen' });

    assert.equal(res1.status, 200);
    assert.equal(res1.body.data.log.completed, true);
    assert.equal(res1.body.data.log.progressValue, 1);
    const initialLogId = res1.body.data.log.id;

    // Retry/second call: completed = true, updated progress = 2
    const res2 = await request(app)
      .put(`/api/v1/habits/${habitId}/completions/${date}`)
      .set('Authorization', `Bearer ${tokenUserA}`)
      .send({ completed: true, progressValue: 2, note: 'Added evening session' });

    assert.equal(res2.status, 200);
    assert.equal(res2.body.data.log.id, initialLogId, 'Must update existing log ID, NOT create duplicate');
    assert.equal(res2.body.data.log.progressValue, 2);
    assert.equal(logStore.size, 1, 'Only 1 record must exist in database for this habit and date');
  });

  it('PUT completion should reject invalid calendar date (e.g. 2026-02-30) with 400', async () => {
    const res = await request(app)
      .put(`/api/v1/habits/${new mongoose.Types.ObjectId()}/completions/2026-02-30`)
      .set('Authorization', `Bearer ${tokenUserA}`)
      .send({ completed: true });

    assert.equal(res.status, 400);
    assert.equal(res.body.error.code, 'VALIDATION_ERROR');
  });

  it('PUT completion should reject negative progressValue with 400', async () => {
    const res = await request(app)
      .put(`/api/v1/habits/${new mongoose.Types.ObjectId()}/completions/2026-10-22`)
      .set('Authorization', `Bearer ${tokenUserA}`)
      .send({ completed: true, progressValue: -5 });

    assert.equal(res.status, 400);
    assert.equal(res.body.error.code, 'VALIDATION_ERROR');
  });

  it('GET /api/v1/completions/today should return status of all active habits', async () => {
    const h1 = await request(app)
      .post('/api/v1/habits')
      .set('Authorization', `Bearer ${tokenUserA}`)
      .send({ title: 'Habit 1', category: 'Morning' });

    const h2 = await request(app)
      .post('/api/v1/habits')
      .set('Authorization', `Bearer ${tokenUserA}`)
      .send({ title: 'Habit 2', category: 'Evening' });

    // Mark habit 1 completed today
    await request(app)
      .put(`/api/v1/habits/${h1.body.data.habit.id}/completions/2026-10-22`)
      .set('Authorization', `Bearer ${tokenUserA}`)
      .send({ completed: true });

    const res = await request(app)
      .get('/api/v1/completions/today?date=2026-10-22')
      .set('Authorization', `Bearer ${tokenUserA}`);

    assert.equal(res.status, 200);
    assert.equal(res.body.data.totalHabits, 2);
    assert.equal(res.body.data.completedCount, 1);
  });

  // ==========================================
  // 3. Goal API Tests
  // ==========================================
  it('POST /api/v1/goals should reject linked habits that belong to another user', async () => {
    // User B creates habit
    const habitB = await request(app)
      .post('/api/v1/habits')
      .set('Authorization', `Bearer ${tokenUserB}`)
      .send({ title: 'User B Habit', category: 'Morning' });

    // User A attempts to link User B's habit to their goal
    const res = await request(app)
      .post('/api/v1/goals')
      .set('Authorization', `Bearer ${tokenUserA}`)
      .send({
        title: 'Unauthorized Link Goal',
        tier: 'Gold',
        targetValue: 50,
        linkedHabitIds: [habitB.body.data.habit.id],
      });

    assert.equal(res.status, 400);
    assert.equal(res.body.error.code, 'INVALID_LINKED_HABIT');
  });

  it('POST /api/v1/goals should create goal when linked habits belong to authenticated user', async () => {
    const habitA = await request(app)
      .post('/api/v1/habits')
      .set('Authorization', `Bearer ${tokenUserA}`)
      .send({ title: 'Own Habit', category: 'Morning' });

    const res = await request(app)
      .post('/api/v1/goals')
      .set('Authorization', `Bearer ${tokenUserA}`)
      .send({
        title: '30 Days of Habit',
        tier: 'Silver',
        targetValue: 30,
        linkedHabitIds: [habitA.body.data.habit.id],
      });

    assert.equal(res.status, 201);
    assert.equal(res.body.success, true);
    assert.equal(res.body.data.goal.title, '30 Days of Habit');
  });

  // ==========================================
  // 4. Dashboard Summary Tests
  // ==========================================
  it('GET /api/v1/dashboard/summary should safely handle user with 0 habits without error', async () => {
    const res = await request(app)
      .get('/api/v1/dashboard/summary')
      .set('Authorization', `Bearer ${tokenUserB}`);

    assert.equal(res.status, 200);
    assert.equal(res.body.data.metrics.activeHabitCount, 0);
    assert.equal(res.body.data.metrics.todayCompletedCount, 0);
    assert.equal(res.body.data.metrics.todayCompletionRate, 0);
  });
});
