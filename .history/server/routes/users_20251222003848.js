import express from "express";
import * as user from "../controllers/users.js";

const userRoutes = express.Router();
// Example route for users
//localhost:5000/api/users
userRoutes.get("/", user.getUsers);
userRoutes.post("/register", user.registerUser);
userRoutes.post("/login", user.loginUser);


// --- 👇 API MỚI: LẤY THÔNG TIN PROFILE ĐẦY ĐỦ 👇 ---
// URL: GET /api/users/profile/:targetUserId?currentUserId=...
userRoutes.get('/profile/:targetId', async (req, res) => {
  try {
    const { targetId } = req.params;
    const { currentUserId } = req.query;

    // 1. Đếm số bài viết (Dùng trường 'owner' để khớp với model của bạn)
    const postCount = await Post.countDocuments({ owner: targetId });

    // 2. Đếm bạn bè (Tạm tính: Bạn bè = Followers = Following)
    const friendCount = await Friendship.countDocuments({
      $or: [{ requester: targetId }, { recipient: targetId }],
      status: 'accepted'
    });

    // 3. Kiểm tra xem mình (currentUserId) đã gửi lời mời hay kết bạn chưa
    let isFollowing = false;
    if (currentUserId) {
      const friendship = await Friendship.findOne({
        $or: [
          { requester: currentUserId, recipient: targetId },
          { requester: targetId, recipient: currentUserId }
        ],
        status: { $in: ['pending', 'accepted'] }
      });
      if (friendship) isFollowing = true;
    }

    // 4. Lấy danh sách ảnh thật (Mới nhất lên đầu)
    const posts = await Post.find({ owner: targetId }) // Dùng 'owner'
                            .sort({ createdAt: -1 })
                            .select('imageUrl _id');

    res.status(200).json({
      postCount,
      followerCount: friendCount,
      followingCount: friendCount,
      isFollowing,
      posts // Trả về mảng ảnh thật
    });

  } catch (err) {
    console.error("Lỗi Profile API:", err);
    res.status(500).json({ error: err.message });
  }
});


export default userRoutes;
