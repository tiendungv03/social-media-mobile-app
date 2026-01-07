import { Router } from "express";
import {
  register,
  login,
  me,
  checkGoogleEmailAllowed,
  googleLogin,
} from "../controllers/auth.controller.js";
import { authRequired } from "../middleware/auth.middleware.js";

const router = Router();

router.post("/register", register);
router.post("/login", login);
router.get("/me", authRequired, me);
router.get("/google/allowed", checkGoogleEmailAllowed);
router.post("/google", googleLogin);

export default router;
