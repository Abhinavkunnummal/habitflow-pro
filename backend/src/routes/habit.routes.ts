import { Router } from 'express';
import { HabitController } from '../controllers/habit.controller';
import { CompletionController } from '../controllers/completion.controller';
import { authenticate } from '../middleware/auth';
import { validateRequest } from '../middleware/validate';
import {
  createHabitSchema,
  updateHabitSchema,
  habitIdParamSchema,
  listHabitsQuerySchema,
} from '../validators/habit.validator';
import {
  recordCompletionSchema,
  habitCompletionsSchema,
} from '../validators/completion.validator';

const router = Router();

// Require JWT authentication for all habit routes
router.use(authenticate);

// Habit CRUD
router.post('/', validateRequest(createHabitSchema), HabitController.createHabit);
router.get('/', validateRequest(listHabitsQuerySchema), HabitController.listHabits);
router.get('/:id', validateRequest(habitIdParamSchema), HabitController.getHabitById);
router.patch('/:id', validateRequest(updateHabitSchema), HabitController.updateHabit);
router.delete('/:id', validateRequest(habitIdParamSchema), HabitController.archiveHabit);

// Habit Completions Sub-routes
router.put(
  '/:id/completions/:date',
  validateRequest(recordCompletionSchema),
  CompletionController.recordCompletion
);
router.get(
  '/:id/completions',
  validateRequest(habitCompletionsSchema),
  CompletionController.getHabitCompletions
);

export default router;
