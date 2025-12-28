// lib/widgets/post_card.dart
import 'package:flutter/material.dart';
import '../models/post.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onLike;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header user
          ListTile(
            leading: CircleAvatar(
              backgroundImage: post.ownerAvatar.isNotEmpty
                  ? NetworkImage(post.ownerAvatar)
                  : null,
              child: post.ownerAvatar.isEmpty
                  ? Text(
                post.ownerName.isNotEmpty
                    ? post.ownerName[0].toUpperCase()
                    : '?',
              )
                  : null,
            ),
            title: Text(
              post.ownerName.isNotEmpty ? post.ownerName : 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              post.createdAt.toLocal().toString(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),

          // ảnh
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              post.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
              const Center(child: Icon(Icons.broken_image)),
            ),
          ),

          // nút like / comment
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  onPressed: onLike,
                  icon: const Icon(Icons.favorite_border),
                ),
                Text('${post.likes.length} likes'),
                const SizedBox(width: 16),
                const Icon(Icons.comment_outlined, size: 20),
                const SizedBox(width: 4),
                Text('${post.commentsCount} comments'),
              ],
            ),
          ),

          // caption
          if (post.caption.isNotEmpty)
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: post.ownerName.isNotEmpty
                          ? '${post.ownerName} '
                          : '',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: post.caption),
                  ],
                ),
              ),
            ),

          // tags
          if (post.tags.isNotEmpty)
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Wrap(
                spacing: 4,
                runSpacing: -4,
                children: post.tags
                    .map(
                      (t) => Text(
                    '#$t',
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 12,
                    ),
                  ),
                )
                    .toList(),
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
