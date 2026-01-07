// lib/services/auth_service.dart

import 'package:shared_preferences/shared_preferences.dart'; // 1. Import để xóa token khi logout
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient api;
  AppUser? currentUser;

  // 👇 2. SỬA CONSTRUCTOR:
  // Cho phép khởi tạo AuthService() mà không cần truyền tham số
  // Nó sẽ tự tạo mới ApiClient() bên trong.
  AuthService() : api = ApiClient();

  // --- LOGIN ---
  Future<Map<String, dynamic>> login(String usernameOrEmail, String password) async {
    final data = await api.post('/auth/login', {
      'usernameOrEmail': usernameOrEmail,
      'password': password,
    });

    print("📢 LOG LOGIN RESPONSE: $data");

    if (data == null) throw Exception("Lỗi: Server không trả về dữ liệu.");
    if (data['token'] == null) throw Exception("Login thất bại: Thiếu Token.");

    final token = data['token'] as String;
    api.setToken(token); // Lưu token vào RAM của API Client

    // Lưu token vào bộ nhớ máy (để lần sau vào app không phải login lại)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);

    // Lưu ID user nếu cần
    if (data['user'] != null) {
      currentUser = AppUser.fromJson(data['user']);
      if (data['user']['id'] != null) {
        await prefs.setString('userId', data['user']['id']);
      }
    }

    return data;
  }

  // --- REGISTER ---
  Future<Map<String, dynamic>> register(String name, String username, String email, String password) async {
    final data = await api.post('/auth/register', {
      'name': name,
      'username': username,
      'email': email,
      'password': password,
    });

    print("📢 LOG REGISTER RESPONSE: $data");

    if (data['token'] == null) throw Exception("Register thất bại: Thiếu Token.");

    final token = data['token'] as String;
    api.setToken(token);

    // Lưu token khi đăng ký thành công luôn
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);

    if (data['user'] != null) {
      currentUser = AppUser.fromJson(data['user']);
      if (data['user']['id'] != null) {
        await prefs.setString('userId', data['user']['id']);
      }
    }

    return data;
  }

  // 👇 3. THÊM HÀM LOGOUT (QUAN TRỌNG)
  // Hàm này sẽ xóa sạch dữ liệu đăng nhập
  Future<void> logout() async {
    // 1. Xóa token trong bộ nhớ tạm của API
    try {
      api.setToken('');
    } catch (e) {
      // Bỏ qua nếu ApiClient không hỗ trợ set rỗng
    }

    // 2. Xóa token lưu trong máy (SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Xóa sạch tất cả (Token, UserId...)

    print("✅ Đã đăng xuất thành công!");
  }

  // 👇👇👇 QUÊN MẬT KHẨU
  Future<Map<String, dynamic>> forgotPassword(String email) {
    return api.post('/auth/forgot-password', {
      'email': email,
    });
  }
}