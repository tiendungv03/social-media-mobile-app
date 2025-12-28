import { Router } from "express";
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
    if (!fromId || !toId) return res.status(400).json({ msg: 'Thiếu ID' });

    const existing = await Friendship.findOne({
      $or: [{ requester: fromId, recipient: toId }, { requester: toId, recipient: fromId }]
    });

    if (existing) return res.status(400).json({ msg: 'Đã có quan hệ bạn bè hoặc lời mời' });

    const newFriendship = new Friendship({
      requester: fromId,
      recipient: toId,
      status: 'pending'
    });

    await newFriendship.save();
    res.status(200).json({ message: 'Gửi lời mời thành công', data: newFriendship });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==========================================
// 2. API: Chấp nhận lời mời (🔥 MỚI THÊM)
// PUT /api/friends/accept
// ==========================================
router.put('/accept', async (req, res) => {
  try {
    const { fromId, toId } = req.body; // fromId: Người bấm chấp nhận (Mình), toId: Người gửi lời mời

    // Tìm lời mời mà 'toId' là người gửi (requester), 'fromId' là người nhận (recipient)
    const friendship = await Friendship.findOneAndUpdate(
      { requester: toId, recipient: fromId, status: 'pending' },
      { status: 'accepted' },
      { new: true }
    );

    if (friendship) {
      res.status(200).json({ message: 'Đã trở thành bạn bè', data: friendship });
    } else {
      res.status(404).json({ message: 'Không tìm thấy lời mời để chấp nhận' });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==========================================
// 3. API: Hủy lời mời / Hủy kết bạn
// POST /api/friends/cancel
// ==========================================
router.post('/cancel', async (req, res) => {
  try {
    const { fromId, toId } = req.body;
    const deleted = await Friendship.findOneAndDelete({
      $or: [{ requester: fromId, recipient: toId }, { requester: toId, recipient: fromId }]
    });

    if (deleted) res.status(200).json({ message: 'Đã hủy thành công' });
    else res.status(404).json({ message: 'Không tìm thấy quan hệ để hủy' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==========================================
// 4. API: Lấy danh sách (🔥 ĐÃ SỬA LOGIC SẮP XẾP)
// GET /api/friends/suggestions/:userId
// ==========================================
router.get('/suggestions/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    // A. Lấy tất cả user khác
    const users = await User.find({ _id: { $ne: userId } }).select('-password').lean();

    // B. Lấy các mối quan hệ của mình
    const myFriendships = await Friendship.find({
      $or: [{ requester: userId }, { recipient: userId }]
    });

    // C. Gắn status
    const usersWithStatus = users.map(user => {
      const relationship = myFriendships.find(f => 
        (f.requester.toString() === user._id.toString() && f.recipient.toString() === userId) ||
        (f.recipient.toString() === user._id.toString() && f.requester.toString() === userId)
      );

      let status = 'none';
      if (relationship) {
        if (relationship.status === 'accepted') {
          status = 'friend';
        } else if (relationship.status === 'pending') {
          // Nếu mình là người gửi -> pending (Đã gửi)
          // Nếu mình là người nhận -> pending_received (Chờ chấp nhận)
          if (relationship.requester.toString() === userId) {
            status = 'pending'; 
          } else {
            status = 'pending_received'; 
          }
        }
      }
      return { ...user, status };
    });

    // 🔥 D. SẮP XẾP: Đưa người gửi lời mời (pending_received) lên đầu danh sách
    usersWithStatus.sort((a, b) => {
      // Hàm tính điểm ưu tiên: càng thấp càng xếp trên
      const getPriority = (status) => {
        if (status === 'pending_received') return 1; // Ưu tiên 1: Lời mời kết bạn
        if (status === 'none') return 2;             // Ưu tiên 2: Người lạ (Gợi ý)
        if (status === 'pending') return 3;          // Ưu tiên 3: Đã gửi (xếp dưới)
        return 4;                                    // Ưu tiên 4: Đã là bạn (xếp cuối)
      };
      return getPriority(a.status) - getPriority(b.status);
    });

    res.status(200).json(usersWithStatus);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});



// ... code cũ giữ nguyên

// 👇 API LẤY DANH SÁCH BẠN BÈ (FOLLOWERS/FOLLOWING)
router.get('/list/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    // Tìm tất cả quan hệ 'accepted' của user này
    const friendships = await Friendship.find({
      $or: [{ requester: userId }, { recipient: userId }],
      status: 'accepted'
    }).populate('requester recipient', 'name username avatarUrl email'); 
    // .populate giúp lấy luôn thông tin chi tiết của người kia

    // Lọc ra danh sách "người kia" (không lấy bản thân mình)
    const friendList = friendships.map(f => {
      return f.requester._id.toString() === userId ? f.recipient : f.requester;
    });

    res.status(200).json(friendList);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// export default router; (Giữ nguyên ở cuối)
export default router;