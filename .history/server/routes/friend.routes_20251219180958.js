const express = require('express');
const router = express.Router();

// LƯU Ý: Kiểm tra kỹ tên file trong thư mục models của bạn là 'Friendship.js' hay 'Friends.js'
// Dùng dấu ../ để lùi ra thư mục cha tìm vào folder models
const Friendship = require('../models/ '); 

// API: Gửi lời mời kết bạn
// Đường dẫn gọi từ Flutter sẽ là: POST http://localhost:5000/api/friends/request
router.post('/request', async (req, res) => {
  try {
    // Lấy dữ liệu từ Flutter gửi lên (dùng fromId, toId cho khớp với Flutter)
    const { fromId, toId } = req.body;

    // Validate: Kiểm tra xem có gửi thiếu dữ liệu không
    if (!fromId || !toId) {
      return res.status(400).json({ msg: 'Thiếu ID người gửi hoặc người nhận' });
    }

    // 1. Kiểm tra xem đã tồn tại lời mời hoặc đã là bạn chưa
    const existing = await Friendship.findOne({
      $or: [
        { requester: fromId, recipient: toId },
        { requester: toId, recipient: fromId } // Kiểm tra cả chiều ngược lại
      ]
    });

    if (existing) {
      return res.status(400).json({ msg: 'Đã gửi lời mời hoặc đã kết bạn rồi' });
    }

    // 2. Tạo mới lời mời
    const newFriendship = new Friendship({
      requester: fromId,
      recipient: toId,
      status: 'pending' // Mặc định là đang chờ
    });

    await newFriendship.save();
    
    // Trả về kết quả
    res.status(200).json({ 
      message: 'Gửi lời mời thành công', 
      data: newFriendship 
    });
    
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;