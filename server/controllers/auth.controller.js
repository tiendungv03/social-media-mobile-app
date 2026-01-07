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

export const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ message: "Email is required" });
    }

    const user = await User.findOne({ email });

    // Không leak email tồn tại hay không
    if (!user) {
      return res.json({
        message: "Nếu email tồn tại, link reset sẽ được gửi",
      });
    }

    // Tạo token gốc
    const resetToken = crypto.randomBytes(32).toString("hex");

    // Hash token lưu DB
    user.resetPasswordToken = crypto
      .createHash("sha256")
      .update(resetToken)
      .digest("hex");

    user.resetPasswordExpire = Date.now() + 15 * 60 * 1000; // 15 phút

    await user.save();

    const resetUrl = `${process.env.CLIENT_URL}/reset-password?token=${resetToken}`;

    await sendEmail({
      to: user.email,
      subject: "Reset mật khẩu",
      html: `
        <p>Bạn đã yêu cầu đặt lại mật khẩu.</p>
        <p>Link có hiệu lực 15 phút:</p>
        <a href="${resetUrl}">${resetUrl}</a>
      `,
    });

    return res.json({ message: "Reset email sent" });
  } catch (e) {
    console.error("FORGOT PASSWORD ERROR 👉", e);
    return res.status(500).json({ message: e.message });
  }
};

export const resetPassword = async (req, res) => {
  try {
    const { token, newPassword } = req.body;

    if (!token || !newPassword || newPassword.length < 6) {
      return res.status(400).json({
        message: "Invalid token or password too short",
      });
    }

    const hashedToken = crypto.createHash("sha256").update(token).digest("hex");

    const user = await User.findOne({
      resetPasswordToken: hashedToken,
      resetPasswordExpire: { $gt: Date.now() },
    });

    if (!user) {
      return res.status(400).json({
        message: "Token không hợp lệ hoặc đã hết hạn",
      });
    }

    user.passwordHash = await bcrypt.hash(newPassword, 10);
    user.resetPasswordToken = undefined;
    user.resetPasswordExpire = undefined;

    await user.save();

    return res.json({ message: "Đổi mật khẩu thành công" });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ message: "Reset password error" });
  }
};
