import { Router } from "express";
// SỬA 1: Import đúng tên file (Friendship.js) và không có dấu cách
import Friendship from "../models/Friends.js"; 

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
    // SỬA 2: Dùng biến Friendship (khớp với import ở trên)
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
    // SỬA 3: Dùng new Friendship
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

// SỬA 4: Export default để index.js import được
export default router;