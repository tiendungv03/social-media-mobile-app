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
    // 👇 Sửa: Lấy thêm 'name'
    const populated = await post.populate("owner", "username name avatarUrl");
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
      // 👇 Sửa: Lấy thêm 'name'
      .populate("owner", "username name avatarUrl");
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
      // 👇 Sửa: Lấy thêm 'name'
      .populate("owner", "username name avatarUrl");
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

// --- 👇 2 HÀM QUAN TRỌNG ĐỂ HIỂN THỊ TÊN ĐÚNG ---

// 6. LẤY CHI TIẾT BÀI VIẾT (Kèm Comments)
export const getPost = async (req, res) => {
  try {
    const { postId } = req.params; 

    // Tìm bài viết - Lấy cả 'name'
    const post = await Post.findById(postId).populate("owner", "username name avatarUrl");
    if (!post) return res.status(404).json({ message: "Post not found" });

    // Tìm comment - Lấy cả 'name' của người comment
    const comments = await Comment.find({ post: postId })
        // 👇 QUAN TRỌNG: Thêm 'name' vào chuỗi populate
        .populate("user", "username name avatarUrl") 
        .sort({ createdAt: 1 });

    // Map dữ liệu
    const formattedComments = comments.map(c => ({
        _id: c._id,
        content: c.text,
        createdAt: c.createdAt,
        owner: c.user // Bây giờ owner đã có cả 'username' và 'name'
    }));

    const result = post.toObject();
    result.comments = formattedComments;

    res.json(result);
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Get post details error" });
  }
};

// 7. BÌNH LUẬN (Trả về tên ngay lập tức)
export const commentPost = async (req, res) => {
  try {
    const { postId } = req.params;
    const { content } = req.body;

    if (!req.user) return res.status(401).json({ message: "No user found" });
    if (!content) return res.status(400).json({ message: "Content required" });

    const newComment = await Comment.create({
      text: content,
      post: postId,
      user: req.user._id
    });

    // 👇 QUAN TRỌNG: Thêm 'name' để hiển thị ngay
    await newComment.populate("user", "username name avatarUrl");

    const responseForApp = {
        _id: newComment._id,
        content: newComment.text,
        createdAt: newComment.createdAt,
        owner: newComment.user 
    };

    res.json(responseForApp);
  } catch (e) {
    console.error("❌ LỖI DB:", e);
    res.status(500).json({ message: "Lỗi Server: " + e.message });
  }
};np