// // // lib/services/friend_service.dart
// // import 'dart:convert';
// // import 'package:http/http.dart' as http;
// // import '../models/user.dart';
//
// // class FriendService {
// //   // - Nếu dùng máy ảo Android (Emulator): giữ nguyên 10.0.2.2
// //   // - Nếu dùng điện thoại thật: thay bằng IP Wifi của máy tính (ví dụ: http://192.168.1.5:5000/api)
// //   final String baseUrl = 'http://localhost:5000/api';
//
// //   // Hàm này gọi API Node.js để lấy danh sách User thật từ MongoDB
// //   Future<List<AppUser>> getFriendsList(String currentUserId) async {
// //     try {
// //       print('Đang gọi API: $baseUrl/friends/suggestions/$currentUserId'); // In ra để check link
//
// //       final response = await http.get(
// //         Uri.parse('$baseUrl/friends/suggestions/$currentUserId'),
// //       );
//
// //       print('Server trả về code: ${response.statusCode}'); // Check mã lỗi (200, 404, 500?)
//
// //       if (response.statusCode == 200) {
// //         List<dynamic> body = jsonDecode(response.body);
// //         print('Dữ liệu nhận được: $body'); // In ra xem có phải [] không?
//
// //         return body.map((dynamic item) => AppUser.fromJson(item)).toList();
// //       } else {
// //         // Đừng return [], hãy ném lỗi để biết
// //         throw Exception('Lỗi Server: ${response.statusCode} - ${response.body}');
// //       }
// //     } catch (e) {
// //       print('Lỗi Chết người: $e'); // Xem lỗi gì ở đây
// //       rethrow; // Ném lỗi ra ngoài để màn hình hiện đỏ lên
// //     }
// //   }
//
// //   // Hàm gửi lời mời kết bạn
// //   Future<bool> sendFriendRequest(String fromId, String toId) async {
// //     try {
// //       // Gọi API: POST /friends/request
// //       final response = await http.post(
// //         Uri.parse('$baseUrl/friends/request'),
// //         headers: {'Content-Type': 'application/json'},
// //         body: jsonEncode({
// //           'fromId': fromId,
// //           'toId': toId,
// //         }),
// //       );
//
// //       if (response.statusCode == 200) {
// //         return true;
// //       } else {
// //         // In lỗi ra terminal để debug nếu thất bại
// //         print('Lỗi Server trả về: ${response.body}');
// //         return false;
// //       }
// //     } catch (e) {
// //       print('Lỗi kết nối: $e');
// //       return false;
// //     }
// //   }
// // }
//
//


// // lib/services/friend_service.dart
//
// import 'dart:convert';
// import 'dart:io'; // Cần thêm thư viện này để check Platform (Android/iOS/Windows)
// import 'package:flutter/foundation.dart'; // Cần thêm để check kIsWeb
// import 'package:http/http.dart' as http;
// import '../models/user.dart';
//
// class FriendService {
//   // --- 1. Cấu hình URL thông minh (Tự động đổi theo thiết bị) ---
//   String get baseUrl {
//     // Nếu đang chạy trên Web -> Dùng localhost
//     if (kIsWeb) {
//       return 'http://localhost:5000/api';
//     }
//     // Nếu đang chạy trên Android Emulator -> Dùng 10.0.2.2
//     try {
//       if (Platform.isAndroid) {
//         return 'http://10.0.2.2:5000/api';
//       }
//     } catch (e) {
//       // Bỏ qua lỗi check platform trên web
//     }
//     // Các trường hợp còn lại (Windows, iOS Simulator, Máy thật chung mạng) -> Dùng localhost
//     // Lưu ý: Nếu dùng điện thoại thật, bạn hãy đổi dòng dưới thành IP máy tính (VD: 'http://192.168.1.5:5000/api')
//     return 'http://localhost:5000/api';
//   }
//
//   // --- 2. Hàm lấy danh sách gợi ý kết bạn ---
//   Future<List<AppUser>> getFriendsList(String currentUserId) async {
//     try {
//       final url = '$baseUrl/friends/suggestions/$currentUserId';
//       print('🌐 Đang gọi API: $url');
//
//       final response = await http.get(Uri.parse(url));
//
//       print('📡 Server trả về code: ${response.statusCode}');
//
//       if (response.statusCode == 200) {
//         List<dynamic> body = jsonDecode(response.body);
//         print('📦 Dữ liệu nhận được: $body');
//
//         // Map từ JSON sang List<AppUser>
//         // Nhờ file user.dart đã sửa, dòng này giờ đây "miễn nhiễm" với lỗi status boolean
//         return body.map((dynamic item) => AppUser.fromJson(item)).toList();
//       } else {
//         throw Exception('Lỗi Server: ${response.statusCode} - ${response.body}');
//       }
//     } catch (e) {
//       print('❌ Lỗi getFriendsList: $e');
//       rethrow; // Ném lỗi ra để UI (FriendsTab) hiện thông báo hoặc icon xoay
//     }
//   }
//
//   // --- 3. Hàm gửi lời mời kết bạn ---
//   Future<bool> sendFriendRequest(String fromId, String toId) async {
//     try {
//       final url = '$baseUrl/friends/request';
//       print('📨 Đang gửi lời mời tới: $url');
//
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'fromId': fromId,
//           'toId': toId,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         print('✅ Gửi thành công!');
//         return true;
//       } else {
//         print('⚠️ Lỗi Server trả về: ${response.body}');
//         return false;
//       }
//     } catch (e) {
//       print('❌ Lỗi kết nối khi gửi lời mời: $e');
//       return false;
//     }
//   }
//
//   // Thêm hàm này vào trong class FriendService _/HUY LOI MOI KET BAN /
//   Future<bool> cancelFriendRequest(String fromId, String toId) async {
//     try {
//       final url = '$baseUrl/friends/cancel'; // Gọi API hủy (Lưu ý đường dẫn API)
//       print('🗑️ Đang hủy lời mời tại: $url');
//
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'fromId': fromId,
//           'toId': toId,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         print('✅ Đã hủy lời mời thành công!');
//         return true;
//       } else {
//         print('⚠️ Lỗi Server khi hủy: ${response.body}');
//         return false;
//       }
//     } catch (e) {
//       print('❌ Lỗi kết nối khi hủy: $e');
//       return false;
//     }
//   }
//
//
//   // API Chấp nhận kết bạn
//   Future<bool> acceptFriendRequest(String fromId, String toId) async {
//     try {
//       // Gọi đúng API /accept vừa viết ở Backend
//       final url = '$baseUrl/friends/accept';
//
//       final response = await http.put(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'fromId': fromId, // ID của mình (người bấm chấp nhận)
//           'toId': toId,     // ID của người gửi lời mời
//         }),
//       );
//
//       return response.statusCode == 200;
//     } catch (e) {
//       print('❌ Lỗi accept: $e');
//       return false;
//     }
//   }
//
//
//   // 👇 Lấy danh sách bạn bè (Followers/Following)
//   Future<List<AppUser>> getAcceptedFriends(String userId) async {
//     try {
//       final response = await http.get(Uri.parse('$baseUrl/friends/list/$userId'));
//
//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         return data.map((json) => AppUser.fromJson(json)).toList();
//       } else {
//         return [];
//       }
//     } catch (e) {
//       print("Lỗi lấy danh sách bạn: $e");
//       return [];
//     }
//   }
//
// }

import 'dart:convert';
import '../main.dart'; // 👈 Bắt buộc phải có dòng này để dùng biến 'api'
import '../models/user.dart';

class FriendService {

  // 1. Lấy danh sách gợi ý
  Future<List<AppUser>> getFriendsList(String currentUserId) async {
    try {
      final response = await apiClient.get('/friends/suggestions/$currentUserId');
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => AppUser.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 2. Gửi lời mời (Cần ID của mình + ID người nhận)
  Future<bool> sendFriendRequest(String myId, String targetUserId) async {
    try {
      final response = await apiClient.post('/friends/request/$targetUserId', {
        'currentUserId': myId // 👈 CHÌA KHÓA QUAN TRỌNG ĐÂY!
      });
      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi gửi lời mời: $e");
      return false;
    }
  }

  // 3. Hủy lời mời / Hủy kết bạn
  Future<bool> cancelFriendRequest(String myId, String targetUserId) async {
    try {
      // Backend của bạn dùng route: /unfriend/:toId
      // Lưu ý: Mình đổi thành /unfriend cho khớp với file route bạn gửi
      final response = await apiClient.post('/friends/unfriend/$targetUserId', {
        'currentUserId': myId // 👈 Server bắt buộc có cái này
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 4. Chấp nhận
  Future<bool> acceptFriendRequest(String myId, String targetUserId) async {
    try {
      final response = await apiClient.put('/friends/accept/$targetUserId', {
        'currentUserId': myId
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 5. Lấy danh sách bạn bè
  Future<List<AppUser>> getAcceptedFriends(String userId) async {
    try {
      final response = await apiClient.get('/friends/list/$userId');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => AppUser.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

final friendService = FriendService();