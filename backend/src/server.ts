import { createApp } from './app';
import { env } from './config/env';
import { connectDatabase, disconnectDatabase } from './config/database';
import { logger } from './utils/logger';

async function bootstrap() {
  const app = createApp();

  // Connect to MongoDB Atlas (if configured)
  await connectDatabase();

  const server = app.listen(env.PORT, '0.0.0.0', () => {
    logger.info(`HabitFlow Pro Backend listening on port ${env.PORT} [${env.NODE_ENV}]`);
    logger.info(`Health check available at http://localhost:${env.PORT}/api/v1/health`);
  });

  // Graceful shutdown handling
  const shutdown = async (signal: string) => {
    logger.info(`Received ${signal}. Shutting down gracefully...`);
    server.close(async () => {
      logger.info('HTTP server closed');
      await disconnectDatabase();
      process.exit(0);
    });

    // Force shutdown after 10 seconds if hanging
    setTimeout(() => {
      logger.error('Could not close connections in time, forcefully shutting down');
      process.exit(1);
    }, 10000);
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));
}

bootstrap().catch((error) => {
  logger.error('Fatal error during backend bootstrap:', error);
  process.exit(1);
});
