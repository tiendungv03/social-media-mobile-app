import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import User  from "../models/user.model.js";

const genToken = (user) => {
  if (!process.env.JWT_SECRET) {
    // ném lỗi rõ ràng nếu chưa set
    throw new Error("JWT_SECRET is missing in .env");
  }
  return jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
    expiresIn: "7d",
  });
};

export const register = async (req, res) => {
  try {
    const { name, username, email, password } = req.body;

    const exist = await User.findOne({
      $or: [{ email }, { username }],
    });
    if (exist) {
      return res.status(400).json({ message: "User exists" });
    }

    const hash = await bcrypt.hash(password, 10);

    const user = await User.create({
      name,
      username,
      email,
      passwordHash: hash,
    });

    const token = genToken(user);

    return res.json({
      token,
      user: {
        id: user._id,
        name: user.name,
        username: user.username,
        email: user.email,
        avatarUrl: user.avatarUrl,
        bio: user.bio,
      },
    });
  } catch (e) {
    console.error("REGISTER_ERROR:", e);
    return res.status(500).json({ message: e.message || "Register error" });
  }
};

export const login = async (req, res) => {
  try {
    const { usernameOrEmail, password } = req.body;

    const user = await User.findOne({
      $or: [{ email: usernameOrEmail }, { username: usernameOrEmail }],
    });

    if (!user) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    const ok = await bcrypt.compare(password, user.passwordHash);
    if (!ok) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    const token = genToken(user);

    return res.json({
      token,
      user: {
        id: user._id,
        name: user.name,
        username: user.username,
        email: user.email,
        avatarUrl: user.avatarUrl,
        bio: user.bio,
      },
    });
  } catch (e) {
    console.error("LOGIN_ERROR:", e); // xem log chi tiết trong terminal
    return res.status(500).json({ message: e.message || "Login error" });
  }
};

export const me = async (req, res) => {
  const u = req.user;
  return res.json({
    user: {
      id: u._id,
      name: u.name,
      username: u.username,
      email: u.email,
      avatarUrl: u.avatarUrl,
      bio: u.bio,
    },
  });
};
