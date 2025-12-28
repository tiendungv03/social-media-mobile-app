// services/friend_service.dart
import '../models/user.dart';
import '../models/friends.dart'; // Nếu dùng model này

class FriendService {
  // Hàm lấy danh sách bạn bè (Giả lập hoặc gọi API)
  Future<List<AppUser>> getFriendsList(String userId) async {
    // Code gọi API backend để lấy list bạn bè
    // Tạm thời return mock data như bạn đã làm
    await Future.delayed(const Duration(seconds: 1));
    return [/* List các user bạn bè */];
  }

  // Hàm gửi lời mời kết bạn
  Future<bool> sendFriendRequest(String fromId, String toId) async {
    // Gọi API gửi lời mời
    return true;
  }
}
