import { Request, Response, NextFunction } from 'express';
import { HabitService } from '../services/habit.service';

export class HabitController {
  public static async createHabit(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const habit = await HabitService.createHabit(req.user!.id, req.body);
      res.status(201).json({
        success: true,
        data: { habit },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async listHabits(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const result = await HabitService.listHabits(req.user!.id, req.query as any);
      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  public static async getHabitById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = req.params.id as string;
      const result = await HabitService.getHabitById(req.user!.id, id);
      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  public static async updateHabit(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = req.params.id as string;
      const habit = await HabitService.updateHabit(req.user!.id, id, req.body);
      res.status(200).json({
        success: true,
        data: { habit },
      });
    } catch (error) {
      next(error);
    }
  }

  public static async archiveHabit(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = req.params.id as string;
      const habit = await HabitService.archiveHabit(req.user!.id, id);
      res.status(200).json({
        success: true,
        data: { habit },
      });
    } catch (error) {
      next(error);
    }
  }
}
