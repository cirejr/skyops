import type { Request, Response, NextFunction } from "express";

function requestTime(req: Request, res: Response, next: NextFunction): void {
  req.requestTime = Date.now();
  next();
}

export { requestTime };
