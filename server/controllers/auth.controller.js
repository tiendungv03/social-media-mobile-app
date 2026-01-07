import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import User from "../models/user.model.js";
import admin from "../config/firebaseAdmin.js";

const genToken = (user) => {
  if (!process.env.JWT_SECRET) throw new Error("JWT_SECRET is missing in .env");
  return jwt.sign({ id: user._id }, process.env.JWT_SECRET, {
    expiresIn: "7d",
  });
};

// ✅ POST /api/auth/register
export const register = async (req, res) => {
  try {
    // hỗ trợ cả 2 kiểu: password hoặc passwordHash (đỡ sửa Flutter gấp)
    const { name, username, email, password, passwordHash } = req.body;
    const plainPassword = password ?? passwordHash;

    const emailKey = (email || "").trim().toLowerCase();

    const exist = await User.findOne({
      $or: [{ email: emailKey }, { username }],
    });
    if (exist) return res.status(400).json({ message: "User exists" });

    if (!plainPassword || plainPassword.length < 6) {
      return res.status(400).json({ message: "Mật khẩu tối thiểu 6 ký tự" });
    }

    const hash = await bcrypt.hash(plainPassword, 10);

    const user = await User.create({
      name,
      username,
      email: emailKey,
      passwordHash: hash,
    });

    // ✅ whitelist email lên Firestore để Google login so sánh
    if (emailKey) {
      try {
        await admin
          .firestore()
          .collection("pre_registered_emails")
          .doc(emailKey)
          .set(
            {
              email: emailKey,
              mongoUserId: user._id.toString(),
              username: user.username,
              name: user.name,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            },
            { merge: true }
          );
      } catch (e) {
        console.error("FIRESTORE WRITE ERROR >>>", e?.message || e);
      }
    }

    const token = genToken(user);

    return res.json({
      token,
      user: {
        id: user._id,
        _id: user._id,
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

// ✅ POST /api/auth/login
export const login = async (req, res) => {
  try {
    // hỗ trợ nhiều kiểu body (đỡ sửa Flutter)
    const { usernameOrEmail, username, password, passwordHash } = req.body;

    const key = (usernameOrEmail ?? username ?? "").trim().toLowerCase();
    const plainPassword = password ?? passwordHash;

    const user = await User.findOne({
      $or: [{ email: key }, { username: key }],
    });

    if (!user) return res.status(400).json({ message: "Invalid credentials" });

    const ok = await bcrypt.compare(
      plainPassword || "",
      user.passwordHash || ""
    );
    if (!ok) return res.status(400).json({ message: "Invalid credentials" });

    const token = genToken(user);

    return res.json({
      token,
      user: {
        id: user._id,
        _id: user._id,
        name: user.name,
        username: user.username,
        email: user.email,
        avatarUrl: user.avatarUrl,
        bio: user.bio,
      },
    });
  } catch (e) {
    console.error("LOGIN_ERROR:", e);
    return res.status(500).json({ message: e.message || "Login error" });
  }
};

// ✅ GET /api/auth/google/allowed?email=...
export const checkGoogleEmailAllowed = async (req, res) => {
  try {
    const email = (req.query.email || "").trim().toLowerCase();
    if (!email)
      return res.status(400).json({ allowed: false, message: "Missing email" });

    const doc = await admin
      .firestore()
      .collection("pre_registered_emails")
      .doc(email)
      .get();
    return res.json({ allowed: doc.exists });
  } catch (e) {
    console.error("CHECK EMAIL ERROR:", e);
    return res
      .status(500)
      .json({ allowed: false, message: "Something went wrong" });
  }
};

// ✅ POST /api/auth/google  (body: { idToken })
export const googleLogin = async (req, res) => {
  try {
    const { idToken } = req.body;
    if (!idToken) return res.status(400).json({ message: "Missing idToken" });

    const decoded = await admin.auth().verifyIdToken(idToken);
    const email = (decoded.email || "").trim().toLowerCase();
    const picture = decoded.picture;

    if (!email)
      return res.status(400).json({ message: "Google account has no email" });

    // whitelist check
    const allowDoc = await admin
      .firestore()
      .collection("pre_registered_emails")
      .doc(email)
      .get();
    if (!allowDoc.exists) {
      return res.status(403).json({
        message: "Email Google này chưa được đăng ký trong hệ thống.",
      });
    }

    // user mongo
    const user = await User.findOne({ email });
    if (!user)
      return res
        .status(404)
        .json({ message: "User not found in Mongo. Hãy đăng ký trước." });

    if (!user.avatarUrl && picture) {
      user.avatarUrl = picture;
      await user.save();
    }

    const token = genToken(user);

    return res.json({
      token,
      user: {
        id: user._id,
        _id: user._id,
        name: user.name,
        username: user.username,
        email: user.email,
        avatarUrl: user.avatarUrl,
        bio: user.bio,
      },
    });
  } catch (e) {
    console.error("GOOGLE_LOGIN_ERROR:", e);
    return res.status(401).json({ message: "Invalid Google token" });
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
