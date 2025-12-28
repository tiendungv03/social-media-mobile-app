// lib/services/profile_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  // Hàm lấy URL tự động (Web/Android/Windows)
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:5000/api';
    } catch (e) {}
    return 'http://localhost:5000/api';
  }

  // Hàm gọi API lấy thông tin Profile
  Future<Map<String, dynamic>> getUserProfile(String targetId, String currentId) async {
    final url = '$baseUrl/users/profile/$targetId?currentUserId=$currentId';
    print("Fetching profile: $url");

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Lỗi tải profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getUserProfile: $e');
      rethrow;
    }
  }


  // 👇 THÊM HÀM NÀY: Gọi API Update Profile
  Future<bool> updateProfile(String userId, String name, String bio, String avatarUrl) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/update/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'bio': bio,
          'avatarUrl': avatarUrl,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi update profile: $e");
      return false;
    }
  }
}