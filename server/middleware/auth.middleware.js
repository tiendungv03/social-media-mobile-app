import jwt from "jsonwebtoken";
import User from "../models/user.model.js";

export const authRequired = async (req, res, next) => {
  try {
    const header = req.headers.authorization || "";
    const token = header.startsWith("Bearer ") ? header.substring(7) : null;
    if (!token) return res.status(401).json({ message: "No token" });

    const payload = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(payload.id);
    if (!user) return res.status(401).json({ message: "User not found" });

    req.user = user;
    next();
  } catch (e) {
    return res.status(401).json({ message: "Invalid token" });
  }
};
