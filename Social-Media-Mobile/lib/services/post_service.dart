// lib/services/post_service.dart
import '../models/post.dart';
import 'api_client.dart';

class PostService {
  final ApiClient api;
  PostService(this.api);

  // --- CÁC HÀM CŨ (GIỮ NGUYÊN) ---
  Future<List<PostModel>> getFeed() async {
    final list = await api.getList('/posts');
    return list.map((e) => PostModel.fromJson(e)).toList();
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

  Future<int> toggleLike(String postId) async {
    final data = await api.post('/posts/$postId/like', {});
    return (data['likes'] ?? 0) as int;
  }

  Future<void> likeComment(String commentId) async {
    await api.post('/comments/$commentId/like',{});
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

  // ================= ADD COMMENT / REPLY =================
  Future<Map<String, dynamic>?> addComment(
      String postId,
      String content, {
        String? parentId,
      }) async {
    try {
      if (content.trim().isEmpty) {
        throw Exception("Comment content is empty");
      }

      final body = {
        'content': content,
      };

      // 👇 nếu là reply thì gửi parentId
      if (parentId != null && parentId.isNotEmpty) {
        body['parentId'] = parentId;
      }

      final data = await api.post(
        '/posts/$postId/comments',
        body,
      );

      print("✅ COMMENT CREATED = $data");
      return Map<String, dynamic>.from(data);
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