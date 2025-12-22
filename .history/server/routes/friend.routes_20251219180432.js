const Friendship = require('./models/Friends'); // Import model vừa tạo

// API: Gửi lời mời kết bạn
// POST /api/friends/request
app.post('/api/friends/request', async (req, res) => {
  try {
    const { fromUserId, toUserId } = req.body;

    // Kiểm tra xem đã tồn tại lời mời chưa
    const existing = await Friendship.findOne({
      requester: fromUserId,
      recipient: toUserId
    });

    if (existing) {
      return res.status(400).json({ msg: 'Đã gửi lời mời rồi' });
    }

    // Tạo mới
    const newFriendship = new Friendship({
      requester: fromUserId,
      recipient: toUserId,
      status: 'pending' // Mặc định là đang chờ
    });

    await newFriendship.save();
    res.json(newFriendship);
    
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});