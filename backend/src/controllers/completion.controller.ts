import { Request, Response, NextFunction } from 'express';
import { CompletionService } from '../services/completion.service';

export class CompletionController {
  public static async recordCompletion(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = req.params.id as string;
      const date = req.params.date as string;
      const result = await CompletionService.recordCompletion(req.user!.id, id, date, req.body);
      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  public static async getHabitCompletions(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const id = req.params.id as string;
      const result = await CompletionService.getHabitCompletions(
        req.user!.id,
        id,
        req.query as any
      );
      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  public static async getTodayCompletions(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const date = req.query.date as string | undefined;
      const result = await CompletionService.getTodayCompletions(req.user!.id, date);
      res.status(200).json({
        success: true,
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }
}
