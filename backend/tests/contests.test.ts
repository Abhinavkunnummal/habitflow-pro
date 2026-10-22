import { describe, it, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';
import jwt from 'jsonwebtoken';
import mongoose from 'mongoose';
import { createApp } from '../src/app';
import { Contest } from '../src/models/Contest';
import { User } from '../src/models/User';
import { env } from '../src/config/env';

describe('Contests & Global Leaderboard Endpoints', () => {
  const app = createApp();

  const userAId = new mongoose.Types.ObjectId().toString();
  const tokenUserA = jwt.sign({ sub: userAId, email: 'userA@test.com' }, env.JWT_SECRET, {
    expiresIn: '1d',
  });

  const contestStore = new Map<string, any>();
  const userStore = new Map<string, any>();

  beforeEach(() => {
    contestStore.clear();
    userStore.clear();

    userStore.set(userAId, {
      _id: new mongoose.Types.ObjectId(userAId),
      id: userAId,
      name: 'Alex Rivera',
      email: 'userA@test.com',
      level: 6,
      xp: 1450,
      currentStreak: 12,
      longestStreak: 24,
    });

    Contest.countDocuments = (async () => contestStore.size) as any;

    Contest.create = (async (data: any) => {
      if (Array.isArray(data)) {
        const results = data.map((d) => {
          const id = new mongoose.Types.ObjectId();
          const doc: any = {
            ...d,
            _id: id,
            id: id.toString(),
            participants: d.participants || [],
            toJSON() {
              return { ...this, id: this._id.toString() };
            },
          };
          contestStore.set(id.toString(), doc);
          return doc;
        });
        return results;
      }

      const id = new mongoose.Types.ObjectId();
      const doc: any = {
        ...data,
        _id: id,
        id: id.toString(),
        participants: data.participants || [],
        toJSON() {
          return { ...this, id: this._id.toString() };
        },
        save: async function () {
          contestStore.set(id.toString(), this);
          return this;
        },
      };
      contestStore.set(id.toString(), doc);
      return doc;
    }) as any;

    Contest.find = (() => {
      const all = Array.from(contestStore.values());
      return {
        sort: () => all,
      } as any;
    }) as any;

    Contest.findById = (async (id: string) => {
      const doc = contestStore.get(id);
      if (!doc) return null;
      return {
        ...doc,
        save: async function () {
          contestStore.set(id, this);
          return this;
        },
      };
    }) as any;

    User.findById = (async (id: string) => {
      return userStore.get(id) || null;
    }) as any;

    User.find = (() => {
      const all = Array.from(userStore.values());
      return {
        select: () => ({
          sort: () => ({
            limit: () => all,
          }),
        }),
      } as any;
    }) as any;
  });

  it('GET /api/v1/contests/leaderboard should return ranked leaderboard', async () => {
    const res = await request(app)
      .get('/api/v1/contests/leaderboard')
      .set('Authorization', `Bearer ${tokenUserA}`);

    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.ok(Array.isArray(res.body.data.leaderboard));
    assert.ok(res.body.data.leaderboard.length >= 1);
  });

  it('GET /api/v1/contests should return seeded contests and list', async () => {
    const res = await request(app)
      .get('/api/v1/contests')
      .set('Authorization', `Bearer ${tokenUserA}`);

    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.ok(Array.isArray(res.body.data));
    assert.ok(res.body.data.length >= 3);
  });

  it('POST /api/v1/contests should create a custom user contest', async () => {
    const res = await request(app)
      .post('/api/v1/contests')
      .set('Authorization', `Bearer ${tokenUserA}`)
      .send({
        title: '7-Day Focus Challenge',
        description: 'Compete for focus minutes this week!',
        category: 'productivity',
        durationDays: 7,
      });

    assert.equal(res.status, 201);
    assert.equal(res.body.success, true);
    assert.equal(res.body.data.title, '7-Day Focus Challenge');
    assert.equal(res.body.data.participants.length, 1);
  });

  it('POST /api/v1/contests/:id/join should allow authenticated user to join', async () => {
    // First list contests to get an ID
    const listRes = await request(app).get('/api/v1/contests');
    const contestId = listRes.body.data[0].id;

    const joinRes = await request(app)
      .post(`/api/v1/contests/${contestId}/join`)
      .set('Authorization', `Bearer ${tokenUserA}`);

    assert.equal(joinRes.status, 200);
    assert.equal(joinRes.body.success, true);
  });
});
