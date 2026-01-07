import { Router } from "express";
import authRoutes from "./auth.routes.js";
import commentRoutes from "./comment.routes.js";
import friendRoutes from "./friend.routes.js";
import postRoutes from "./post.routes.js";
import userRoutes from "./users.routes.js";

const router = Router();

router.use("/auth", authRoutes);
router.use("/posts", postRoutes);
router.use("/comments", commentRoutes);
router.use("/friends", friendRoutes);
// 👇 2. THÊM DÒNG NÀY ĐỂ MỞ ĐƯỜNG CHO API PROFILE
router.use("/users", userRoutes);
export default router;
