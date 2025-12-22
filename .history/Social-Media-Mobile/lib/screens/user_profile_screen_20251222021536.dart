// lib/screens/user_profile_screen.dart

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/profile_service.dart';

class UserProfileScreen extends StatefulWidget {
  final AppUser user;
  final String currentUserId;

  const UserProfileScreen({
    super.key,
    required this.user,
    required this.currentUserId,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ProfileService _profileService = ProfileService();

  bool _isLoading = true;
  int _postCount = 0;
  int _followerCount = 0;
  int _followingCount = 0;
  String _relationStatus = 'none'; // 'none', 'pending', 'friend', 'self'...
  List<dynamic> _posts = [];

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  void _fetchProfileData() async {
    try {
      final data = await _profileService.getUserProfile(widget.user.id, widget.currentUserId);
      if (mounted) {
        setState(() {
          _postCount = data['postCount'] ?? 0;
          _followerCount = data['followerCount'] ?? 0;
          _followingCount = data['followingCount'] ?? 0;
          _relationStatus = data['relationStatus'] ?? 'none';
          _posts = data['posts'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi tải profile: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Widget hiển thị nút bấm dựa trên quan hệ
  Widget _buildActionButtons() {
    // 1. Nếu là chính mình -> Nút Edit Profile
    if (_relationStatus == 'self') {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {}, // TODO: Mở màn hình Edit
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.grey),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          child: const Text("Edit Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      );
    }

    // 2. Nếu đã là bạn bè -> Nút Message
    if (_relationStatus == 'friend') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: const Text("Message", style: TextStyle(color: Colors.black)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
             decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(5)),
             child: IconButton(icon: const Icon(Icons.person_remove, size: 20), onPressed: () {}), // TODO: Hủy kết bạn
          )
        ],
      );
    }

    // 3. Nếu họ gửi lời mời cho mình -> Nút Chấp nhận
    if (_relationStatus == 'pending_received') {
       return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {}, // TODO: Gọi API Accept ở đây nếu muốn
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          child: const Text("Accept Request", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    }

    // 4. Nếu chưa là gì cả -> Nút Follow (Kết bạn)
    bool isPending = _relationStatus == 'pending';
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Gọi API gửi kết bạn
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isPending ? Colors.grey[200] : Colors.blue,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Text(
          isPending ? "Requested" : "Follow",
          style: TextStyle(color: isPending ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.user.username, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER INSTAGRAM ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        // Avatar to
                        CircleAvatar(
                          radius: 42,
                          backgroundImage: widget.user.avatarUrl.isNotEmpty ? NetworkImage(widget.user.avatarUrl) : null,
                          child: widget.user.avatarUrl.isEmpty ? Text(widget.user.name[0].toUpperCase(), style: const TextStyle(fontSize: 32)) : null,
                        ),
                        const SizedBox(width: 24),
                        // 3 Cột chỉ số
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatItem("Posts", _postCount),
                              _buildStatItem("Followers", _followerCount),
                              _buildStatItem("Following", _followingCount),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- BIO & NAME ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        if (widget.user.bio.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(widget.user.bio),
                        ]
                      ],
                    ),
                  ),

                  // --- ACTION BUTTONS ---
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildActionButtons(),
                  ),

                  // --- TAB ICONS ---
                  const Divider(height: 1),
                  Row(
                    children: [
                      Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black))), child: const Icon(Icons.grid_on))),
                      Expanded(child: Container(padding: const EdgeInsets.all(12), child: const Icon(Icons.person_pin_outlined, color: Colors.grey))),
                    ],
                  ),

                  // --- GRID ẢNH ---
                  if (_posts.isEmpty)
                     const Padding(padding: EdgeInsets.all(50), child: Center(child: Text("No posts yet")))
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _posts.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 1.5,
                        mainAxisSpacing: 1.5,
                      ),
                      itemBuilder: (context, index) {
                         return Image.network(
                            _posts[index]['imageUrl'], 
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(color: Colors.grey[200]),
                         );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
      ],
    );
  }
}