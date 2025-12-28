import { Comment } from "../models/comment.model.js";
import { Post } from "../models/post.model.js";

export const createComment = async (req, res) => {
  try {
    const { postId } = req.params;
    const { text } = req.body;

    const post = await Post.findById(postId);
    if (!post) return res.status(404).json({ message: "Post not found" });

    const cmt = await Comment.create({
      post: postId,
      user: req.user._id,
      text,
    });

    post.commentsCount += 1;
    await post.save();

    res.status(201).json(cmt);
  } catch (e) {
    res.status(500).json({ message: "Create comment error" });
  }
};

export const getComments = async (req, res) => {
  try {
    const { postId } = req.params;
    const list = await Comment.find({ post: postId })
      .sort({ createdAt: 1 })
      .populate("user", "username avatarUrl");
    res.json(list);
  } catch (e) {
    res.status(500).json({ message: "Get comments error" });
  }
};
