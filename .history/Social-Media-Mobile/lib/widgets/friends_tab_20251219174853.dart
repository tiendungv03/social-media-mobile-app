import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/friend_service.dart'; // <--- SỬA 1: Import đúng file service của bạn

class FriendsTab extends StatelessWidget {
  FriendsTab({super.key}); // <--- SỬA 2: Bỏ 'const' ở đây vì service không phải hằng số

  // <--- SỬA 3: Khởi tạo FriendService thay vì MockFriendsRepo
  final FriendService _friendService = FriendService(); 

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppUser>>(
      // <--- SỬA 4: Gọi hàm getFriendsList() mà bạn đã viết trong service
      future: _friendService.getFriendsList('1'), 
      
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }

        final users = snap.data ?? [];
        if (users.isEmpty) {
          return const Center(child: Text('No suggestions'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final u = users[index];
            // Phần hiển thị bên dưới giữ nguyên code của bạn
            return ListTile(
               leading: CircleAvatar(child: Text(u.name[0])),
               title: Text(u.name),
               subtitle: Text(u.email),
            );
          },
        );
      },
    );
  }
}