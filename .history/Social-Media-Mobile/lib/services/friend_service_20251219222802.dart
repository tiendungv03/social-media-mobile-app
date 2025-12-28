// lib/services/friend_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class FriendService {
  // LƯU Ý QUAN TRỌNG: 
  // - Nếu dùng máy ảo Android (Emulator): giữ nguyên 10.0.2.2
  // - Nếu dùng điện thoại thật: thay bằng IP Wifi của máy tính (ví dụ: http://192.168.1.5:5000/api)
  final String baseUrl = 'http://10.0.2.2:5000/api';

  // Hàm này gọi API Node.js để lấy danh sách User thật từ MongoDB
  Future<List<AppUser>> getFriendsList(String currentUserId) async {
    try {
      // Gọi API: GET /friends/suggestions/:userId
      final response = await http.get(
        Uri.parse('$baseUrl/friends/suggestions/$currentUserId'),
      );

      if (response.statusCode == 200) {
        // Parse dữ liệu JSON trả về thành List
        List<dynamic> body = jsonDecode(response.body);
        
        // Chuyển đổi từng phần tử JSON thành object AppUser
        List<AppUser> users = body.map((dynamic item) => AppUser.fromJson(item)).toList();
        return users;
      } else {
        print('Lỗi tải danh sách: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Lỗi kết nối: $e');
      return []; // Trả về rỗng nếu lỗi mạng
    }
  }

  // Hàm gửi lời mời kết bạn
  Future<bool> sendFriendRequest(String fromId, String toId) async {
    try {
      // Gọi API: POST /friends/request
      final response = await http.post(
        Uri.parse('$baseUrl/friends/request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fromId': fromId,
          'toId': toId,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        // In lỗi ra terminal để debug nếu thất bại
        print('Lỗi Server trả về: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Lỗi kết nối: $e');
      return false;
    }
  }
}