// lib/widgets/friends_tab.dart

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/friend_service.dart';
import '../screens/user_profile_screen.dart'; // Import màn hình profile

class FriendsTab extends StatefulWidget {
  // Nhận ID thật từ Home truyền sang
  final String currentUserId; 

  const FriendsTab({super.key, required this.currentUserId});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  final FriendService _friendService = FriendService();
  
  List<AppUser>? _users;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // Tải danh sách gợi ý kết bạn
  void _loadUsers() async {
    try {
      final users = await _friendService.getFriendsList(widget.currentUserId);
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Xử lý gửi lời mời
  void _handleSendRequest(AppUser user, int index) async {
    // Cập nhật giao diện giả lập trước cho mượt
    setState(() {
      if (_users != null) _users![index] = user.copyWith(status: 'pending');
    });

    bool success = await _friendService.sendFriendRequest(widget.currentUserId, user.id);

    if (!success) {
      // Nếu lỗi thì hoàn tác
      setState(() {
        if (_users != null) _users![index] = user.copyWith(status: 'none');
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi gửi lời mời')));
      }
    }
  }

  // Xử lý hủy lời mời
 // Thêm hàm xử lý Chấp nhận kết bạn (Gọi Service)
  void _handleAcceptRequest(AppUser user, int index) async {
    // 1. Cập nhật giao diện ngay lập tức
    setState(() {
       if (_users != null) _users![index] = user.copyWith(status: 'friend'); // Chuyển thành bạn bè
    });

    // 2. Gọi API (Cần bổ sung hàm acceptFriendRequest trong friend_service.dart sau)
    // Tạm thời gọi API mẫu, tí nữa ta sửa Service sau
    bool success = await _friendService.acceptFriendRequest(widget.currentUserId, user.id); 

    if (!success) {
      // Nếu lỗi thì quay lại trạng thái cũ
      setState(() {
        if (_users != null) _users![index] = user.copyWith(status: 'pending_received');
      });
    }
  }

  // Hàm vẽ nút bấm bên phải (Kết bạn / Đã gửi)
 Widget buildFriendButton(AppUser user, int index) {
    if (user.status == 'friend' || user.status == 'accepted') {
      return const Icon(Icons.check, color: Colors.green); // Đã là bạn
    } else if (user.status == 'pending') {
      // Mình gửi cho họ -> Hiện nút "Đã gửi" (Màu cam)
      return TextButton.icon(
        style: TextButton.styleFrom(
          backgroundColor: Colors.orange[50],
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        icon: const Icon(Icons.arrow_forward, size: 20, color: Colors.orange),
        label: const Text("Đã gửi", style: TextStyle(color: Colors.orange, fontSize: 13)),
        onPressed: () => _handleCancelRequest(user, index),
      );
    } else if (user.status == 'pending_received') {
      // 🔥 TRƯỜNG HỢP QUAN TRỌNG: Họ gửi cho mình -> Hiện nút "Chấp nhận" (Màu Xanh Đậm)
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          elevation: 0,
        ),
        onPressed: () => _handleAcceptRequest(user, index), // Hàm chấp nhận
        child: const Text("Chấp nhận"),
      );
    } else {
      // Người lạ -> Hiện nút thêm bạn
      return IconButton(
        icon: const Icon(Icons.person_add, color: Colors.blue),
        onPressed: () => _handleSendRequest(user, index),
      );
    }
  }