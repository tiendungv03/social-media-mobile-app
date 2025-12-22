// models/Friendship.js
const mongoose = require('mongoose');

const FriendshipSchema = new mongoose.Schema({
  requester: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'users', // Liên kết với bảng users
    required: true 
  },
  recipient: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'users', 
    required: true 
  },
  status: {
    type: String,
    enum: ['pending', 'accepted', 'rejected'], // 3 trạng thái: Chờ, Đồng ý, Từ chối
    default: 'pending'
  }
}, { timestamps: true }); // Tự động tạo createdAt, updatedAt

module.exports = mongoose.model('friendships', FriendshipSchema);