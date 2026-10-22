import { Router } from 'express';
import { DashboardController } from '../controllers/dashboard.controller';
import { authenticate } from '../middleware/auth';

const router = Router();

// Require JWT authentication for dashboard summary
router.use(authenticate);

router.get('/summary', DashboardController.getSummary);

export default router;
