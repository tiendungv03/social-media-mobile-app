import { Router } from "express";
import {
  getUsers,
  searchUsers,
  getProfile,
  updateProfile,
} from "../controllers/users.controller.js";

const router = Router();

router.get("/", getUsers);
router.get("/search", searchUsers);
router.get("/profile/:targetId", getProfile);
router.put("/update/:userId", updateProfile);

export default router;
