// lib/services/post_service.dart
import 'dart:convert'; // 👈 THÊM DÒNG NÀY VÀO TRÊN CÙNG
import '../models/post.dart';
import 'api_client.dart';
import '../models/comment.dart';

class PostService {
  final ApiClient api;
  PostService(this.api);

  // --- CÁC HÀM CŨ (GIỮ NGUYÊN) ---
// 1. Lấy News Feed
  Future<List<PostModel>> getFeed() async {
    try {
      // 2. Dùng biến 'api' toàn cục để gọi (đã có Token)
      final response = await api.get('/posts');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => PostModel.fromJson(item)).toList();
      }
      throw Exception('Lỗi: ${response.statusCode} - ${jsonDecode(response.body)['message']}');
    } catch (e) {
      // Bắt lỗi No token tại đây
      rethrow;
    }
  }

  // 2. Thả tim
  Future<int> toggleLike(String postId) async {
    try {
      final response = await api.post('/posts/$postId/like', {});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['likes'] ?? 0) as int;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<List<PostModel>> getUserPosts(String userId) async {
    final list = await api.getList('/posts/user/$userId');
    return list.map((e) => PostModel.fromJson(e)).toList();
  }

  Future<PostModel> createPost(
      String caption,
      String imageUrl,
      List<String> tags,
      ) async {
    final data = await api.post('/posts', {
      'caption': caption,
      'imageUrl': imageUrl,
      'tags': tags,
    });
    return PostModel.fromJson(data);
  }


  // --- 👇 3 HÀM QUAN TRỌNG ĐÃ ĐƯỢC CẬP NHẬT ---

  // 1. Xóa bài viết
  Future<bool> deletePost(String postId) async {
    try {
      await api.delete('/posts/$postId');
      return true;
    } catch (e) {
      print("❌ Lỗi xóa bài: $e");
      return false;
    }
  }

  // 2. Thêm bình luận (SỬA LẠI ĐỂ BẮT LỖI KỸ HƠN)
  Future<CommentModel?> addComment(String postId, String content) async {
    try {
      print("🚀 Đang gửi comment: $content");

      final response = await api.post('/posts/$postId/comments', {
        'content': content,
      });

      print("📡 Server trả về: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonMap = jsonDecode(response.body);

        // 👇 SỬA LẠI: Dùng 'Comment' thay vì 'CommentModel'
        return CommentModel.fromJson(jsonMap);
      } else {
        print("❌ Server từ chối: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ LỖI GỌI API COMMENT: $e");
      return null;
    }
  }

  // 3. Lấy chi tiết bài viết (Để load lại comment khi vào màn hình chi tiết)
  Future<Map<String, dynamic>?> getPostDetails(String postId) async {
    try {
      final data = await api.getObject('/posts/$postId');
      return data;
    } catch (e) {
      print("❌ Lỗi lấy chi tiết bài: $e");
      return null;
    }
  }
}