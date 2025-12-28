import PostMessage from "../models/postMessage.js";

export const getPosts = async (req, res) => {
  // res.send("List of posts");
  try {
    console.log("Fetching posts from database");
    const postMessage = await PostMessage.find();
    res.status(200).json(postMessage);
  } catch (error) {
    res.status(404).json({ message: error.message });
  }
};

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
  //   const { id } = req.params;
};

export const deletePost = (req, res) => {
  res.send("Delete a post");
};

export const likePost = async (req, res) => {
  const { id } = req.params;
  // console.log("data post like update:", res.body);

  try {
    const post = await PostMessage.findById(id);
    // console.log("data update post like: ", post);
    if (!post) return res.status(404).json({ message: "Post not found" });

    post.likeCount = (post.likeCount || 0) + 1;
    const updated = await post.save();
    console.log("update like post: ", updated);

    res.status(200).json(updated);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
