import { Router } from "express";
import { authRequired } from "../middleware/auth.middleware.js";
import {
  createComment,
  getComments,
  toggleLikeComment,
  replyComment
} from "../controllers/comment.controller.js";

const router = Router();

router.get("/:postId", authRequired, getComments);
router.post("/:postId", authRequired, createComment);
router.post("/:commentId/like", authRequired, toggleLikeComment);
router.post("/:commentId/reply", authRequired, replyComment);

export default router;
