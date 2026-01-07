import 'api_client.dart';

class CommentService {
  final ApiClient _api = ApiClient();

  // Lấy comment theo post
  Future<List<dynamic>> getComments(String postId) {
    return _api.getList('/comments/$postId');
  }

  // Tạo comment
  Future<Map<String, dynamic>> createComment(
      String postId, String text) {
    return _api.post('/comments/$postId', {
      'text': text,
    });
  }

  Future<void> toggleLike(String commentId) async {
    await _api.post('/comments/$commentId/like', {});
  }

  Future<Map<String, dynamic>?> reply(
      String commentId, String content) async {
    final res = await _api.post(
      '/comments/$commentId/reply',
      {'content': content},
    );
    return res;
  }
}
