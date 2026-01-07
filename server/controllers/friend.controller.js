import Friendship from "../models/friends.model.js";

export const sendFriendRequest = async (req, res) => {
  try {
    const { targetId } = req.params;
    const { currentUserId } = req.body;

    if (!currentUserId)
      return res.status(400).json({ message: "Thiếu ID người gửi" });

    const existing = await Friendship.findOne({
      $or: [
        { requester: currentUserId, recipient: targetId },
        { requester: targetId, recipient: currentUserId },
      ],
    });

    if (existing) return res.status(200).json(existing); // Đã có rồi thì trả về luôn

    // Tạo lời mời mới
    const newFriend = new Friendship({
      requester: currentUserId,
      recipient: targetId,
      status: "pending", // Trạng thái: Đang chờ
    });

    await newFriend.save();
    res.status(200).json(newFriend);
  } catch (err) {
    console.log(err);
    res.status(500).json({ error: err.message });
  }
};

// 2. Hủy kết bạn / Hủy lời mời (Unfollow)
export const unfriend = async (req, res) => {
  try {
    const { targetId } = req.params;
    const { currentUserId } = req.body;

    await Friendship.findOneAndDelete({
      $or: [
        { requester: currentUserId, recipient: targetId },
        { requester: targetId, recipient: currentUserId },
      ],
    });

    res.status(200).json({ message: "Đã hủy thành công" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
