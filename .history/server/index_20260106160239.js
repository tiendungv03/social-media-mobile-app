import express from "express";
import cors from "cors";
import "dotenv/config.js";
import { connectDB } from "./config/db.js";
import routes from "./routes/index.js"; // File tổng hợp routes

const app = express(); // <--- ĐƯA LÊN ĐÂY

app.use(cors());
app.use(express.json());

// Route test
app.get("/", (_req, res) => {
  res.json({ message: "Mini Instagram API" });
});

// Các routes API
app.use("/api", routes);

const start = async () => {
  await connectDB();
  const port = process.env.PORT || 5000;
  app.listen(port, () => console.log("Server listening on " + port));
};

start();