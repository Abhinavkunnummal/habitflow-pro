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
│   ├── middleware/
│   │   ├── errorHandler.ts     # Global error filter & AppError
│   │   └── validate.ts         # Generic Zod validation middleware
│   ├── utils/
│   │   └── logger.ts           # Clean structured logger
│   ├── app.ts                  # Express app configuration & middleware
│   └── server.ts               # Server startup & graceful shutdown
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
