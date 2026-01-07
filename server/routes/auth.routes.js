import { Router } from "express";
import { register, login, me, forgotPassword,
  resetPassword} from "../controllers/auth.controller.js";

import { authRequired } from "../middleware/auth.middleware.js";
import { forgotPasswordLimiter } from "../middleware/rateLimit.middleware.js";

const router = Router();

console.log("🔥 ROUTES/INDEX.JS ĐÃ ĐƯỢC LOAD");

router.post("/register", register);
router.post("/login", login);
router.get("/me", authRequired, me);
router.post("/forgot-password",forgotPasswordLimiter, forgotPassword);
router.post("/reset-password", resetPassword);

export default router;
