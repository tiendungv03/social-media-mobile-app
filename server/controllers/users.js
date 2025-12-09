import User from "../models/userModel.js";

export const getUsers = async (req, res) => {
  try {
    console.log("Fetching users from database");
    const users = await User.find();
    res.status(200).json(users);
  } catch (error) {
    res.status(404).json({ message: error.message });
  }
};

export const registerUser = async (req, res) => {
  const { name, username, email, passwordHash } = req.body;
  console.log("BODY REGISTER:", req.body);

  try {
    const existingUser = await User.findOne({ username });
    if (existingUser) {
      return res.status(400).json({ message: "User already exists" });
    }

    const newUser = new User({ name, username, email, passwordHash });
    console.log("test data", newUser);
    await newUser.save();

    res.status(201).json({ message: "User registered successfully" });
  } catch (error) {
    console.error("REGISTER ERROR >>>", error);
    res.status(500).json({ message: "Something went wrong" });
  }
};

export const loginUser = async (req, res) => {
  const { username, passwordHash } = req.body;

  try {
    const user = await User.findOne({ username });
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    if (user.passwordHash !== passwordHash) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    res.status(200).json({ message: "Login successful", user });
  } catch (error) {
    res.status(500).json({ message: "Something went wrong" });
  }
};

// export const updateUser = async (req, res) => {
