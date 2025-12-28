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

  // --- 👇 2 HÀM MỚI THÊM VÀO ĐÂY ---

  // 1. Xóa bài viết
  Future<bool> deletePost(String postId) async {
    try {
      // Giả định ApiClient có hàm delete. Nếu chưa có, xem lưu ý bên dưới (*).
      await api.delete('/posts/$postId'); 
      return true;
    } catch (e) {
      print("Lỗi xóa bài: $e");
      return false;
    }
  }

  // 2. Thêm bình luận
  Future<dynamic> addComment(String postId, String content) async {
    try {
      final data = await api.post('/posts/$postId/comments', {
        'content': content,
      });
      // Trả về data comment mới (hoặc PostModel mới tùy server trả về)
      return data; 
    } catch (e) {
      print("Lỗi comment: $e");
      return null;
    }
  }
}