import { Router } from "express";
import { authRequired } from "../middleware/auth.middleware.js";
import {
  createComment,
  getComments,
} from "../controllers/comment.controller.js";

const router = Router();

router.get("/:postId", authRequired, getComments);
router.post("/:postId", authRequired, createComment);

export default router;
