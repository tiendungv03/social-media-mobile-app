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
  void _handleCancelRequest(AppUser user, int index) async {
    setState(() {
      if (_users != null) _users![index] = user.copyWith(status: 'none');
    });

    bool success = await _friendService.cancelFriendRequest(widget.currentUserId, user.id);

    if (!success) {
      setState(() {
        if (_users != null) _users![index] = user.copyWith(status: 'pending');
      });
    }
  }

  // Hàm vẽ nút bấm bên phải (Kết bạn / Đã gửi)
  Widget buildFriendButton(AppUser user, int index) {
    if (user.status == 'friend' || user.status == 'accepted') {
      return const Icon(Icons.check, color: Colors.green);
    } else if (user.status == 'pending' || user.status == 'pending_sent') {
      return TextButton.icon(
        style: TextButton.styleFrom(
          backgroundColor: Colors.orange[50],
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        icon: const Icon(Icons.arrow_forward, size: 20, color: Colors.orange),
        label: const Text("Đã gửi", style: TextStyle(color: Colors.orange, fontSize: 13)),
        onPressed: () => _handleCancelRequest(user, index),
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.person_add, color: Colors.blue),
        onPressed: () => _handleSendRequest(user, index),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Lỗi: $_error'));
    if (_users == null || _users!.isEmpty) return const Center(child: Text('Không có gợi ý kết bạn nào'));

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _users!.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final AppUser user = _users![index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            
            // 👇 SỰ KIỆN QUAN TRỌNG: BẤM VÀO SANG TRANG PROFILE 👇
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(
                    user: user,
                    // ✅ QUAN TRỌNG: Truyền ID thật sang để bên kia check follow
                    currentUserId: widget.currentUserId, 
                  ),
                ),
              );
            },

            leading: CircleAvatar(
              backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
              child: user.avatarUrl.isEmpty ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?') : null,
            ),
            title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(user.email),
            trailing: buildFriendButton(user, index),
          );
        },
      ),
    );
  }
}