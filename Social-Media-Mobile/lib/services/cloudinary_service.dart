// services/cloudinary_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName;
  final String uploadPreset;

  CloudinaryService({
    required this.cloudName,
    required this.uploadPreset,
  });

  // Sử dụng cấu hình thật bạn đã cung cấp trong đoạn code cũ
  factory CloudinaryService.defaultConfig() {
    return CloudinaryService(
      cloudName: 'dzh18qpra',
      uploadPreset: 'social_app_unsigned',
    );
  }

  Future<String> uploadBytes({
    required Uint8List bytes,
    required String filename,
    String folder = 'posts',
  }) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    try {
      final req = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = folder
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: filename,
          ),
        );

      final streamed = await req.send();
      final resp = await http.Response.fromStream(streamed);
      final data = jsonDecode(resp.body);

      if (resp.statusCode == 200) {
        // Ưu tiên lấy secure_url
        return (data['secure_url'] ?? data['url']).toString();
      } else {
        // In lỗi chi tiết ra console để debug
        print('Cloudinary Error: ${resp.body}');
        final msg = data['error']['message'] ?? 'Unknown error';
        throw Exception('Upload Failed: $msg');
      }
    } catch (e) {
      print('Cloudinary Exception: $e');
      rethrow;
    }
  }
}