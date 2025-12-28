// import { Comment } from "../models/comment.model.js";
// import { Post } from "../models/post.model.js";

// // 1. TẠO BÀI VIẾT
// export const createPost = async (req, res) => {
//   try {
//     const { caption, imageUrl, tags } = req.body;
//     const post = await Post.create({
//       owner: req.user._id,
//       caption: caption || "",
//       imageUrl,
//       tags: tags || [],
//     });
//     const populated = await post.populate("owner", "username avatarUrl");
//     return res.status(201).json(populated);
//   } catch (e) {
//     console.error("CREATE_POST_ERROR:", e);
//     return res.status(500).json({ message: "Create post error" });
//   }
// };

// // 2. LẤY FEED
// export const getFeed = async (req, res) => {
//   try {
//     const posts = await Post.find({ isPublic: true })
//       .sort({ createdAt: -1 })
//       .populate("owner", "username avatarUrl");
//     res.json(posts);
//   } catch (e) {
//     res.status(500).json({ message: "Get feed error" });
//   }
// };

// // 3. LẤY BÀI VIẾT CỦA USER
// export const getUserPosts = async (req, res) => {
//   try {
//     const { userId } = req.params;
//     const posts = await Post.find({ owner: userId })
//       .sort({ createdAt: -1 })
//       .populate("owner", "username avatarUrl");
//     res.json(posts);
//   } catch (e) {
//     res.status(500).json({ message: "Get user posts error" });
//   }
// };

// // 4. LIKE BÀI VIẾT
// export const likePost = async (req, res) => {
//   try {
//     const { postId } = req.params;
//     const userId = req.user._id;
//     const post = await Post.findById(postId);
//     if (!post) return res.status(404).json({ message: "Post not found" });

//     const index = post.likes.findIndex((id) => id.toString() === userId.toString());
//     if (index === -1) {
//       post.likes.push(userId);
//     } else {
//       post.likes.splice(index, 1);
//     }
//     await post.save();
//     res.json({ likes: post.likes.length });
//   } catch (e) {
//     res.status(500).json({ message: "Like error" });
//   }
// };

// // 5. XÓA BÀI VIẾT
// export const deletePost = async (req, res) => {
//   try {
//     const { postId } = req.params;
//     const post = await Post.findOne({ _id: postId, owner: req.user._id });
//     if (!post) return res.status(404).json({ message: "Post not found" });

//     await Comment.deleteMany({ post: post._id });
//     await post.deleteOne();
//     res.json({ message: "Deleted" });
//   } catch (e) {
//     res.status(500).json({ message: "Delete error" });
//   }
// };

// // --- 👇 2 HÀM MỚI QUAN TRỌNG ĐỂ SỬA LỖI 404 (VIẾT CHO KHỚP SCHEMA MỚI) ---

// // 6. LẤY CHI TIẾT BÀI VIẾT (Kèm Comments từ bảng Comment)
// export const getPost = async (req, res) => {
//   try {
//     const { postId } = req.params; // Dùng postId cho khớp router

//     // Tìm bài viết
//     const post = await Post.findById(postId).populate("owner", "username avatarUrl");
//     if (!post) return res.status(404).json({ message: "Post not found" });

//     // Tìm comment thuộc về bài viết này (Sắp xếp mới nhất trước)
//     const comments = await Comment.find({ post: postId })
//         .populate("owner", "username avatarUrl")
//         .sort({ createdAt: 1 });

//     // Gộp comment vào bài viết để trả về cho Flutter
//     // (Flutter đang mong đợi field 'comments' là list)
//     const result = post.toObject();
//     result.comments = comments;

//     res.json(result);
//   } catch (e) {
//     console.error(e);
//     res.status(500).json({ message: "Get post details error" });
//   }
// };

// // 7. BÌNH LUẬN (Tạo vào bảng Comment riêng)
// export const commentPost = async (req, res) => {
//   try {
//     const { postId } = req.params;
//     const { content } = req.body;

//     // Tạo comment mới
//     const newComment = await Comment.create({
//       content,
//       post: postId,
//       owner: req.user._id
//     });

//     // Populate thông tin người comment
//     await newComment.populate("owner", "username avatarUrl");

//     res.json(newComment);
//   } catch (e) {
//     console.error(e);
//     res.status(500).json({ message: "Comment error" });
//   }
// };