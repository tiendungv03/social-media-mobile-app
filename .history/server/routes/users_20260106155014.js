import express from "express";
import * as userController from "../controllers/users.js";
import Friendship from "../models/friends.model.js";
import { Post } from "../models/post.model.js";
import User from "../models/user.model.js"; // 🔥 Import User Model

const userRoutes = express.Router();

// --- CÁC ROUTE CƠ BẢN ---
userRoutes.get("/", userController.getUsers);
userRoutes.post("/register", userController.registerUser);
userRoutes.post("/login", userController.loginUser);

// ========================================================
// 👇 1. API TÌM KIẾM BẠN BÈ (MỚI THÊM VÀO ĐÂY)
// (Phải đặt route này lên TRƯỚC các route có :id để không bị lỗi)
// ========================================================
userRoutes.get("/search", async (req, res) => {
  try {
    const { q } = req.query; // Lấy từ khóa từ URL (ví dụ: ?q=dieubui)
    
    if (!q) {
      return res.json([]); // Không nhập gì thì trả về rỗng
    }

    // Tìm trong Database (so khớp username HOẶC name)
    const users = await User.find({
      $or: [
        { username: { $regex: q, $options: "i" } }, // Tìm gần đúng, không phân biệt hoa thường
        { name: { $regex: q, $options: "i" } }
      ]
    }).select("username name avatarUrl email"); // Chỉ lấy thông tin cần thiết

    res.json(users);
  } catch (error) {
    console.error("SEARCH ERROR:", error);
    res.status(500).json({ message: "Lỗi tìm kiếm người dùng" });
  }
});

// ========================================================
// 👇 2. API LẤY PROFILE ĐẦY ĐỦ (CODE CŨ CỦA BẠN)
// ========================================================
userRoutes.get('/profile/:targetId', async (req, res) => {
  try {
    const { targetId } = req.params;
    const { currentUserId } = req.query;

    // 1. Lấy thông tin cá nhân
    const userInfo = await User.findById(targetId).select('name username email avatarUrl bio');
    
    if (!userInfo) {
      return res.status(404).json({ message: "User not found" });
    }

    // 2. Đếm số bài viết
    const postCount = await Post.countDocuments({ owner: targetId });

    // 3. Đếm số bạn bè
    const friendCount = await Friendship.countDocuments({
      $or: [{ requester: targetId }, { recipient: targetId }],
      status: 'accepted'
    });

    // 4. Kiểm tra trạng thái quan hệ
    let relationStatus = 'none'; 
    
    if (currentUserId === targetId) {
        relationStatus = 'self';
    } else if (currentUserId) {
      const friendship = await Friendship.findOne({
        $or: [
          { requester: currentUserId, recipient: targetId },
          { requester: targetId, recipient: currentUserId }
        ]
      });

      if (friendship) {
        if (friendship.status === 'accepted') relationStatus = 'friend';
        else if (friendship.status === 'pending') {
            if (friendship.requester.toString() === currentUserId) relationStatus = 'pending';
            else relationStatus = 'pending_received';
        }
      }
    }

    // 5. Lấy danh sách ảnh
    const posts = await Post.find({ owner: targetId })
                            .sort({ createdAt: -1 })
                            .select('imageUrl _id');

    // 6. Trả về kết quả
    res.status(200).json({
      user: userInfo,
      postCount,
      followerCount: friendCount, 
      followingCount: friendCount, 
      relationStatus, 
      posts
    });

  } catch (err) {
    console.error("Lỗi Profile API:", err);
    res.status(500).json({ error: err.message });
  }
});

// ========================================================
// 👇 3. API CẬP NHẬT PROFILE (CODE CŨ CỦA BẠN)
// ========================================================
userRoutes.put('/update/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { name, bio, avatarUrl } = req.body;

    const updatedUser = await User.findByIdAndUpdate(
      userId,
      { 
        name: name, 
        bio: bio,
        avatarUrl: avatarUrl 
      },
      { new: true }
    );

    if (!updatedUser) {
      return res.status(404).json({ message: "User not found" });
    }

    res.status(200).json({ message: "Update success", data: updatedUser });

  } catch (err) {
    console.error("Update Error:", err);
    res.status(500).json({ error: err.message });
  }
});

export default userRoutes;