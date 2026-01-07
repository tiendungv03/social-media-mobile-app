import Friendship from "../models/friends.model.js";
import { Post } from "../models/post.model.js";
import User from "../models/user.model.js";

// GET /api/users
export const getUsers = async (req, res) => {
  try {
    const users = await User.find();
    return res.status(200).json(users);
  } catch (e) {
    return res.status(404).json({ message: e.message });
  }
};

// GET /api/users/search?q=...
export const searchUsers = async (req, res) => {
  try {
    const q = (req.query.q || "").trim(); // ✅ dùng q
    if (!q) return res.json([]);

    const users = await User.find({
      $or: [
        { username: { $regex: q, $options: "i" } },
        { name: { $regex: q, $options: "i" } },
      ],
    }).select("username name avatarUrl email");

    return res.json(users);
  } catch (error) {
    console.error("SEARCH ERROR:", error);
    return res.status(500).json({ message: "Lỗi tìm kiếm người dùng" });
  }
};

// GET /api/users/profile/:targetId?currentUserId=...
export const getProfile = async (req, res) => {
  try {
    const { targetId } = req.params;
    const { currentUserId } = req.query;

    const userInfo = await User.findById(targetId).select(
      "name username email avatarUrl bio"
    );

    if (!userInfo) {
      return res.status(404).json({ message: "User not found" });
    }

    const postCount = await Post.countDocuments({ owner: targetId });

    const friendCount = await Friendship.countDocuments({
      $or: [{ requester: targetId }, { recipient: targetId }],
      status: "accepted",
    });

    let relationStatus = "none";

    if (currentUserId === targetId) {
      relationStatus = "self";
    } else if (currentUserId) {
      const friendship = await Friendship.findOne({
        $or: [
          { requester: currentUserId, recipient: targetId },
          { requester: targetId, recipient: currentUserId },
        ],
      });

      if (friendship) {
        if (friendship.status === "accepted") relationStatus = "friend";
        else if (friendship.status === "pending") {
          relationStatus =
            friendship.requester.toString() === currentUserId
              ? "pending"
              : "pending_received";
        }
      }
    }

    const posts = await Post.find({ owner: targetId })
      .sort({ createdAt: -1 })
      .select("imageUrl _id");

    return res.status(200).json({
      user: userInfo,
      postCount,
      followerCount: friendCount,
      followingCount: friendCount,
      relationStatus,
      posts,
    });
  } catch (err) {
    console.error("PROFILE ERROR:", err);
    return res.status(500).json({ error: err.message });
  }
};

// PUT /api/users/update/:userId
export const updateProfile = async (req, res) => {
  try {
    const { userId } = req.params;
    const { name, bio, avatarUrl } = req.body;

    const updatedUser = await User.findByIdAndUpdate(
      userId,
      { name, bio, avatarUrl },
      { new: true }
    );

    if (!updatedUser) {
      return res.status(404).json({ message: "User not found" });
    }

    return res
      .status(200)
      .json({ message: "Update success", data: updatedUser });
  } catch (err) {
    console.error("UPDATE ERROR:", err);
    return res.status(500).json({ error: err.message });
  }
};
