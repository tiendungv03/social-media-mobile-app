// // lib/widgets/friends_tab.dart
//
// import 'package:flutter/material.dart';
// import '../models/user.dart';
// import '../services/friend_service.dart';
// import '../screens/user_profile_screen.dart';
//
// class FriendsTab extends StatefulWidget {
//   final String currentUserId;
//
//   const FriendsTab({super.key, required this.currentUserId});
//
//   @override
//   State<FriendsTab> createState() => _FriendsTabState();
// }
//
// class _FriendsTabState extends State<FriendsTab> {
//   final FriendService _friendService = FriendService();
//
//   List<AppUser>? _users;
//   bool _isLoading = true;
//   String? _error;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUsers();
//   }
//
//   void _loadUsers() async {
//     try {
//       final users = await _friendService.getFriendsList(widget.currentUserId);
//       if (mounted) {
//         setState(() {
//           _users = users;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _error = e.toString();
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   // 1. Hàm GỬI lời mời
//   void _handleSendRequest(AppUser user, int index) async {
//     setState(() {
//       if (_users != null) _users![index] = user.copyWith(status: 'pending');
//     });
//
//     bool success = await _friendService.sendFriendRequest(widget.currentUserId, user.id);
//
//     if (!success) {
//       setState(() {
//         if (_users != null) _users![index] = user.copyWith(status: 'none');
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi gửi lời mời')));
//       }
//     }
//   }
//
//   // 2. Hàm HỦY lời mời (Đây là hàm bạn đang bị thiếu)
//   void _handleCancelRequest(AppUser user, int index) async {
//     setState(() {
//       if (_users != null) _users![index] = user.copyWith(status: 'none');
//     });
//
//     bool success = await _friendService.cancelFriendRequest(widget.currentUserId, user.id);
//
//     if (!success) {
//       setState(() {
//         if (_users != null) _users![index] = user.copyWith(status: 'pending');
//       });



import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/friend_service.dart';
import '../screens/user_profile_screen.dart';

class FriendsTab extends StatefulWidget {
  final String currentUserId;

  const FriendsTab({super.key, required this.currentUserId});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  // Vì mình đã khai báo 'friendService' toàn cục ở file service rồi,
  // nên ở đây dùng trực tiếp biến đó hoặc khởi tạo mới đều được.
  // Để an toàn, dùng biến toàn cục import từ file service:
  final _service = friendService;

  List<AppUser>? _users;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    try {
      final users = await _service.getFriendsList(widget.currentUserId);
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

  // 1. Hàm GỬI lời mời
  void _handleSendRequest(AppUser user, int index) async {
    setState(() {
      if (_users != null) _users![index] = user.copyWith(status: 'pending');
    });

    // 👇 ĐÃ SỬA: Chỉ truyền user.id (không truyền widget.currentUserId nữa)
    bool success = await _service.sendFriendRequest(widget.currentUserId,user.id);


    if (!success) {
      setState(() {
        if (_users != null) _users![index] = user.copyWith(status: 'none');
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi gửi lời mời')));
      }
    }
  }

  // 2. Hàm HỦY lời mời
  void _handleCancelRequest(AppUser user, int index) async {
    setState(() {
      if (_users != null) _users![index] = user.copyWith(status: 'none');
    });

    // 👇 ĐÃ SỬA: Chỉ truyền user.id
    bool success = await _service.cancelFriendRequest(widget.currentUserId,user.id);

    if (!success) {
      setState(() {
        if (_users != null) _users![index] = user.copyWith(status: 'pending');
      });
    }
  }

  // 3. Hàm CHẤP NHẬN lời mời
  void _handleAcceptRequest(AppUser user, int index) async {
    setState(() {
      if (_users != null) _users![index] = user.copyWith(status: 'friend');
    });

    // 👇 ĐÃ SỬA: Chỉ truyền user.id
    bool success = await _service.acceptFriendRequest(widget.currentUserId,user.id);

    if (!success) {
      setState(() {
        if (_users != null) _users![index] = user.copyWith(status: 'pending_received');
      });
    }
  }

  Widget buildFriendButton(AppUser user, int index) {
    if (user.status == 'friend' || user.status == 'accepted') {
      // ✅ Code mới: Hiện nút "Bạn bè" màu xám (Giống Facebook/Insta)
      return OutlinedButton.icon(
        onPressed: () {
          // Có thể thêm hành động: Nhắn tin hoặc Hủy kết bạn
          _handleCancelRequest(user, index); // Ví dụ: Bấm vào thì hủy bạn
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          foregroundColor: Colors.black87,
        ),
        icon: const Icon(Icons.check, size: 16, color: Colors.green),
        label: const Text("Bạn bè"),
      );


    } else if (user.status == 'pending') {
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
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          elevation: 0,
        ),
        onPressed: () => _handleAcceptRequest(user, index),
        child: const Text("Chấp nhận"),
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(
                    user: user,
                    userId: user.id,
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
