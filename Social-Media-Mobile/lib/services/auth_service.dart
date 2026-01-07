import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient api;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  AuthService() : api = ApiClient();

  Future<Map<String, dynamic>?> login(String usernameOrEmail, String password) async {
    try {
      final res = await api.post('/auth/login', {
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      });

      final data = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode >= 400) {
        throw Exception(data['message'] ?? 'Đăng nhập thất bại');
      }

      final token = (data['token'] ?? '').toString();
      if (token.isEmpty) throw Exception('Server không trả token');

      // ✅ QUAN TRỌNG: dùng api.setToken để đồng bộ _token + static token + SharedPreferences(auth_token)
      await api.setToken(token);

      // set currentUser
      final u = data['user'];
      if (u is Map<String, dynamic>) {
        _currentUser = AppUser.fromJson(u);
        final userId = (u['_id'] ?? u['id'] ?? '').toString();
        if (userId.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);
        }
      }

      return data;
    } catch (e) {
      print("❌ Lỗi Login: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> register(
      String name,
      String username,
      String email,
      String password,
      ) async {
    try {
      final res = await api.post('/auth/register', {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
      });

      final data = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode >= 400) {
        throw Exception(data['message'] ?? 'Đăng ký thất bại');
      }

      final token = (data['token'] ?? '').toString();
      if (token.isEmpty) throw Exception('Server không trả token');

      await api.setToken(token);

      final u = data['user'];
      if (u is Map<String, dynamic>) {
        _currentUser = AppUser.fromJson(u);
        final userId = (u['_id'] ?? u['id'] ?? '').toString();
        if (userId.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);
        }
      }

      return data;
    } catch (e) {
      print("❌ Lỗi Register: $e");
      return null;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await api.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }


  // 👇👇👇 QUÊN MẬT KHẨU
  Future<Map<String, dynamic>?> forgotPassword(String email) async {
    try {
      final res = await api.post('/auth/forgot-password', {
        'email': email,
      });

      final data = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode >= 400) {
        throw Exception(data['message'] ?? 'Gửi email quên mật khẩu thất bại');
      }

      return data;
    } catch (e) {
      print("❌ Lỗi forgotPassword: $e");
      return null;
    }
  }


}
