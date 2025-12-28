// [Flutter] lib/services/friend_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
// ... các import khác

class FriendService {
  // Lưu ý: Nếu chạy máy ảo Android thì dùng 10.0.2.2, máy thật thì dùng IP Wifi
  final String baseUrl = 'http://10.0.2.2:5000/api'; 

  // ... (giữ nguyên hàm getFriendsList cũ)

  // THÊM HÀM NÀY:
  Future<bool> sendFriendRequest(String myId, String friendId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/friends/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fromId': myId,
          'toId': friendId,
        }),
      );

      if (response.statusCode == 200) {
        return true; // Gửi thành công
      } else {
        print('Lỗi gửi kết bạn: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Lỗi kết nối: $e');
      return false;
    }
  }
}