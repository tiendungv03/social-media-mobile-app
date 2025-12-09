// lib/widgets/profile_tab.dart
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/post.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    if (user == null) {
      return const Center(child: Text('No user info'));
    }

    return Column(
      children: [
        // header + info
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: user.avatarUrl.isNotEmpty
                    ? NetworkImage(user.avatarUrl)
                    : null,
                child: user.avatarUrl.isEmpty
                    ? Text(
                  user.username.isNotEmpty
                      ? user.username[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold),
                )
                    : null,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {
                        // TODO: edit profile screen
                      },
                      child: const Text('Edit Profile'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              user.bio,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _ProfileStat(label: 'Posts', value: '—'),
              _ProfileStat(label: 'Followers', value: '—'),
              _ProfileStat(label: 'Following', value: '—'),
            ],
          ),
        ),

        const SizedBox(height: 16),
        const Divider(height: 1),

        // danh sách bài viết của user (grid)
        Expanded(
          child: FutureBuilder<List<PostModel>>(
            future: postService.getUserPosts(user.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }
              final posts = snapshot.data ?? [];
              if (posts.isEmpty) {
                return const Center(child: Text('No posts yet'));
              }
              return GridView.builder(
                padding: const EdgeInsets.all(2),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  childAspectRatio: 1,
                ),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final p = posts[index];
                  return GestureDetector(
                    onTap: () {
                      // TODO: mở chi tiết post nếu muốn
                    },
                    child: Image.network(
                      p.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: Colors.black12),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
