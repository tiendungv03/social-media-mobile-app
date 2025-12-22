import { Router } from "express";
import authRoutes from "./auth.routes.js";
import commentRoutes from "./comment.routes.js";
import friendRoutes from "./friend.routes.js";
import postRoutes from "./post.routes.js";
import userRoutes from "./users.js"; // 👈 1. THÊM IMPORT NÀY (File users.js ta vừa sửa lúc nãy)


const router = Router();

router.use("/auth", authRoutes);
router.use("/posts", postRoutes);
router.use("/comments", commentRoutes);
router.use("/friends", friendRoutes);
// 👇 2. THÊM DÒNG NÀY ĐỂ MỞ ĐƯỜNG CHO API PROFILE
router.use("/users", userRoutes);
export default router;
