import express, { Application, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { env } from './config/env';
import { isDatabaseConnected } from './config/database';
import { errorHandler, AppError } from './middleware/errorHandler';
import { logger } from './utils/logger';
import authRoutes from './routes/auth.routes';
import habitRoutes from './routes/habit.routes';
import completionRoutes from './routes/completion.routes';
import goalRoutes from './routes/goal.routes';
import dashboardRoutes from './routes/dashboard.routes';
import contestRoutes from './routes/contest.routes';

export function createApp(): Application {
  const app = express();

  // 1. Security Headers
  app.use(helmet());

  // 2. Cross-Origin Resource Sharing
  app.use(
    cors({
      origin: env.CORS_ORIGIN === '*' ? true : env.CORS_ORIGIN.split(','),
      credentials: true,
      methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
    })
  );

  // 3. Rate Limiting (100 requests per 15 minutes)
  const limiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: env.NODE_ENV === 'test' ? 10000 : 150,
    standardHeaders: true,
    legacyHeaders: false,
    message: {
      success: false,
      error: {
        code: 'TOO_MANY_REQUESTS',
        message: 'Too many requests from this IP, please try again after 15 minutes',
      },
    },
  });
  app.use('/api/', limiter);

  // 4. Request Body Parsing with Strict Size Limits
  app.use(express.json({ limit: '50kb' }));
  app.use(express.urlencoded({ extended: true, limit: '50kb' }));

  // 5. Request Logger
  app.use((req: Request, _res: Response, next: NextFunction) => {
    logger.debug(`${req.method} ${req.url}`);
    next();
  });

  // 6. Base Root Route
  app.get('/', (_req: Request, res: Response) => {
    res.json({
      name: 'HabitFlow Pro API',
      version: '1.0.0',
      documentation: '/api/v1/health',
    });
  });

  // 7. API Version 1 Routes
  const v1Router = express.Router();

  // Health Endpoint
  v1Router.get('/health', (_req: Request, res: Response) => {
    const dbStatus = isDatabaseConnected() ? 'connected' : 'disconnected';
    res.status(200).json({
      success: true,
      service: 'HabitFlow Pro Backend',
      version: '1.0.0',
      environment: env.NODE_ENV,
      timestamp: new Date().toISOString(),
      uptimeSeconds: Math.floor(process.uptime()),
      database: dbStatus,
    });
  });

  // Auth Routes
  v1Router.use('/auth', authRoutes);

  // Habit CRUD & Completion Sub-routes
  v1Router.use('/habits', habitRoutes);

  // Standalone Daily Completion Routes
  v1Router.use('/completions', completionRoutes);

  // Goal & Milestone Routes
  v1Router.use('/goals', goalRoutes);

  // Dashboard Summary Route
  v1Router.use('/dashboard', dashboardRoutes);

  // Contest & Community Leaderboard Routes
  v1Router.use('/contests', contestRoutes);

  app.use('/api/v1', v1Router);

  // 8. 404 Catch-All Handler
  app.all('*', (req: Request, _res: Response, next: NextFunction) => {
    next(new AppError(`Cannot find ${req.method} ${req.originalUrl} on this server`, 404, 'NOT_FOUND'));
  });

  // 9. Centralized Error Handler
  app.use(errorHandler);

  return app;
}
