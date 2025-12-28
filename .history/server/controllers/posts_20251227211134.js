// import PostMessage from "../models/postMessage.js";

// // --- LẤY DANH SÁCH BÀI VIẾT ---
// export const getPosts = async (req, res) => {
//   try {
//     const postMessage = await PostMessage.find();
//     res.status(200).json(postMessage);
//   } catch (error) {
//     res.status(404).json({ message: error.message });
//   }
// };

// // --- TẠO BÀI VIẾT MỚI ---
// export const createPost = async (req, res) => {
//   const post = req.body;
//   const newPost = new PostMessage(post);
//   try {
//     await newPost.save();
//     res.status(201).json(newPost);
//   } catch (error) {
//     res.status(409).json({ message: error.message });
//   }
// };

// // --- CẬP NHẬT BÀI VIẾT ---
// export const updatePost = async (req, res) => {
//   res.send("Update a post");
// };

// // --- XÓA BÀI VIẾT ---
// export const deletePost = (req, res) => {
//   res.send("Delete a post");
// };

// // --- LIKE BÀI VIẾT ---
// export const likePost = async (req, res) => {
//   const { id } = req.params;
//   try {
//     const post = await PostMessage.findById(id);
//     if (!post) return res.status(404).json({ message: "Post not found" });

//     post.likeCount = (post.likeCount || 0) + 1;
//     const updated = await post.save();
//     res.status(200).json(updated);
//   } catch (error) {
//     res.status(500).json({ message: error.message });
//   }
// };

// // --- 👇 2 HÀM QUAN TRỌNG ĐỂ FIX LỖI 404 ---

// // 1. LẤY CHI TIẾT 1 BÀI VIẾT
// export const getPost = async (req, res) => { 
//     const { id } = req.params;
//     try {
//         const post = await PostMessage.findById(id);
//         if (!post) return res.status(404).json({ message: "Không tìm thấy bài viết" });
//         res.status(200).json(post);
//     } catch (error) {
//         res.status(404).json({ message: error.message });
//     }
// };

// // 2. XỬ LÝ BÌNH LUẬN (Bạn đang thiếu hàm này nên Server báo lỗi)
// export const commentPost = async (req, res) => {
//     const { id } = req.params;
//     const { content } = req.body;

//     try {
//         const post = await PostMessage.findById(id);
//         if (!post) return res.status(404).json({ message: "Post not found" });

//         // Thêm bình luận vào mảng
//         post.comments.push({ 
//             content: content,
//             createdAt: new Date().toISOString()
//         });

//         // Cập nhật Database
//         const updatedPost = await PostMessage.findByIdAndUpdate(id, post, { new: true });
        
//         // Trả về bình luận vừa tạo (hoặc cả bài viết)
//         res.json(updatedPost.comments[updatedPost.comments.length - 1]); 
//     } catch (error) {
//         res.status(409).json({ message: error.message });
//     }
// };


import PostMessage from "../models/postMessage.js";

// --- LẤY DANH SÁCH BÀI VIẾT ---
export const getPosts = async (req, res) => {
  try {
    const postMessage = await PostMessage.find();
    res.status(200).json(postMessage);
  } catch (error) {
    res.status(404).json({ message: error.message });
  }
};

// --- TẠO BÀI VIẾT MỚI ---
export const createPost = async (req, res) => {
  const post = req.body;
  const newPost = new PostMessage(post);
  try {
    await newPost.save();
    res.status(201).json(newPost);
  } catch (error) {
    res.status(409).json({ message: error.message });
  }
};

export const updatePost = async (req, res) => {
  res.send("Update a post");
};

export const deletePost = (req, res) => {
  res.send("Delete a post");
};

export const likePost = async (req, res) => {
  const { id } = req.params;
  try {
    const post = await PostMessage.findById(id);
    if (!post) return res.status(404).json({ message: "Post not found" });

    post.likeCount = (post.likeCount || 0) + 1;
    const updated = await post.save();
    res.status(200).json(updated);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// --- 👇 2 HÀM QUAN TRỌNG ĐỂ FIX LỖI 404 ---

// 1. LẤY CHI TIẾT 1 BÀI VIẾT
export const getPost = async (req, res) => { 
    const { id } = req.params;
    try {
        const post = await PostMessage.findById(id);
        if (!post) return res.status(404).json({ message: "Không tìm thấy bài viết" });
        res.status(200).json(post);
    } catch (error) {
        res.status(404).json({ message: error.message });
    }
};

// --- 👇 2 HÀM QUAN TRỌNG ĐỂ FIX LỖI 404 ---

// 1. LẤY CHI TIẾT 1 BÀI VIẾT
export const getPosts = async (req, res) => { 
    const { id } = req.params;
    try {
        const post = await PostMessage.findById(id);
        if (!post) return res.status(404).json({ message: "Không tìm thấy bài viết" });
        res.status(200).json(post);
    } catch (error) {
        res.status(404).json({ message: error.message });
    }
};

// 2. XỬ LÝ BÌNH LUẬN (Bạn cần thêm hàm này)
export const commentPost = async (req, res) => {
    const { id } = req.params;
    const { content } = req.body;

    try {
        const post = await PostMessage.findById(id);
        if (!post) return res.status(404).json({ message: "Post not found" });

        // Thêm bình luận vào mảng
        post.comments.push({ 
            content: content,
            createdAt: new Date().toISOString()
        });

        // Cập nhật Database
        const updatedPost = await PostMessage.findByIdAndUpdate(id, post, { new: true });
        
        // Trả về bình luận vừa tạo
        res.json(updatedPost.comments[updatedPost.comments.length - 1]); 
    } catch (error) {
        res.status(409).json({ message: error.message });
    }
};