// 



// lib/widgets/friends_tab.dart
import 'package:flutter/material.dart';
import '../mocks/mock_friends_repo.dart';
import '../models/user.dart';

class FriendsTab extends StatelessWidget {
  const FriendsTab({super.key});

  final MockFriendsRepo repo = const MockFriendsRepo(); // nếu repo không const thì bỏ const

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppUser>>(
      future: repo.suggestions(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }

        final users = snap.data ?? [];
        if (users.isEmpty) {
          return const Center(child: Text('No suggestions'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final u = users[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  (u.username.isNotEmpty ? u.username[0] : 'U').toUpperCase(),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              title: Text(u.username),
              subtitle: Text(u.bio.isEmpty ? 'Tap to view profile' : u.bio),
              trailing: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  side: BorderSide(color: Colors.blue.shade300),
                ),
                child: const Text('Follow', style: TextStyle(fontSize: 12)),
              ),
            );
          },
        );
      },
    );
  }
}

