import { Router } from "express";
// SỬA QUAN TRỌNG: Tên file phải khớp chính xác với ảnh bạn gửi (friends.model.js)
import Friendship from "../models/friends.model.js";


const router = Router();

// API: Gửi lời mời kết bạn
// POST /api/friends/request
router.post('/request', async (req, res) => {
  try {
    const { fromId, toId } = req.body;

    if (!fromId || !toId) {
      return res.status(400).json({ msg: 'Thiếu ID người gửi hoặc người nhận' });
    }

    // 1. Kiểm tra tồn tại
    const existing = await Friendship.findOne({
      $or: [
        { requester: fromId, recipient: toId },
        { requester: toId, recipient: fromId }
      ]
    });

    if (existing) {
      return res.status(400).json({ msg: 'Đã gửi lời mời hoặc đã kết bạn rồi' });
    }

    // 2. Tạo mới
    const newFriendship = new Friendship({
      requester: fromId,
      recipient: toId,
      status: 'pending'
    });

    await newFriendship.save();
    
    res.status(200).json({ 
      message: 'Gửi lời mời thành công', 
      data: newFriendship 
    });
    
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});


// API: Lấy danh sách gợi ý kết bạn (Lấy tất cả user trừ chính mình)
// GET /api/friends/suggestions/:userId
router.get('/suggestions/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    // Tìm tất cả user trong DB, ngoại trừ user có ID là userId ($ne nghĩa là Not Equal)
    // .select('-password') nghĩa là lấy thông tin nhưng bỏ trường password ra cho bảo mật
    const users = await User.find({ _id: { $ne: userId } }).select('-password');

    res.status(200).json(users);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

export default router;