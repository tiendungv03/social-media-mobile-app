// lib/screens/user_profile_screen.dart

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/profile_service.dart'; // Import service vừa tạo

class UserProfileScreen extends StatefulWidget {
  final AppUser user;
  final String currentUserId; // Cần ID của chính bạn để check follow

  const UserProfileScreen({
    super.key, 
    required this.user, 
    required this.currentUserId
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ProfileService _profileService = ProfileService();

  // Biến chứa dữ liệu thật
  bool _isLoading = true;
  int _postCount = 0;
  int _followerCount = 0;
  int _followingCount = 0;
  bool _isFollowing = false;
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
          _isFollowing = data['isFollowing'] ?? false;
          _posts = data['posts'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi tải profile: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.user.username.isNotEmpty ? widget.user.username : widget.user.name,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            child: Column(
              children: [
                // --- 1. AVATAR & INFO ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: (widget.user.avatarUrl.isNotEmpty)
                            ? NetworkImage(widget.user.avatarUrl)
                            : null,
                        child: (widget.user.avatarUrl.isEmpty)
                            ? Text(widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 30))
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(widget.user.email, style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            // Nút Theo dõi (Logic hiển thị theo _isFollowing thật)
                            ElevatedButton(
                              onPressed: () {
                                // Sau này thêm API follow vào đây
                                setState(() { _isFollowing = !_isFollowing; });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isFollowing ? Colors.grey[200] : Colors.blue,
                                foregroundColor: _isFollowing ? Colors.black : Colors.white,
                                elevation: 0,
                              ),
                              child: Text(_isFollowing ? "Đang theo dõi" : "Theo dõi"),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                // --- 2. BIO ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(widget.user.bio.isNotEmpty ? widget.user.bio : "Chưa có giới thiệu.")
                  ),
                ),
                const SizedBox(height: 10),

                // --- 3. THỐNG KÊ (DỮ LIỆU THẬT) ---
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem("Bài viết", "$_postCount"),
                      _buildStatItem("Người theo dõi", "$_followerCount"),
                      _buildStatItem("Đang theo dõi", "$_followingCount"),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // --- 4. GRID VIEW (ẢNH THẬT) ---
                if (_posts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Text("Chưa có bài viết nào"),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _posts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return Image.network(
                        post['imageUrl'], // Link ảnh từ MongoDB
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200]),
                      );
                    },
                  ),
              ],
            ),
          ),
    );
  }

  Widget _buildStatItem(String label, String count) {
    return Column(children: [
      Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ]);
  }
}