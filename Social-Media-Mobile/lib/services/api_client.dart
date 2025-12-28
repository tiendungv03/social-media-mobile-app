// lib/services/api_client.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // 👈 1. Import thư viện này

class ApiClient {
  // Singleton
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // Web vs emulator
  static final String baseUrl = kIsWeb
      ? 'http://localhost:5000/api'
      : 'http://10.0.2.2:5000/api';

  String? _token;

  // 👇 2. SỬA HÀM NÀY: Lưu token vào bộ nhớ máy (Cần async)
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token); // Lưu vĩnh viễn
    if (kDebugMode) {
      print("✅ ApiClient đã lưu token vào bộ nhớ máy: $token");
    }
  }

  // 👇 3. THÊM HÀM NÀY: Để khôi phục token khi vừa mở App (F5)
  Future<void> loadTokenFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      if (kDebugMode) print("✅ Đã khôi phục Token từ bộ nhớ: $_token");
    } else {
      if (kDebugMode) print("⚠️ Không tìm thấy Token cũ.");
    }
  }

  // 👇 4. THÊM HÀM NÀY: Đăng xuất và xóa token
  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    print("👋 Đã đăng xuất và xóa Token.");
  }

  Map<String, String> _headers() {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (_token != null && _token!.isNotEmpty) {
      h['Authorization'] = 'Bearer $_token';
    }
    return h;
  }

  // --- 1. POST ---
  Future<Map<String, dynamic>> post(
      String path,
      Map<String, dynamic> body,
      ) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.post(uri, headers: _headers(), body: jsonEncode(body));

    final ct = res.headers['content-type'] ?? '';
    if (!ct.contains('application/json')) {
      final body = res.body;
      final preview = body.length > 100 ? body.substring(0, 100) : body;
      throw Exception('Not JSON (POST): ${res.statusCode} $preview');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw Exception(data['message'] ?? 'Error');
    }
    return data;
  }

  // --- 2. GET OBJECT ---
  Future<Map<String, dynamic>> getObject(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.get(uri, headers: _headers());

    final ct = res.headers['content-type'] ?? '';
    if (!ct.contains('application/json')) {
      final body = res.body;
      final preview = body.length > 100 ? body.substring(0, 100) : body;
      throw Exception('Not JSON (GET OBJ): ${res.statusCode} $preview');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw Exception(data['message'] ?? 'Error');
    }
    return data;
  }

  // --- 3. GET LIST ---
  Future<List<dynamic>> getList(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.get(uri, headers: _headers());

    final ct = res.headers['content-type'] ?? '';
    if (!ct.contains('application/json')) {
      final body = res.body;
      final preview = body.length > 100 ? body.substring(0, 100) : body;
      throw Exception('Not JSON (GET LIST): ${res.statusCode} $preview');
    }

    final data = jsonDecode(res.body);
    if (res.statusCode >= 400) {
      throw Exception(
          (data is Map && data['message'] != null) ? data['message'] : 'Error');
    }
    return data as List<dynamic>;
  }

  // --- 4. DELETE ---
  Future<dynamic> delete(String path) async {
    final url = Uri.parse('$baseUrl$path');
    final response = await http.delete(url, headers: _headers());

    if (response.statusCode == 200 || response.statusCode == 204) {
      if (response.body.isEmpty) return {};
      final ct = response.headers['content-type'] ?? '';
      if (ct.contains('application/json')) {
        return jsonDecode(response.body);
      }
      return {};
    } else {
      throw Exception('Lỗi xóa dữ liệu: ${response.statusCode}');
    }
  }
}