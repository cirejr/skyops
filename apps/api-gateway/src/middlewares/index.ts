import type { RequestHandler } from "express";

const timeLog: RequestHandler = (req, res, next) => {
  console.log("Time", Date.now());
  next();
};

export { timeLog };
