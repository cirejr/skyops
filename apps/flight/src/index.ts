import express, { type Express, type Request, type Response } from "express";

const app: Express = express();

const PORT = process.env.PORT || 3001;

app.get("/", (req: Request, res: Response) => {
  res.send("Hello World!");
});

app.listen(PORT);
