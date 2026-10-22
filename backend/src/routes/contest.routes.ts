import { Router } from 'express';
import { ContestController } from '../controllers/contest.controller';
import { authenticate, optionalAuthenticate } from '../middleware/auth';

const router = Router();

// Global Community Leaderboard (accessible with optional auth to identify current user rank)
router.get('/leaderboard', optionalAuthenticate, ContestController.getLeaderboard);

// List all active and upcoming contests
router.get('/', optionalAuthenticate, ContestController.getContests);

// Get single contest details and rankings
router.get('/:id', optionalAuthenticate, ContestController.getContestById);

// Create a new contest (requires login)
router.post('/', authenticate, ContestController.createContest);

// Join an existing contest (requires login)
router.post('/:id/join', authenticate, ContestController.joinContest);

export default router;
