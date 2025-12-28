import { Router } from "express";
// Tên file model phải khớp chính xác
import Friendship from "../models/friends.model.js";
import User from "../models/user.model.js";

const router = Router();

// ==========================================
// 1. API: Gửi lời mời kết bạn
// POST /api/friends/request
// ==========================================
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

// ==========================================
// 2. API: Hủy lời mời kết bạn
// POST /api/friends/cancel
// ==========================================
router.post('/cancel', async (req, res) => {
  try {
    const { fromId, toId } = req.body;

    // Tìm và xóa vĩnh viễn dòng dữ liệu kết bạn
    const deletedFriendship = await Friendship.findOneAndDelete({
      $or: [
        { requester: fromId, recipient: toId },
        { requester: toId, recipient: fromId }
      ]
    });

    if (deletedFriendship) {
      res.status(200).json({ message: 'Đã hủy lời mời thành công' });
    } else {
      res.status(404).json({ message: 'Không tìm thấy lời mời để hủy' });
    }

  } catch (err) {
    console.error("Lỗi hủy kết bạn:", err);
    res.status(500).json({ error: err.message });
  }
});

// ==========================================
// 3. API: Lấy danh sách gợi ý (ĐÃ NÂNG CẤP)
// GET /api/friends/suggestions/:userId
// ==========================================
router.get('/suggestions/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    // BƯỚC A: Lấy danh sách tất cả user (trừ bản thân mình)
    // .lean() trả về Object thường (giúp ta chỉnh sửa dữ liệu status dễ dàng hơn)
    const users = await User.find({ _id: { $ne: userId } }).select('-password').lean();

    // BƯỚC B: Lấy tất cả mối quan hệ của mình (dù là người gửi hay người nhận)
    const myFriendships = await Friendship.find({
      $or: [{ requester: userId }, { recipient: userId }]
    });

    // BƯỚC C: Duyệt qua từng user và gắn cái mác "status" vào
    const usersWithStatus = users.map(user => {
      // Tìm xem có mối quan hệ nào giữa mình và user này không
      const relationship = myFriendships.find(f => 
        (f.requester.toString() === user._id.toString() && f.recipient.toString() === userId) ||
        (f.recipient.toString() === user._id.toString() && f.requester.toString() === userId)
      );

      // Mặc định là 'none' (Chưa quen biết)
      let status = 'none';

      if (relationship) {
        if (relationship.status === 'accepted') {
          status = 'friend'; // Đã là bạn
        } else if (relationship.status === 'pending') {
          // Nếu đang chờ: Kiểm tra xem AI LÀ NGƯỜI GỬI?
          if (relationship.requester.toString() === userId) {
            status = 'pending'; // Mình gửi -> App hiện mũi tên "Đã gửi"
          } else {
            status = 'pending_received'; // Họ gửi cho mình (Tạm thời App sẽ hiện dấu cộng, sau này xử lý nút Chấp nhận sau)
          }
        }
      }

      // Trả về user kèm theo status chính xác
      return { ...user, status };
    });

    res.status(200).json(usersWithStatus);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

export default router;