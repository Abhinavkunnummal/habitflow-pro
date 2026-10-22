import { Request, Response, NextFunction } from 'express';
import { GoalService } from '../services/goal.service';

export class GoalController {
  public static async createGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const goal = await GoalService.createGoal(req.user!.id, req.body);
      res.status(201).json({
        success: true,
        data: { goal },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async listGoals(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const result = await GoalService.listGoals(req.user!.id, req.query as any);
      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  public static async getGoalById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = req.params.id as string;
      const goal = await GoalService.getGoalById(req.user!.id, id);
      res.status(200).json({
        success: true,
        data: { goal },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async updateGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = req.params.id as string;
      const goal = await GoalService.updateGoal(req.user!.id, id, req.body);
      res.status(200).json({
        success: true,
        data: { goal },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async archiveGoal(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = req.params.id as string;
      const goal = await GoalService.archiveGoal(req.user!.id, id);
      res.status(200).json({
        success: true,
        data: { goal },
      });
    } catch (error) {
      next(error);
    }
  }
}
