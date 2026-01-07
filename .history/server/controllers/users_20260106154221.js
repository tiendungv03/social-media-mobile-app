// SỬA DÒNG NÀY: Thêm dấu ngoặc nhọn { } để import đúng
import User from "../models/user.model.js";

// API: Lấy danh sách tất cả user
export const getUsers = async (req, res) => {
  try {
    console.log("Fetching users from database");
    const users = await User.find();
    res.status(200).json(users);
  } catch (error) {
    res.status(404).json({ message: error.message });
  }
};

// API: Đăng ký thành viên mới
export const registerUser = async (req, res) => {
  const { name, username, email, passwordHash } = req.body;
  console.log("BODY REGISTER:", req.body);

  try {
    // Kiểm tra xem username đã tồn tại chưa
    const existingUser = await User.findOne({ username });
    if (existingUser) {
      return res.status(400).json({ message: "User already exists" });
    }

    // Tạo user mới
    const newUser = new User({ name, username, email, passwordHash });
    console.log("test data", newUser);
    
    // Lưu vào database
    await newUser.save();

    res.status(201).json({ message: "User registered successfully" });
  } catch (error) {
    console.error("REGISTER ERROR >>>", error);
    res.status(500).json({ message: "Something went wrong" });
  }
};

// API: Đăng nhập
export const loginUser = async (req, res) => {
  const { username, passwordHash } = req.body;

  try {
    // Tìm user theo username
    const user = await User.findOne({ username });
    
    // Nếu không thấy user
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Kiểm tra mật khẩu (Lưu ý: Mật khẩu này đang so sánh chuỗi thô, chưa mã hóa)
    if (user.passwordHash !== passwordHash) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    // Đăng nhập thành công
    res.status(200).json({ message: "Login successful", user });
  } catch (error) {
    res.status(500).json({ message: "Something went wrong" });
  }
};

//Search User
export const searchUsers = async (req, res) => {
  try {
    const { q } = req.query; // Lấy từ khóa tìm kiếm từ URL (ví dụ: ?q=dieubui)
    
    if (!q) {
      return res.json([]); // Nếu không nhập gì thì trả về danh sách rỗng
    }

    // Tìm trong Database
    const users = await User.find({
      $or: [
        { username: { $regex: q, $options: "i" } }, // Tìm theo tên đăng nhập (không phân biệt hoa thường)
        { name: { $regex: q, $options: "i" } }      // Tìm theo tên hiển thị
      ]
    }).select("username name avatarUrl"); // Chỉ lấy các thông tin cần thiết để hiện ra

    res.json(users);
  } catch (error) {
    console.error("SEARCH ERROR:", error);
    res.status(500).json({ message: "Lỗi tìm kiếm người dùng" });
  }
};