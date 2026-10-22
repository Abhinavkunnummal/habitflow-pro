# HabitFlow Pro Backend API

A production-ready REST API built with Node.js, Express, TypeScript, and MongoDB Atlas to power the HabitFlow Pro habit tracking application.

---

## 1. Features & Architecture

- **TypeScript Strict Mode**: Fully typed request/response pipelines and database models.
- **Security**: Hardened with Helmet HTTP headers, CORS policies, rate limiting, and 50kb request payload bounds.
- **Validation**: Schema-driven request validation with **Zod** for body, params, and queries.
- **Error Handling**: Centralized error middleware returning normalized JSON responses with standard error codes.
- **Database**: **MongoDB Atlas** cloud persistence with Mongoose schemas and compound indexes.
- **Authentication**: JWT token verification and bcrypt-compatible password hashing.
- **Zero-SDK PC Constraint**: Consumes ~40MB of RAM when running; does not require local MongoDB or Gradle daemons.

---

## 2. Directory Structure

```
backend/
├── src/
│   ├── config/
│   │   ├── env.ts              # Zod-validated environment config
│   │   └── database.ts         # Mongoose connection & lifecycle manager
│   ├── controllers/
│   │   ├── auth.controller.ts        # Register, login, me endpoints
│   │   ├── habit.controller.ts       # Habit CRUD & history
│   │   ├── completion.controller.ts  # Idempotent logs & today query
│   │   ├── goal.controller.ts        # Goals with linked habits
│   │   └── dashboard.controller.ts   # Unified dashboard summary
│   ├── middleware/
│   │   ├── auth.ts             # JWT Bearer verification
│   │   ├── errorHandler.ts     # Global error filter & AppError
│   │   └── validate.ts         # Generic Zod validation middleware
│   ├── models/
│   │   ├── user.model.ts       # User schema & bcrypt password hashing
│   │   ├── habit.model.ts      # Habit schema with category/streaks
│   │   ├── habitLog.model.ts   # Unique compound index completion logs
│   │   └── goal.model.ts       # Milestone goals & linked habit references
│   ├── routes/
│   │   ├── auth.routes.ts
│   │   ├── habit.routes.ts
│   │   ├── completion.routes.ts
│   │   ├── goal.routes.ts
│   │   └── dashboard.routes.ts
│   ├── services/
│   │   ├── habit.service.ts
│   │   ├── completion.service.ts
│   │   ├── goal.service.ts
│   │   ├── dashboard.service.ts
│   │   └── streak.service.ts   # Authoritative streak calculation engine
│   ├── validators/
│   │   ├── auth.validator.ts
│   │   ├── habit.validator.ts
│   │   ├── completion.validator.ts
│   │   └── goal.validator.ts
│   ├── utils/
│   │   └── logger.ts           # Clean structured logger
│   ├── app.ts                  # Express app configuration & middleware
│   └── server.ts               # Server startup & graceful shutdown
├── tests/
│   ├── auth.test.ts
│   ├── models.test.ts
│   ├── streak.test.ts
│   ├── habits_and_completions.test.ts
│   └── health.test.ts
├── .env.example                # Template with placeholder variables
├── package.json
└── tsconfig.json
```

---

## 3. Environment Configuration

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
2. Update the variables in `.env`:
   - `PORT`: Server port (default: `5000`).
   - `MONGODB_URI`: Your MongoDB Atlas cluster connection string.
   - `JWT_SECRET`: A secure random string (minimum 32 characters in production).
   - `CORS_ORIGIN`: Allowed origins (e.g. `*` for local dev/tunnels, or your production frontend domain).

> **Important**: Never commit your `.env` file to source control. The root `.gitignore` is pre-configured to exclude all `.env*` files.

---

## 4. Development & Build Scripts

```bash
# Install dependencies
npm install

# Start development server with live reload (tsx watch)
npm run dev

# Type-check without building
npm run lint

# Compile TypeScript to JavaScript in /dist
npm run build

# Start production server from compiled /dist
npm run start
```

---

## 5. MongoDB Atlas Setup Guide

To create a free cloud database cluster (M0 sandbox):
1. Sign in to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas).
2. Create a free shared cluster (`M0` Sandbox — 512MB storage, free forever).
3. Under **Security > Database Access**, add a database user with read/write permissions.
4. Under **Security > Network Access**, click **Add IP Address** and choose **Allow Access From Anywhere** (`0.0.0.0/0`) so both your local PC and cloud hosting platforms can connect.
5. In your cluster dashboard, click **Connect > Drivers**, copy the connection string, and paste it into `MONGODB_URI` in `.env`:
   ```
   mongodb+srv://<username>:<password>@cluster0.example.mongodb.net/habitflow_pro?retryWrites=true&w=majority
   ```

---

## 6. Cloud Deployment Guide (e.g., Render / Railway)

1. **Render.com**:
   - Create a new **Web Service** connected to your GitHub repository.
   - Root Directory: `backend`
   - Build Command: `npm install && npm run build`
   - Start Command: `npm run start`
   - Add environment variables: `MONGODB_URI`, `JWT_SECRET`, `NODE_ENV=production`.
2. **Railway.app**:
   - Deploy from repo, set root directory to `backend`, add environment variables.

---

## 7. REST API Reference

All requests and responses use JSON (`Content-Type: application/json`).
All protected endpoints require the HTTP header:
```
Authorization: Bearer <jwt-token>
```

### 7.1 Health Check
- **`GET /api/v1/health`** (Public)
  - Returns service status, uptime, environment, and MongoDB connection status.
  - Returns `503` if MongoDB is down, `200` when connected.

### 7.2 Authentication (`/api/v1/auth`)
- **`POST /register`** (Public)
  - Creates account, hashes password with bcrypt, and returns JWT token.
  - Body: `{ "email": "user@example.com", "password": "securePassword123", "displayName": "Alex Rivera" }`
- **`POST /login`** (Public)
  - Verifies credentials and returns JWT token.
  - Body: `{ "email": "user@example.com", "password": "securePassword123" }`
- **`GET /me`** (Protected)
  - Returns the authenticated user's profile.

### 7.3 Habits (`/api/v1/habits`)
- **`POST /`** (Protected)
  - Creates a new habit owned by the authenticated user.
  - Body:
    ```json
    {
      "name": "Morning Meditation",
      "description": "15 minutes mindfulness",
      "category": "Mindfulness",
      "schedule": "daily",
      "targetValue": 15,
      "targetUnit": "minutes",
      "colorHex": "#5D3ADC",
      "iconName": "self_improvement"
    }
    ```
- **`GET /`** (Protected)
  - Lists all active habits for the user, with pagination & category filtering.
  - Query params: `category`, `isArchived` (default `false`), `page`, `limit`.
- **`GET /:id`** (Protected)
  - Retrieves a single habit with its 30 most recent completion logs.
- **`PATCH /:id`** (Protected)
  - Updates habit settings (name, category, targetValue, targetUnit, colorHex, iconName, schedule, customDays, streakShieldEnabled).
- **`DELETE /:id`** (Protected)
  - Safely soft-deletes a habit by setting `isArchived: true`.

### 7.4 Completions & Daily Tracking (`/api/v1/completions`)
- **`PUT /api/v1/habits/:id/completions/:date`** (Protected, Idempotent)
  - Logs or updates habit completion for a specific calendar date (`YYYY-MM-DD`).
  - Protected by a unique compound MongoDB index `{ userId: 1, habitId: 1, date: 1 }`.
  - Automatically recalculates and updates `currentStreak` and `longestStreak` on the habit.
  - Body:
    ```json
    {
      "completed": true,
      "progressValue": 15,
      "notes": "Felt very calm"
    }
    ```
- **`GET /api/v1/habits/:id/completions`** (Protected)
  - Queries completion history between `startDate` and `endDate` (defaults to last 30 days).
- **`GET /api/v1/completions/today`** (Protected)
  - Returns today's completion status for all of the user's active habits in a single call.
  - Query param: `date` (optional, defaults to current UTC day).

### 7.5 Goals (`/api/v1/goals`)
- **`POST /`** (Protected)
  - Creates a milestone goal linked to owned habits.
  - Body:
    ```json
    {
      "title": "Meditate for 30 consecutive days",
      "tier": "Gold",
      "targetDays": 30,
      "linkedHabitIds": ["<habitId>"]
    }
    ```
- **`GET /`** (Protected)
  - Lists all goals for the user.
- **`GET /:id`** (Protected)
  - Retrieves a specific goal with linked habit details.
- **`PATCH /:id`** (Protected)
  - Updates goal details or increments `currentProgress`. Automatically sets `isCompleted: true` when target is reached.
- **`DELETE /:id`** (Protected)
  - Deletes a goal.

### 7.6 Dashboard Summary (`/api/v1/dashboard/summary`)
- **`GET /`** (Protected)
  - Returns unified dashboard metrics in a single round-trip:
    ```json
    {
      "metrics": {
        "activeHabitsCount": 3,
        "completedTodayCount": 2,
        "completionRateToday": 66.7,
        "bestStreak": 14,
        "activeGoalsCount": 1,
        "completedGoalsCount": 0
      },
      "habitsToday": [ ... ],
      "recentActivity": [ ... ]
    }
    ```

---

## 8. Streak Engine Logic

The streak engine (`src/services/streak.service.ts`) runs authoritatively on the backend:
1. **Idempotent Logs**: Stored with `{ userId, habitId, date }` unique compound index. Retries never duplicate streaks.
2. **Calendar Boundary Safety**: Dates are verified with UTC year/month/day calendar logic (rejects invalid dates like `2026-02-30`).
3. **Grace Period**: If completed today, today is included in the streak. If not yet completed today, but completed yesterday, yesterday's streak is preserved (the day remains open).
4. **Historical High Watermark**: `longestStreak` is preserved even after a streak resets to 0.
5. **Streak Shield**: If `streakShieldEnabled: true`, a 1-day missed gap is absorbed once without breaking the streak.

