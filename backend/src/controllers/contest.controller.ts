import { Request, Response, NextFunction } from 'express';
import { ContestService } from '../services/contest.service';

export class ContestController {
  public static async getContests(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const contests = await ContestService.getContests(req.user?.id);
      res.status(200).json({
        success: true,
        data: contests,
      });
    } catch (error) {
      next(error);
    }
  }

  public static async getContestById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = req.params.id as string;
      const contest = await ContestService.getContestById(id, req.user?.id);
      res.status(200).json({
        success: true,
        data: contest,
      });
    } catch (error) {
      next(error);
    }
  }

  public static async createContest(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const contest = await ContestService.createContest(req.user!.id, req.body);
      res.status(201).json({
        success: true,
        message: 'Contest created successfully',
        data: contest,
      });
    } catch (error) {
      next(error);
    }
  }

  public static async joinContest(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = req.params.id as string;
      const contest = await ContestService.joinContest(id, req.user!.id);
      res.status(200).json({
        success: true,
        message: 'Joined contest successfully',
        data: contest,
      });
    } catch (error) {
      next(error);
    }
  }

  public static async getLeaderboard(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const leaderboardData = await ContestService.getGlobalLeaderboard(req.user?.id);
      res.status(200).json({
        success: true,
        data: leaderboardData,
      });
    } catch (error) {
      next(error);
    }
  }
}
