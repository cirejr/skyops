import express, { type Express, type Request, type Response } from "express";

const app: Express = express();
const PORT = process.env.PORT || 3003;
app.use(express.json());

app.get("/", (_req: Request, res: Response) => {
  res.json({ message: "App's live!" });
});

app.listen(PORT, () => {
  console.log("server's started on port : ", PORT);
});
