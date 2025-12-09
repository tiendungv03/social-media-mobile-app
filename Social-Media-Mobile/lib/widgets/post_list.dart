// lib/widgets/post_list.dart
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import 'post_card.dart';

class PostList extends StatelessWidget {
  final Future<List<PostModel>> future;
  final PostService postService;
  final Future<void> Function() onReload;

  const PostList({
    super.key,
    required this.future,
    required this.postService,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onReload,
      child: FutureBuilder<List<PostModel>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(child: Text('No posts'));
          }
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final p = posts[index];
              return PostCard(
                post: p,
                onLike: () async {
                  final likes = await postService.toggleLike(p.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Likes: $likes')),
                  );
                  await onReload();
                },
              );
            },
          );
        },
      ),
    );
  }
}
