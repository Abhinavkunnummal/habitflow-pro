import { describe, it, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import mongoose from 'mongoose';
import { createApp } from '../src/app';
import { User } from '../src/models/User';
import { env } from '../src/config/env';

describe('Authentication & Protected Route Testing', () => {
  const app = createApp();

  // In-memory mock database store for isolated, blazing fast unit testing
  const mockUserStore = new Map<string, any>();

  beforeEach(() => {
    mockUserStore.clear();

    // Stub User.findOne
    User.findOne = ((query: any) => {
      const email = query?.email;
      const found = mockUserStore.get(email);
      return {
        select: (_fields: string) => Promise.resolve(found || null),
        then: (resolve: any) => Promise.resolve(found || null).then(resolve),
      } as any;
    }) as any;

    // Stub User.create
    User.create = (async (data: any) => {
      const id = new mongoose.Types.ObjectId();
      const userDoc: any = {
        _id: id,
        id: id.toString(),
        email: data.email,
        name: data.name,
        passwordHash: data.passwordHash,
        avatarUrl: data.avatarUrl,
        level: 1,
        xp: 0,
        currentStreak: 0,
        longestStreak: 0,
        createdAt: new Date(),
        updatedAt: new Date(),
        comparePassword: async (candidate: string) => {
          return bcrypt.compare(candidate, data.passwordHash);
        },
        toJSON: function () {
          return {
            id: this.id,
            email: this.email,
            name: this.name,
            avatarUrl: this.avatarUrl,
            level: this.level,
            xp: this.xp,
            currentStreak: this.currentStreak,
            longestStreak: this.longestStreak,
            createdAt: this.createdAt,
          };
        },
      };
      mockUserStore.set(data.email, userDoc);
      return userDoc;
    }) as any;

    // Stub User.findById
    User.findById = ((id: string) => {
      const user = Array.from(mockUserStore.values()).find(
        (u) => u.id === id || u._id?.toString() === id
      );
      return Promise.resolve(user || null);
    }) as any;
  });

  // --- Input Validation Tests ---
  it('should reject registration with invalid email', async () => {
    const res = await request(app)
      .post('/api/v1/auth/register')
      .send({ email: 'bad-email', password: 'password123', name: 'Alex' });

    assert.equal(res.status, 400);
    assert.equal(res.body.success, false);
    assert.equal(res.body.error.code, 'VALIDATION_ERROR');
  });

  it('should reject registration with password shorter than 8 characters', async () => {
    const res = await request(app)
      .post('/api/v1/auth/register')
      .send({ email: 'alex@habitflow.pro', password: 'short', name: 'Alex' });

    assert.equal(res.status, 400);
    assert.equal(res.body.success, false);
    assert.equal(res.body.error.code, 'VALIDATION_ERROR');
  });

  it('should reject registration with missing display name', async () => {
    const res = await request(app)
      .post('/api/v1/auth/register')
      .send({ email: 'alex@habitflow.pro', password: 'secure_password_123' });

    assert.equal(res.status, 400);
    assert.equal(res.body.success, false);
    assert.equal(res.body.error.code, 'VALIDATION_ERROR');
  });

  // --- Registration & Login Flow ---
  it('should register a new user successfully and return JWT and safe profile', async () => {
    const res = await request(app)
      .post('/api/v1/auth/register')
      .send({
        email: 'Alex@HabitFlow.pro', // Mixed case to test normalization
        password: 'secure_password_123',
        name: 'Alex Rivera',
      });

    assert.equal(res.status, 201);
    assert.equal(res.body.success, true);
    assert.ok(res.body.data.token, 'Must return JWT token');
    assert.equal(res.body.data.user.email, 'alex@habitflow.pro');
    assert.equal(res.body.data.user.name, 'Alex Rivera');
    assert.equal(res.body.data.user.level, 1);
    assert.equal(res.body.data.user.xp, 0);
    assert.equal(res.body.data.user.passwordHash, undefined, 'Must NEVER return passwordHash');
  });

  it('should reject duplicate email registration with 409 Conflict', async () => {
    // First registration
    await request(app)
      .post('/api/v1/auth/register')
      .send({
        email: 'alex@habitflow.pro',
        password: 'secure_password_123',
        name: 'Alex Rivera',
      });

    // Duplicate registration attempt
    const res = await request(app)
      .post('/api/v1/auth/register')
      .send({
        email: 'ALEX@habitflow.pro', // Case-insensitive duplicate check
        password: 'different_password_123',
        name: 'Another Alex',
      });

    assert.equal(res.status, 409);
    assert.equal(res.body.success, false);
    assert.equal(res.body.error.code, 'DUPLICATE_EMAIL');
  });

  it('should log in with correct credentials', async () => {
    // Register user first
    await request(app)
      .post('/api/v1/auth/register')
      .send({
        email: 'alex@habitflow.pro',
        password: 'secure_password_123',
        name: 'Alex Rivera',
      });

    // Login
    const res = await request(app)
      .post('/api/v1/auth/login')
      .send({
        email: 'alex@habitflow.pro',
        password: 'secure_password_123',
      });

    assert.equal(res.status, 200);
    assert.equal(res.body.success, true);
    assert.ok(res.body.data.token);
    assert.equal(res.body.data.user.email, 'alex@habitflow.pro');
  });

  it('should reject login with incorrect password with 401 and generic message', async () => {
    await request(app)
      .post('/api/v1/auth/register')
      .send({
        email: 'alex@habitflow.pro',
        password: 'secure_password_123',
        name: 'Alex Rivera',
      });

    const res = await request(app)
      .post('/api/v1/auth/login')
      .send({
        email: 'alex@habitflow.pro',
        password: 'wrong_password_999',
      });

    assert.equal(res.status, 401);
    assert.equal(res.body.success, false);
    assert.equal(res.body.error.code, 'INVALID_CREDENTIALS');
    assert.equal(res.body.error.message, 'Invalid email or password');
  });

  // --- Protected Route & Token Verification ---
  it('GET /api/v1/auth/me should reject request without Authorization header', async () => {
    const res = await request(app).get('/api/v1/auth/me');

    assert.equal(res.status, 401);
    assert.equal(res.body.error.code, 'UNAUTHORIZED');
  });

  it('GET /api/v1/auth/me should reject malformed Authorization header', async () => {
    const res = await request(app)
      .get('/api/v1/auth/me')
      .set('Authorization', 'Basic 123456');

    assert.equal(res.status, 401);
    assert.equal(res.body.error.code, 'MALFORMED_TOKEN');
  });

  it('GET /api/v1/auth/me should reject invalid/forged signature token', async () => {
    const forgedToken = jwt.sign(
      { sub: 'some_id', email: 'forged@test.com' },
      'wrong_secret_key'
    );

    const res = await request(app)
      .get('/api/v1/auth/me')
      .set('Authorization', `Bearer ${forgedToken}`);

    assert.equal(res.status, 401);
    assert.equal(res.body.error.code, 'INVALID_TOKEN');
  });

  it('GET /api/v1/auth/me should reject expired token with TOKEN_EXPIRED', async () => {
    const expiredToken = jwt.sign(
      { sub: 'some_id', email: 'expired@test.com' },
      env.JWT_SECRET,
      { expiresIn: '-1s' } // Expired in the past
    );

    const res = await request(app)
      .get('/api/v1/auth/me')
      .set('Authorization', `Bearer ${expiredToken}`);

    assert.equal(res.status, 401);
    assert.equal(res.body.error.code, 'TOKEN_EXPIRED');
  });

  it('GET /api/v1/auth/me should return authenticated user profile with valid Bearer token', async () => {
    const regRes = await request(app)
      .post('/api/v1/auth/register')
      .send({
        email: 'alex@habitflow.pro',
        password: 'secure_password_123',
        name: 'Alex Rivera',
      });

    const token = regRes.body.data.token;

    const meRes = await request(app)
      .get('/api/v1/auth/me')
      .set('Authorization', `Bearer ${token}`);

    assert.equal(meRes.status, 200);
    assert.equal(meRes.body.success, true);
    assert.equal(meRes.body.data.user.email, 'alex@habitflow.pro');
    assert.equal(meRes.body.data.user.name, 'Alex Rivera');
  });
});
