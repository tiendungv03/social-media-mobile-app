// import { Router } from "express";
// import {
//   commentPost,
//   createPost,
//   deletePost,
//   getFeed,
//   getPost,
//   getUserPosts,
//   likePost,
// } from "../controllers/post.controller.js";
// import { authRequired } from "../middleware/auth.middleware.js";

// const router = Router();

// // Routes cũ
// router.get("/", authRequired, getFeed);
// router.get("/user/:userId", authRequired, getUserPosts);
// router.post("/", authRequired, createPost);

// // 👇 THÊM 2 ROUTE QUAN TRỌNG NÀY (Để sửa lỗi 404)
// // Lưu ý: Dùng :postId cho đồng bộ
// router.get("/:postId", authRequired, getPost); 
// router.post("/:postId/comments", authRequired, commentPost);

// // Routes cũ
// router.post("/:postId/like", authRequired, likePost);
// router.delete("/:postId", authRequired, deletePost);

// export default router;


