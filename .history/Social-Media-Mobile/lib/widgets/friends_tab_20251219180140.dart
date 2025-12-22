import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/friend_service.dart';

class FriendsTab extends StatelessWidget {
  FriendsTab({super.key});

  final FriendService _friendService = FriendService();

  // Giả lập ID của người đang dùng App (Sau này lấy từ Auth)
  final String currentUserId = 'user_id_cua_toi_123'; 

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppUser>>(
      // Gọi API lấy danh sách gợi ý bạn bè
      future: _friendService.getFriendsList(currentUserId), 
      
      builder: (context, snap) {
        // 1. Đang tải
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Có lỗi
        if (snap.hasError) {
          return Center(child: Text('Lỗi: ${snap.error}'));
        }

        // 3. Không có dữ liệu
        final users = snap.data ?? [];
        if (users.isEmpty) {
          return const Center(child: Text('Không có gợi ý kết bạn nào'));
        }

        // 4. Có dữ liệu -> Hiển thị danh sách
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final user = users[index];
            
            return ListTile(
               leading: CircleAvatar(
                 // Nếu không có avatar thì hiện chữ cái đầu
                 child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?'),
               ),
               title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
               subtitle: Text(user.email),
               
               // --- PHẦN QUAN TRỌNG: NÚT THÊM BẠN BÈ ---
               trailing: IconButton(
                 icon: const Icon(Icons.person_add, color: Colors.blue),
                 tooltip: 'Kết bạn',
                 onPressed: () async {
                   // Gọi hàm gửi lời mời từ Service
                   bool success = await _friendService.sendFriendRequest(currentUserId, user.id);

                   // Hiển thị thông báo kết quả (SnackBar)
                   if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                         content: Text(success ? 'Đã gửi lời mời tới ${user.name}!' : 'Gửi thất bại (Có thể đã gửi rồi)'),
                         backgroundColor: success ? Colors.green : Colors.red,
                         duration: const Duration(seconds: 2),
                       ),
                     );
                   }
                 },
               ),
            );
          },
        );
      },
    );
  }
}