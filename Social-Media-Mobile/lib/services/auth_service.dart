// lib/services/auth_service.dart

import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient api;
  AppUser? currentUser;

  AuthService(this.api);

  // 👇 1. Login có trả về dữ liệu và log chi tiết
  Future<Map<String, dynamic>> login(String usernameOrEmail, String password) async {
    final data = await api.post('/auth/login', {
      'usernameOrEmail': usernameOrEmail,
      'password': password,
    });

    // 🔍 DEBUG: In ra console để xem Server trả về cái gì
    print("📢 LOG LOGIN RESPONSE: $data");

    // 🛡️ BẢO VỆ: Kiểm tra token trước khi ép kiểu
    if (data == null) {
      throw Exception("Lỗi: Server không trả về dữ liệu (null).");
    }

    if (data['token'] == null) {
      // Nếu không có token, in lỗi ra console và ném ngoại lệ để UI biết
      print("❌ LỖI: Không tìm thấy 'token' trong phản hồi của server.");
      throw Exception("Login thất bại: Server không trả về Token. Data: $data");
    }

    // Nếu có token thì mới lưu
    final token = data['token'] as String;
    api.setToken(token);

    // Lưu thông tin user nếu có
    if (data['user'] != null) {
      currentUser = AppUser.fromJson(data['user']);
    }

    return data; // Trả về dữ liệu cho màn hình Login
  }

  // 👇 2. Register tương tự
  Future<Map<String, dynamic>> register(String name, String username, String email, String password) async {
    final data = await api.post('/auth/register', {
      'name': name,
      'username': username,
      'email': email,
      'password': password,
    });

    print("📢 LOG REGISTER RESPONSE: $data");

    if (data['token'] == null) {
      throw Exception("Register thất bại: Server không trả về Token.");
    }

    final token = data['token'] as String;
    api.setToken(token);

    if (data['user'] != null) {
      currentUser = AppUser.fromJson(data['user']);
    }

    return data;
  }
}