import { Router } from "express";
import {
  createPost,
  getFeed,
  getUserPosts,
  likePost,
  deletePost,
} from "../controllers/post.controller.js";
import { authRequired } from "../middleware/auth.middleware.js";

const router = Router();

router.get("/", authRequired, getFeed);
router.get("/user/:userId", authRequired, getUserPosts);
router.post("/", authRequired, createPost);
router.post("/:postId/like", authRequired, likePost);
router.delete("/:postId", authRequired, deletePost);

export default router;
