import { Router } from "express";
import {
  register,
  login,
  me,
  checkGoogleEmailAllowed,
  googleLogin,
  forgotPassword,
  resetPassword,
} from "../controllers/auth.controller.js";
import { authRequired } from "../middleware/auth.middleware.js";
import { forgotPasswordLimiter } from "../middleware/rateLimit.middleware.js";

const router = Router();

router.post("/register", register);
router.post("/login", login);
router.get("/me", authRequired, me);
router.get("/google/allowed", checkGoogleEmailAllowed);
router.post("/google", googleLogin);
router.post("/forgot-password", forgotPasswordLimiter, forgotPassword);
router.post("/reset-password", resetPassword);

export default router;
