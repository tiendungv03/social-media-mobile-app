// lib/services/api_client.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  // Web vs emulator
  static final String baseUrl = kIsWeb
      ? 'http://localhost:5000/api'
      : 'http://10.0.2.2:5000/api';

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> _headers() {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (_token != null) {
      h['Authorization'] = 'Bearer $_token';
    }
    return h;
  }

  // dùng cho login, create post, v.v. (trả về object JSON)
  Future<Map<String, dynamic>> post(
      String path,
      Map<String, dynamic> body,
      ) async {
    final uri = Uri.parse('$baseUrl$path');
    final res =
    await http.post(uri, headers: _headers(), body: jsonEncode(body));

    final ct = res.headers['content-type'] ?? '';
    if (!ct.contains('application/json')) {
      final body = res.body;
      final preview = body.substring(0, body.length.clamp(0, 100));
      throw Exception('Not JSON: ${res.statusCode} $preview');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw Exception(data['message'] ?? 'Error');
    }
    return data;
  }

  // dùng cho API trả về OBJECT (vd /auth/me)
  Future<Map<String, dynamic>> getObject(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.get(uri, headers: _headers());

    final ct = res.headers['content-type'] ?? '';
    if (!ct.contains('application/json')) {
      final body = res.body;
      final preview = body.substring(0, body.length.clamp(0, 100));
      throw Exception('Not JSON: ${res.statusCode} $preview');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      throw Exception(data['message'] ?? 'Error');
    }
    return data;
  }

  // dùng cho API trả về LIST (vd /posts, /posts/user/:id)
  Future<List<dynamic>> getList(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.get(uri, headers: _headers());

    final ct = res.headers['content-type'] ?? '';
    if (!ct.contains('application/json')) {
      final body = res.body;
      final preview = body.substring(0, body.length.clamp(0, 100));
      throw Exception('Not JSON: ${res.statusCode} $preview');
    }

    final data = jsonDecode(res.body);
    if (res.statusCode >= 400) {
      throw Exception(
          (data is Map && data['message'] != null) ? data['message'] : 'Error');
    }
    return data as List<dynamic>;
  }
}
