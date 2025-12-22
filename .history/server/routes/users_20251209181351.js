import express from "express";
import * as user from "../controllers/users.js";

const userRoutes = express.Router();
// Example route for users
//localhost:5000/api/users
userRoutes.get("/", user.getUsers);
userRoutes.post("/register", user.registerUser);
userRoutes.post("/login", user.loginUser);

export default userRoutes;
