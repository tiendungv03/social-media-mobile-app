// // lib/services/auth_service.dart

// import 'package:shared_preferences/shared_preferences.dart'; // 1. Import để xóa token khi logout
// import '../models/user.dart';
// import 'api_client.dart';

// class AuthService {
//   final ApiClient api;
//   AppUser? currentUser;

//   // 👇 2. SỬA CONSTRUCTOR:
//   // Cho phép khởi tạo AuthService() mà không cần truyền tham số
//   // Nó sẽ tự tạo mới ApiClient() bên trong.
//   AuthService() : api = ApiClient();

//   // --- LOGIN ---
//   Future<Map<String, dynamic>> login(String usernameOrEmail, String password) async {
//     final data = await api.post('/auth/login', {
//       'usernameOrEmail': usernameOrEmail,
//       'password': password,
//     });

//     print("📢 LOG LOGIN RESPONSE: $data");

//     if (data == null) throw Exception("Lỗi: Server không trả về dữ liệu.");
//     if (data['token'] == null) throw Exception("Login thất bại: Thiếu Token.");

//     final token = data['token'] as String;
//     api.setToken(token); // Lưu token vào RAM của API Client

//     // Lưu token vào bộ nhớ máy (để lần sau vào app không phải login lại)
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('token', token);

//     // Lưu ID user nếu cần
//     if (data['user'] != null) {
//       currentUser = AppUser.fromJson(data['user']);
//       if (data['user']['id'] != null) {
//         await prefs.setString('userId', data['user']['id']);
//       }
//     }

//     return data;
//   }

//   // --- REGISTER ---
//   Future<Map<String, dynamic>> register(String name, String username, String email, String password) async {
//     final data = await api.post('/auth/register', {
//       'name': name,
//       'username': username,
//       'email': email,
//       'password': password,
//     });

//     print("📢 LOG REGISTER RESPONSE: $data");

//     if (data['token'] == null) throw Exception("Register thất bại: Thiếu Token.");

//     final token = data['token'] as String;
//     api.setToken(token);

//     // Lưu token khi đăng ký thành công luôn
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('token', token);

//     if (data['user'] != null) {
//       currentUser = AppUser.fromJson(data['user']);
//       if (data['user']['id'] != null) {
//         await prefs.setString('userId', data['user']['id']);
//       }
//     }

//     return data;
//   }

//   // 👇 3. THÊM HÀM LOGOUT (QUAN TRỌNG)
//   // Hàm này sẽ xóa sạch dữ liệu đăng nhập
//   Future<void> logout() async {
//     // 1. Xóa token trong bộ nhớ tạm của API
//     try {
//       api.setToken('');
//     } catch (e) {
//       // Bỏ qua nếu ApiClient không hỗ trợ set rỗng
//     }

//     // 2. Xóa token lưu trong máy (SharedPreferences)
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear(); // Xóa sạch tất cả (Token, UserId...)

//     print("✅ Đã đăng xuất thành công!");
//   }
// }



// lib/services/auth_service.dart

import 'dart:convert'; // 👈 Cần cái này để giải mã JSON
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient api;
  AppUser? currentUser;

  // Khởi tạo
  AuthService() : api = ApiClient();

  // --- LOGIN ---
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      // 1. Gọi API (Trả về Response)
      final response = await api.post('/auth/login', {
        'email': email, // Backend dùng 'email', code bạn dùng 'usernameOrEmail' coi chừng lệch
        'password': password,
      });

      print("📢 LOG LOGIN STATUS: ${response.statusCode}");
      print("📢 LOG LOGIN BODY: ${response.body}");

      if (response.statusCode == 200) {
        // 2. Giải mã JSON
        final data = jsonDecode(response.body);

        // 3. Lấy Token & ID
        final token = data['token'];
        // 👇 MongoDB trả về '_id', không phải 'id'
        final userId = data['user']['_id'] ?? data['user']['id']; 

        // 4. Lưu Token vào ApiClient (Dùng biến static)
        ApiClient.token = token; 

        // 5. Lưu vào bộ nhớ máy (SharedPreferences)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        if (userId != null) {
          await prefs.setString('userId', userId);
        }
        
        // 6. Lưu thông tin user vào biến tạm
        if (data['user'] != null) {
           // Đảm bảo Model User của bạn khớp với JSON trả về
           // currentUser = AppUser.fromJson(data['user']); 
        }

        return data;
      } else {
        throw Exception(jsonDecode(response.body)['msg'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      print("❌ Lỗi Login: $e");
      return null;
    }
  }

  // --- REGISTER ---
  Future<Map<String, dynamic>?> register(String name, String username, String email, String password) async {
    try {
      final response = await api.post('/auth/register', {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Logic lưu token giống login
        final token = data['token'];
        ApiClient.token = token;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        
        final userId = data['user']['_id'];
        if (userId != null) await prefs.setString('userId', userId);

        return data;
      } else {
        throw Exception(jsonDecode(response.body)['msg'] ?? 'Đăng ký thất bại');
      }
    } catch (e) {
      print("❌ Lỗi Register: $e");
      return null;
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    // 1. Xóa token trong RAM
    ApiClient.token = null;

    // 2. Xóa token trong ổ cứng máy
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    print("✅ Đã đăng xuất thành công!");
  }
}