import express, { type Express, type Request, type Response } from "express";

const app: Express = express();

const PORT = process.env.PORT || 3002;

app.get("/", (req: Request, res: Response) => {
  res.send("Hello!");
});

app.listen(PORT);
