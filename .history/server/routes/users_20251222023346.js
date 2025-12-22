import express from "express";
import * as userController from "../controllers/users.js"; // Đổi tên biến này để tránh trùng
import Friendship from "../models/friends.model.js";
import { Post } from "../models/post.model.js";
import User from "../models/user.model.js"; // 🔥 IMPORT MODEL USER ĐỂ TÌM TÊN

const userRoutes = express.Router();

userRoutes.get("/", userController.getUsers);
userRoutes.post("/register", userController.registerUser);
userRoutes.post("/login", userController.loginUser);

// 👇 API LẤY PROFILE ĐẦY ĐỦ (ĐÃ SỬA: TRẢ VỀ CẢ INFO USER + SỐ LIỆU)
userRoutes.get('/profile/:targetId', async (req, res) => {
  try {
    const { targetId } = req.params;
    const { currentUserId } = req.query;

    // 🔥 1. QUAN TRỌNG: Lấy thông tin cá nhân (Tên, Avatar, Bio...)
    // Nếu thiếu bước này -> App sẽ hiện dấu "?"
    const userInfo = await User.findById(targetId).select('name username email avatarUrl bio');
    
    if (!userInfo) {
      return res.status(404).json({ message: "Không tìm thấy người dùng này" });
    }

    // 2. Đếm số bài viết
    const postCount = await Post.countDocuments({ owner: targetId });

    // 3. Đếm số bạn bè (Status = 'accepted')
    const friendCount = await Friendship.countDocuments({
      $or: [{ requester: targetId }, { recipient: targetId }],
      status: 'accepted'
    });

    // 4. Kiểm tra trạng thái quan hệ với người đang xem
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

    // 6. Trả về kết quả đầy đủ
    res.status(200).json({
      user: userInfo,      // 👈 TRẢ VỀ CỤC NÀY ĐỂ APP HIỂN THỊ TÊN
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

export default userRoutes;