import cors from "cors";
import "dotenv/config.js";
import express from "express";
import { connectDB } from "./config/db.js";
import routes from "./routes/index.js";



app.use("/api/users", usersRoutes); // Đường dẫn gốc là /api/users
app.use(cors());
app.use(express.json());
const app = express();

app.get("/", (_req, res) => {
  res.json({ message: "Mini Instagram API" });
});

app.use("/api", routes);

const start = async () => {
  await connectDB();
  const port = process.env.PORT || 5000;
  app.listen(port, () => console.log("Server listening on " + port));
};

start();
