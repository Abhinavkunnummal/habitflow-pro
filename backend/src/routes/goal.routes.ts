import { Router } from 'express';
import { GoalController } from '../controllers/goal.controller';
import { authenticate } from '../middleware/auth';
import { validateRequest } from '../middleware/validate';
import {
  createGoalSchema,
  updateGoalSchema,
  goalIdParamSchema,
  listGoalsQuerySchema,
} from '../validators/goal.validator';

const router = Router();

// Require JWT authentication for all goal routes
router.use(authenticate);

router.post('/', validateRequest(createGoalSchema), GoalController.createGoal);
router.get('/', validateRequest(listGoalsQuerySchema), GoalController.listGoals);
router.get('/:id', validateRequest(goalIdParamSchema), GoalController.getGoalById);
router.patch('/:id', validateRequest(updateGoalSchema), GoalController.updateGoal);
router.delete('/:id', validateRequest(goalIdParamSchema), GoalController.archiveGoal);

export default router;
