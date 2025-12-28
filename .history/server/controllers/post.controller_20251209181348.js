import { Post } from "../models/post.model.js";
import { Comment } from "../models/comment.model.js";

export const createPost = async (req, res) => {
  try {
    const { caption, imageUrl, tags } = req.body;

    const post = await Post.create({
      owner: req.user._id,
      caption: caption || "",
      imageUrl,
      tags: tags || [],
    });

    // populate cho giống getFeed / getUserPosts
    const populated = await post.populate("owner", "username avatarUrl");

    return res.status(201).json(populated);
  } catch (e) {
    console.error("CREATE_POST_ERROR:", e);
    return res.status(500).json({ message: "Create post error" });
  }
};

export const getFeed = async (req, res) => {
  try {
    const posts = await Post.find({ isPublic: true })
      .sort({ createdAt: -1 })
      .populate("owner", "username avatarUrl");
    res.json(posts);
  } catch (e) {
    res.status(500).json({ message: "Get feed error" });
  }
};

export const getUserPosts = async (req, res) => {
  try {
    const { userId } = req.params;
    const posts = await Post.find({ owner: userId })
      .sort({ createdAt: -1 })
      .populate("owner", "username avatarUrl");
    res.json(posts);
  } catch (e) {
    res.status(500).json({ message: "Get user posts error" });
  }
};

export const likePost = async (req, res) => {
  try {
    const { postId } = req.params;
    const userId = req.user._id;
    const post = await Post.findById(postId);
    if (!post) return res.status(404).json({ message: "Post not found" });

    const index = post.likes.findIndex(
      (id) => id.toString() === userId.toString()
    );
    if (index === -1) {
      post.likes.push(userId);
    } else {
      post.likes.splice(index, 1);
    }
    await post.save();
    res.json({ likes: post.likes.length });
  } catch (e) {
    res.status(500).json({ message: "Like error" });
  }
};

export const deletePost = async (req, res) => {
  try {
    const { postId } = req.params;
    const post = await Post.findOne({ _id: postId, owner: req.user._id });
    if (!post) return res.status(404).json({ message: "Post not found" });

    await Comment.deleteMany({ post: post._id });
    await post.deleteOne();
    res.json({ message: "Deleted" });
  } catch (e) {
    res.status(500).json({ message: "Delete error" });
  }
};
