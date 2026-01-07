import { Router } from "express";
import Friendship from "../models/friends.model.js";
import User from "../models/user.model.js";

const router = Router();

// ==========================================
// 1. Gửi lời mời (Sửa lại nhận ID từ URL)
// POST /api/friends/request/:toId
// ==========================================
router.post('/request/:toId', async (req, res) => {
  try {
    const { toId } = req.params;          // Lấy ID người nhận từ URL
    const { currentUserId: fromId } = req.body; // Lấy ID mình từ Body

    if (!fromId || !toId) return res.status(400).json({ msg: 'Thiếu ID' });
    if (fromId === toId) return res.status(400).json({ msg: 'Không thể tự kết bạn' });

    // Kiểm tra đã có quan hệ chưa
    const existing = await Friendship.findOne({
      $or: [{ requester: fromId, recipient: toId }, { requester: toId, recipient: fromId }]
    });

    if (existing) {
      // Nếu đã từng hủy kết bạn (status là gì đó) thì update lại, còn không thì báo lỗi
      return res.status(400).json({ msg: 'Đã có quan hệ bạn bè hoặc lời mời' });
    }

    const newFriendship = new Friendship({
      requester: fromId,
      recipient: toId,
      status: 'pending'
    });

    await newFriendship.save();
    res.status(200).json({ message: 'Đã gửi lời mời', data: newFriendship });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==========================================
// 2. Chấp nhận lời mời (Sửa lại nhận ID từ URL)
// PUT /api/friends/accept/:targetId
// ==========================================
router.put('/accept/:targetId', async (req, res) => {
  try {
    const { targetId } = req.params; // ID người gửi lời mời (người kia)
    const { currentUserId: myId } = req.body; // ID của mình

    const friendship = await Friendship.findOneAndUpdate(
      { requester: targetId, recipient: myId, status: 'pending' },
      { status: 'accepted' },
      { new: true }
    );

    if (friendship) {
      res.status(200).json({ message: 'Đã trở thành bạn bè', data: friendship });
    } else {
      res.status(404).json({ message: 'Không tìm thấy lời mời phù hợp' });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==========================================
// 3. Hủy kết bạn / Hủy lời mời (Sửa tên route cho khớp Flutter)
// POST /api/friends/unfriend/:toId
// ==========================================
router.post('/unfriend/:toId', async (req, res) => {
  try {
    const { toId } = req.params;
    const { currentUserId: fromId } = req.body;

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
// 4. Lấy danh sách gợi ý (GIỮ NGUYÊN CODE TỐT CỦA BẠN)
// GET /api/friends/suggestions/:userId
// ==========================================
router.get('/suggestions/:userId', async (req, res) => {
  // ... (Giữ nguyên logic tuyệt vời của bạn ở đây) ...
  // (Mình paste lại y nguyên logic của bạn ở dưới để file hoàn chỉnh)
  try {
    const { userId } = req.params;
    const users = await User.find({ _id: { $ne: userId } }).select('-password').lean();
    const myFriendships = await Friendship.find({
      $or: [{ requester: userId }, { recipient: userId }]
    });

    const usersWithStatus = users.map(user => {
      const relationship = myFriendships.find(f => 
        (f.requester.toString() === user._id.toString() && f.recipient.toString() === userId) ||
        (f.recipient.toString() === user._id.toString() && f.requester.toString() === userId)
      );

      let status = 'none';
      if (relationship) {
        if (relationship.status === 'accepted') status = 'friend';
        else if (relationship.status === 'pending') {
          if (relationship.requester.toString() === userId) status = 'pending'; 
          else status = 'pending_received'; 
        }
      }
      return { ...user, status };
    });

    usersWithStatus.sort((a, b) => {
      const getPriority = (status) => {
        if (status === 'pending_received') return 1;
        if (status === 'none') return 2;
        if (status === 'pending') return 3;
        return 4;
      };
      return getPriority(a.status) - getPriority(b.status);
    });

    res.status(200).json(usersWithStatus);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 5. Lấy danh sách bạn bè (Giữ nguyên)
router.get('/list/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const friendships = await Friendship.find({
      $or: [{ requester: userId }, { recipient: userId }],
      status: 'accepted'
    }).populate('requester recipient', 'name username avatarUrl email');

    const friendList = friendships.map(f => {
      return f.requester._id.toString() === userId ? f.recipient : f.requester;
    });

    res.status(200).json(friendList);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;