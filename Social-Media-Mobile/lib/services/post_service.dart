// lib/services/post_service.dart
import 'dart:convert'; // 👈 THÊM DÒNG NÀY VÀO TRÊN CÙNG
import 'package:demo/main.dart';

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
    // 1. Gọi API
    final response = await api.post('/posts', {
      'caption': caption,
      'imageUrl': imageUrl,
      'tags': tags,
    });

    // 2. Kiểm tra thành công (200 OK hoặc 201 Created)
    if (response.statusCode == 200 || response.statusCode == 201) {
      // 3. QUAN TRỌNG: Phải decode body từ String sang Map
      final jsonMap = jsonDecode(response.body);
      return PostModel.fromJson(jsonMap);
    } else {
      // 4. Nếu lỗi thì ném ra Exception để UI bắt được
      throw Exception('Lỗi tạo bài viết: ${response.body}');
    }
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

  // // 2. Thêm bình luận (SỬA LẠI ĐỂ BẮT LỖI KỸ HƠN)
  // Future<CommentModel?> addComment(String postId, String content) async {
  //   try {
  //     print("🚀 Đang gửi comment: $content");
  //
  //     final response = await api.post('/posts/$postId/comments', {
  //       'content': content,
  //     });
  //
  //     print("📡 Server trả về: ${response.statusCode} - ${response.body}");
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final jsonMap = jsonDecode(response.body);
  //
  //       // 👇 SỬA LẠI: Dùng 'Comment' thay vì 'CommentModel'
  //       return CommentModel.fromJson(jsonMap);
  //     } else {
  //       print("❌ Server từ chối: ${response.body}");
  //       return null;
  //     }
  //   } catch (e) {
  //     print("❌ LỖI GỌI API COMMENT: $e");
  //     return null;
  //   }
  // }

  // 2. Thêm bình luận (+ reply)
  Future<CommentModel?> addComment(
      String postId,
      String content, {
        String? parentId,
      }) async {
    try {
      final body = <String, dynamic>{'content': content};

      if (parentId != null && parentId.isNotEmpty) {
        body['parentId'] = parentId; // nếu BE dùng parentCommentId thì đổi key tại đây
      }

      final response = await api.post('/posts/$postId/comments', body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonMap = jsonDecode(response.body);
        return CommentModel.fromJson(jsonMap);
      }
      return null;
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



  // Hàm thả tim bình luận (Sửa POST thành PUT)
  Future<bool> likeComment(String commentId) async {
    try {
      print("❤️ Đang thả tim comment: $commentId");

      // 1. Thử dùng PUT (Đa số server dùng cái này để update)
      // Đường dẫn: /api/comments/:id/like
      final response = await api.put('/comments/$commentId/like', {});

      // Nếu Server trả về 200 (OK) -> Thành công
      if (response.statusCode == 200) {
        return true;
      }

      // 2. Dự phòng: Nếu Server báo lỗi 404, có thể Server dùng đường dẫn khác
      // Bạn hãy check lại Terminal Server xem nó in ra đường dẫn gì nhé!
      print("❌ Lỗi Like Comment: ${response.statusCode} - ${response.body}");
      return false;

    } catch (e) {
      print("❌ Exception Like: $e");
      return false;
    }
  }

}

