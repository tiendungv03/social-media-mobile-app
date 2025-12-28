// lib/services/friend_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class FriendService {
  // Lưu ý: Máy ảo Android dùng 10.0.2.2, máy thật dùng IP Wifi (VD: 192.168.1.5)
  final String baseUrl = 'http://10.0.2.2:5000/api';

 Future<List<AppUser>> getFriendsList(String currentUserId) async {
    try {
      // Gọi API vừa viết ở Bước 1
      final response = await http.get(
        Uri.parse('$baseUrl/friends/suggestions/$currentUserId'),
      );

      if (response.statusCode == 200) {
        // Parse dữ liệu JSON trả về thành List<AppUser>
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

  Future<bool> sendFriendRequest(String fromId, String toId) async {
    try {
      // SỬA 1: Đổi '/add' thành '/request' cho khớp với Backend
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
        // In lỗi ra để debug nếu thất bại
        print('Lỗi Server trả về: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Lỗi kết nối: $e');
      return false;
    }
  }
}