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
  Future<dynamic> addComment(String postId, String content) async {
    try {
      // Gọi API. Nếu thành công, nó trả về object comment vừa tạo
      final data = await api.post('/posts/$postId/comments', {
        'content': content,
      });
      return data;
    } catch (e) {
      // 👇 IN LỖI RA ĐỂ BIẾT TẠI SAO MẤT COMMENT
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