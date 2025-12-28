// lib/screens/user_profile_screen.dart

import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProfileScreen extends StatefulWidget {
  final AppUser user;

  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // Biến giả lập trạng thái Follow (Sau này sẽ gọi API thật)
  bool isFollowing = false;

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
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. PHẦN ĐẦU: AVATAR & THÔNG TIN ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: (widget.user.avatarUrl.isNotEmpty)
                        ? NetworkImage(widget.user.avatarUrl)
                        : null,
                    child: (widget.user.avatarUrl.isEmpty)
                        ? Text(widget.user.name[0].toUpperCase(), style: const TextStyle(fontSize: 30))
                        : null,
                  ),
                  const SizedBox(width: 20),

                  // Thông tin bên phải
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(widget.user.email, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),

                        // Nút Follow / Nhắn tin
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isFollowing = !isFollowing;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFollowing ? Colors.grey[200] : Colors.blue,
                                  foregroundColor: isFollowing ? Colors.black : Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 0), // Nút nhỏ gọn
                                ),
                                child: Text(isFollowing ? "Đang theo dõi" : "Theo dõi"),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 0),
                                ),
                                child: const Text("Nhắn tin", style: TextStyle(color: Colors.black)),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            // --- 2. BIO (TIỂU SỬ) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.user.bio.isNotEmpty ? widget.user.bio : "Chưa có giới thiệu.",
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),

            // --- 3. THỐNG KÊ (POSTS - FOLLOWERS - FOLLOWING) ---
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem("Bài viết", "12"), // Số giả định
                  _buildStatItem("Người theo dõi", "1.5K"),
                  _buildStatItem("Đang theo dõi", "300"),
                ],
              ),
            ),
            const Divider(height: 1),

            // --- 4. TAB BAR (LƯỚI ẢNH) ---
            // Giả lập Tab chọn chế độ xem ảnh
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
                    ),
                    child: const Icon(Icons.grid_on),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: const Icon(Icons.person_pin_outlined, color: Colors.grey),
                  ),
                ),
              ],
            ),

            // --- 5. LƯỚI ẢNH (GRID VIEW) ---
            // Vì chưa có API lấy ảnh của user này, ta dùng ảnh mẫu placeholder
            GridView.builder(
              shrinkWrap: true, // Quan trọng: Để Grid nằm trong ScrollView
              physics: const NeverScrollableScrollPhysics(), // Tắt cuộn riêng của Grid
              itemCount: 15, // Giả lập 15 tấm ảnh
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 ảnh 1 hàng
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                return Image.network(
                  // Lấy ảnh ngẫu nhiên từ Picsum để demo cho đẹp
                  'https://picsum.photos/200?random=$index',
                  fit: BoxFit.cover,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget con để vẽ cột thống kê cho gọn code
  Widget _buildStatItem(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}