import express from "express";
import * as user from "../controllers/users.js";
import Friendship from "../models/friends.model.js";
import { Post } from "../models/post.model.js";

const userRoutes = express.Router();

userRoutes.get("/", user.getUsers);
userRoutes.post("/register", user.registerUser);
userRoutes.post("/login", user.loginUser);

// 👇 API LẤY PROFILE ĐẦY ĐỦ (ĐÃ SỬA LOGIC ĐẾM)
userRoutes.get('/profile/:targetId', async (req, res) => {
  try {
    const { targetId } = req.params;
    const { currentUserId } = req.query;

    // 1. Đếm số bài viết
    const postCount = await Post.countDocuments({ owner: targetId });

    // 2. Đếm số bạn bè (Status = 'accepted')
    // Tìm trong bảng Friendship, những dòng mà user là người gửi HOẶC người nhận, và status là 'accepted'
    const friendCount = await Friendship.countDocuments({
      $or: [{ requester: targetId }, { recipient: targetId }],
      status: 'accepted'
    });

    // 3. Kiểm tra trạng thái quan hệ với người đang xem (currentUserId)
    let relationStatus = 'none'; // 'none', 'pending', 'pending_received', 'friend', 'self'
    
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
            // Nếu mình là người gửi
            if (friendship.requester.toString() === currentUserId) relationStatus = 'pending';
            // Nếu họ gửi cho mình
            else relationStatus = 'pending_received';
        }
      }
    }

    // 4. Lấy danh sách ảnh
    const posts = await Post.find({ owner: targetId })
                            .sort({ createdAt: -1 })
                            .select('imageUrl _id');

    res.status(200).json({
      postCount,
      followerCount: friendCount, // Số bạn bè = Followers
      followingCount: friendCount, // Số bạn bè = Following
      relationStatus, // Trạng thái quan hệ chính xác
      posts
    });

  } catch (err) {
    console.error("Lỗi Profile API:", err);
    res.status(500).json({ error: err.message });
  }
});

export default userRoutes;