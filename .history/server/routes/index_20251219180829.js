import { Router } from "express";
import authRoutes from "./auth.routes.js";
import postRoutes from "./post.routes.js";
import commentRoutes from "./comment.routes.js";
import friendRoutes from "./friend.routes.js";
const router = Router();

router.use("/auth", authRoutes);
router.use("/posts", postRoutes);
router.use("/comments", commentRoutes);

export default router;
