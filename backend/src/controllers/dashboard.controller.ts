import { Request, Response, NextFunction } from 'express';
import { DashboardService } from '../services/dashboard.service';

export class DashboardController {
  public static async getSummary(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const clientDate = req.query.date as string | undefined;
      const summary = await DashboardService.getSummary(req.user!.id, clientDate);
      res.status(200).json({
        success: true,
        data: summary,
      });
    } catch (error) {
      next(error);
    }
  }
}
