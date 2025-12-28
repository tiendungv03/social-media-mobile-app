// lib/services/post_service.dart
import '../models/post.dart';
import 'api_client.dart';

class PostService {
  final ApiClient api;
  PostService(this.api);

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
}
