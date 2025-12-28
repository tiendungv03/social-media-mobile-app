import express from "express";
import * as userController from "../controllers/users.js"; // Đổi tên biến để không bị trùng
import Friendship from "../models/friends.model.js";
import { Post } from "../models/post.model.js";
import User from "../models/user.model.js"; // 🔥 QUAN TRỌNG: Import model User để lấy tên/avatar

const userRoutes = express.Router();

userRoutes.get("/", userController.getUsers);
userRoutes.post("/register", userController.registerUser);
userRoutes.post("/login", userController.loginUser);

// 👇 API LẤY PROFILE ĐẦY ĐỦ (ĐÃ SỬA: TRẢ VỀ CẢ TÊN VÀ AVATAR)
userRoutes.get('/profile/:targetId', async (req, res) => {
  try {
    const { targetId } = req.params;
    const { currentUserId } = req.query;

    // 🔥 1. THÊM ĐOẠN NÀY: Lấy thông tin cá nhân (Tên, Avatar, Bio...)
    // Nếu thiếu đoạn này -> App sẽ không biết tên là gì -> Hiện dấu "?"
    const userInfo = await User.findById(targetId).select('name username email avatarUrl bio');
    
    if (!userInfo) {
      return res.status(404).json({ message: "User not found" });
    }

    // 2. Đếm số bài viết
    const postCount = await Post.countDocuments({ owner: targetId });

    // 3. Đếm số bạn bè (Status = 'accepted')
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

    // 6. Trả về kết quả (Đã bổ sung 'user')
    res.status(200).json({
      user: userInfo,      // 👈 QUAN TRỌNG: Trả về cục này để App hiển thị
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

// ... (Các code cũ giữ nguyên)

// 👇 API CẬP NHẬT PROFILE (UPDATE)
userRoutes.put('/update/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const { name, bio, avatarUrl } = req.body;

    // Tìm user và cập nhật
    const updatedUser = await User.findByIdAndUpdate(
      userId,
      { 
        name: name, 
        bio: bio,
        avatarUrl: avatarUrl 
      },
      { new: true } // Trả về dữ liệu mới sau khi update
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