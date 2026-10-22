import express, { type Express, type Response, type Request } from "express";

const app: Express = express();
const PORT = process.env.PORT || 3000;

app.get("/", (req: Request, res: Response) => {
  res.send("Hello!");
});

app.listen(PORT);
