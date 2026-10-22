import { Router } from 'express';
import { CompletionController } from '../controllers/completion.controller';
import { authenticate } from '../middleware/auth';
import { validateRequest } from '../middleware/validate';
import { todayCompletionsQuerySchema } from '../validators/completion.validator';

const router = Router();

// Require JWT authentication
router.use(authenticate);

// GET /api/v1/completions/today (or ?date=YYYY-MM-DD)
router.get(
  '/today',
  validateRequest(todayCompletionsQuerySchema),
  CompletionController.getTodayCompletions
);

export default router;
