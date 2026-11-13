import express, { type Request, type Response } from "express";

const apiUrl = process.env.FLIGHT_API_URL;

const router = express.Router();

router.get("/", async (req: Request, res: Response) => {
  const result = await fetch(`${apiUrl}`);

  res.json(result);
});

export default router;
