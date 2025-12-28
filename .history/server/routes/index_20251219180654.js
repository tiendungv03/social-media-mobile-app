import { Router } from "express";
import authRoutes from "./auth.routes.js";
import postRoutes from "./post.routes.js";
import commentRoutes from "./comment.routes.js";

const router = Router();

router.use("/auth", authRoutes);
router.use("/posts", postRoutes);
router.use("/comments", commentRoutes);

export default router;
// index.js

const friendRoutes = require('./routes/friend.routes'); // Import file vừa sửa

// Server sẽ ghép '/api/friends' + '/request' => '/api/friends/request'
app.use('/api/friends', friendRoutes);