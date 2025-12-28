import express from "express";
import * as post from "../controllers/posts.js";

const postRoutes = express.Router();
// Example route for posts
//localhost:3000/api/posts
postRoutes.get("/", post.getPosts);
postRoutes.post("/", post.createPost);
postRoutes.patch("/:id", post.updatePost);
postRoutes.delete("/:id", post.deletePost);
postRoutes.patch("/:id/likePost", post.likePost);

export default postRoutes;
