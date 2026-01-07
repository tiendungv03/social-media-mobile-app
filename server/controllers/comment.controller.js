import {Comment}  from "../models/comment.model.js";
import  {Post } from "../models/post.model.js";

export const createComment = async (req, res) => {
  try {
    const { postId } = req.params;
    const { text } = req.body;

    if (!text || text.trim() === "") {
      return res.status(400).json({ message: "Comment text is required" });
    }

    const post = await Post.findById(postId);
    if (!post) return res.status(404).json({ message: "Post not found" });

    

    const cmt = await Comment.create({
      post: postId,
      user: req.user._id,
      text,
    });

    post.commentsCount += 1;
    await post.save();

    await cmt.populate("user", "username avatarUrl");

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

export const toggleLikeComment = async (req, res) => {
  try {
    const { commentId } = req.params;
    const userId = req.user._id;

    const comment = await Comment.findById(commentId);
    if (!comment) {
      return res.status(404).json({ message: "Comment not found" });
    }

    // ⚠️ đảm bảo likes tồn tại
    if (!comment.likes) {
      comment.likes = [];
    }

    const index = comment.likes.findIndex(
      id => id.toString() === userId.toString()
    );

    let liked = false;

    if (index === -1) {
      comment.likes.push(userId);
      liked = true;
    } else {
      comment.likes.splice(index, 1);
      liked = false;
    }

    await comment.save();

    res.json({
      liked,
      likesCount: comment.likes.length,
    });

   


  } catch (e) {
    console.error("❌ LIKE COMMENT ERROR:", e);
    res.status(500).json({ message: "Toggle like comment error" });
  }
};


export const replyComment = async (req, res) => {
  try {
    const { commentId } = req.params;
    const { content } = req.body;

    if (!content || !content.trim()) {
      return res.status(400).json({ message: "Content required" });
    }

    const parent = await Comment.findById(commentId);
    if (!parent) {
      return res.status(404).json({ message: "Parent comment not found" });
    }

    const reply = await Comment.create({
      post: parent.post,
      owner: req.user._id,
      content,
      parent: parent._id,
    });

    await reply.populate("owner", "username avatarUrl");

    res.status(201).json(reply);
  } catch (e) {
    res.status(500).json({ message: "Reply comment error" });
  }
};
