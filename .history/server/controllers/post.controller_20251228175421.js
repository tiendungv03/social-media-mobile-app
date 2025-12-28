


import { Comment } from "../models/comment.model.js";
import { Post } from "../models/post.model.js";

// 1. TẠO BÀI VIẾT
export const createPost = async (req, res) => {
  try {
    const { caption, imageUrl, tags } = req.body;
    const post = await Post.create({
      owner: req.user._id,
      caption: caption || "",
      imageUrl,
      tags: tags || [],
    });
    const populated = await post.populate("owner", "username avatarUrl");
    return res.status(201).json(populated);
  } catch (e) {
    console.error("CREATE_POST_ERROR:", e);
    return res.status(500).json({ message: "Create post error" });
  }
};

// 2. LẤY FEED
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

// 3. LẤY BÀI VIẾT CỦA USER
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

// 4. LIKE BÀI VIẾT
export const likePost = async (req, res) => {
  try {
    const { postId } = req.params;
    const userId = req.user._id;
    const post = await Post.findById(postId);
    if (!post) return res.status(404).json({ message: "Post not found" });

    const index = post.likes.findIndex((id) => id.toString() === userId.toString());
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

// 5. XÓA BÀI VIẾT
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

// --- 👇 2 HÀM MỚI QUAN TRỌNG ĐỂ SỬA LỖI 404 (VIẾT CHO KHỚP SCHEMA MỚI) ---

// 6. LẤY CHI TIẾT BÀI VIẾT (Kèm Comments từ bảng Comment)
export const getPost = async (req, res) => {
  try {
    // Lưu ý: Route dùng :postId nên ở đây lấy postId
    const { postId } = req.params; 

    // Tìm bài viết
    const post = await Post.findById(postId).populate("owner", "username avatarUrl");
    if (!post) return res.status(404).json({ message: "Post not found" });

    // Tìm comment thuộc về bài viết này (Sắp xếp cũ nhất trước)
    const comments = await Comment.find({ post: postId })
        .populate("owner", "username avatarUrl")
        .sort({ createdAt: 1 });

    // Gộp comment vào bài viết để trả về cho Flutter
    const result = post.toObject();
    result.comments = comments; // Flutter sẽ đọc field này

    res.json(result);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Get post details error" });
  }
};

// 7. BÌNH LUẬN (Phiên bản Log chi tiết để tìm lỗi)
export const commentPost = async (req, res) => {
  try {
    const { postId } = req.params;
    const { content } = req.body;

    // 👇 1. In ra Terminal để kiểm tra dữ liệu đầu vào
    console.log("👉 DEBUG COMMENT:", { 
        postId, 
        content, 
        user: req.user ? req.user._id : "NULL" 
    });

    // 👇 2. Kiểm tra an toàn trước khi gọi Database
    if (!req.user) {
        return res.status(401).json({ message: "Lỗi: Server không thấy thông tin User (req.user is null)" });
    }
    if (!content) {
        return res.status(400).json({ message: "Lỗi: Nội dung bình luận bị rỗng" });
    }

    // 👇 3. Tạo comment
    const newComment = await Comment.create({
      content,
      post: postId,
      owner: req.user._id
    });

    // 👇 4. Populate AN TOÀN HƠN 
    // (Tìm lại ID vừa tạo rồi mới populate để tránh lỗi phiên bản Mongoose cũ)
    const populatedComment = await Comment.findById(newComment._id)
        .populate("owner", "username avatarUrl");

    res.json(populatedComment);
  } catch (e) {
    // 👇 5. In lỗi cụ thể ra Terminal (Màn hình đen) để bạn nhìn thấy
    console.error("❌ LỖI SERVER CHI TIẾT:", e); 
    
    // Trả về lỗi cụ thể cho App Flutter hiển thị thay vì chỉ báo "Comment error"
    res.status(500).json({ message: "Lỗi Server: " + e.message });
  }
};