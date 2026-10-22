import dotenv from 'dotenv';
import path from 'path';
import { z } from 'zod';

// Load .env from backend root if it exists
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

const envSchema = z.object({
  PORT: z
    .string()
    .default('5000')
    .transform((val) => parseInt(val, 10))
    .pipe(z.number().positive()),
  NODE_ENV: z
    .enum(['development', 'test', 'production'])
    .default('development'),
  MONGODB_URI: z
    .string()
    .default('mongodb://127.0.0.1:27017/habitflow_pro'),
  JWT_SECRET: z
    .string()
    .default('default_jwt_secret_must_change_in_production'),
  JWT_EXPIRES_IN: z
    .string()
    .default('7d'),
  CORS_ORIGIN: z
    .string()
    .default('*'),
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  // eslint-disable-next-line no-console
  console.error('Invalid backend environment variables:', parsed.error.format());
  throw new Error('Environment configuration validation failed');
}

export const env = parsed.data;
