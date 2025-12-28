// // lib/widgets/profile_tab.dart
//
// import 'package:flutter/material.dart';
// import '../services/profile_service.dart';
// import '../main.dart'; // Để dùng authService (nếu cần logout)
//
// class ProfileTab extends StatefulWidget {
//   final String currentUserId;
//
//   const ProfileTab({super.key, required this.currentUserId});
//
//   @override
//   State<ProfileTab> createState() => _ProfileTabState();
// }
//
// class _ProfileTabState extends State<ProfileTab> {
//   final ProfileService _profileService = ProfileService();
//
//   bool _isLoading = true;
//   String _name = '';      // Biến chứa Tên
//   String _avatarUrl = ''; // Biến chứa Avatar
//   String _bio = '';       // Biến chứa Bio
//   int _postCount = 0;
//   int _followerCount = 0;
//   int _followingCount = 0;
//   List<dynamic> _posts = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchMyProfile();
//   }
//
//   void _fetchMyProfile() async {
//     try {
//       // Gọi API lấy dữ liệu
//       final data = await _profileService.getUserProfile(widget.currentUserId, widget.currentUserId);
//
//       // 👇 IN LOG ĐỂ KIỂM TRA (Nếu lỗi thì chụp log này gửi mình)
//       print("LOG PROFILE DATA: $data");
//
//       if (mounted) {
//         setState(() {
//           // 1. LẤY CÁC CON SỐ
//           _postCount = data['postCount'] ?? 0;
//           _followerCount = data['followerCount'] ?? 0;
//           _followingCount = data['followingCount'] ?? 0;
//           _posts = data['posts'] ?? [];
//
//           // 🔥 2. LẤY THÔNG TIN TÊN & AVATAR (QUAN TRỌNG)
//           // Code cũ thiếu đoạn này nên nó không biết tên là gì
//           if (data['user'] != null) {
//             _name = data['user']['name'] ?? 'No Name';
//             _avatarUrl = data['user']['avatarUrl'] ?? '';
//             _bio = data['user']['bio'] ?? '';
//           } else {
//             _name = 'Không có tên';
//           }
//
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print("Lỗi tải profile: $e");
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) return const Center(child: CircularProgressIndicator());
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // --- HEADER INFO ---
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 children: [
//                   // Avatar
//                   CircleAvatar(
//                     radius: 40,
//                     backgroundColor: Colors.grey[200],
//                     backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
//                     child: _avatarUrl.isEmpty
//                         ? Text(_name.isNotEmpty ? _name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 32, color: Colors.black))
//                         : null,
//                   ),
//                   const SizedBox(width: 20),
//                   // Stats (Chỉ số)
//                   Expanded(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         _buildStatItem("Posts", _postCount),
//                         _buildStatItem("Followers", _followerCount),
//                         _buildStatItem("Following", _followingCount),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
//
//             // --- TÊN VÀ TIỂU SỬ ---
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                       _name.isNotEmpty ? _name : "Đang tải...",
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
//                   ),
//                   if (_bio.isNotEmpty) ...[
//                     const SizedBox(height: 4),
//                     Text(_bio),
//                   ]
//                 ],
//               ),
//             ),
//
//             // --- NÚT EDIT PROFILE ---
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton(
//                   onPressed: () {
//                     // Chức năng sửa hồ sơ sẽ làm sau
//                   },
//                   style: OutlinedButton.styleFrom(
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//                     side: const BorderSide(color: Colors.grey),
//                   ),
//                   child: const Text("Edit Profile", style: TextStyle(color: Colors.black)),
//                 ),
//               ),
//             ),
//
//             // --- LƯỚI ẢNH (GRID) ---
//             const Divider(height: 1),
//             if (_posts.isEmpty)
//               const Padding(
//                 padding: EdgeInsets.all(50),
//                 child: Center(child: Text("No posts yet")),
//               )
//             else
//               GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: _posts.length,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   crossAxisSpacing: 2,
//                   mainAxisSpacing: 2,
//                 ),
//                 itemBuilder: (context, index) {
//                   return Image.network(
//                     _posts[index]['imageUrl'],
//                     fit: BoxFit.cover,
//                     errorBuilder: (ctx, err, stack) => Container(color: Colors.grey[200]),
//                   );
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatItem(String label, int count) {
//     return Column(
//       children: [
//         Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//         Text(label, style: const TextStyle(fontSize: 13)),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../main.dart';

class ProfileTab extends StatefulWidget {
  final String currentUserId;

  const ProfileTab({super.key, required this.currentUserId});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with SingleTickerProviderStateMixin {
  final ProfileService _profileService = ProfileService();
  late TabController _tabController;

  bool _isLoading = true;
  String _name = '';
  String _username = ''; // Thêm username (tên định danh)
  String _avatarUrl = '';
  String _bio = '';
  int _postCount = 0;
  int _followerCount = 0;
  int _followingCount = 0;
  List<dynamic> _posts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 Tab: Posts, Reels, Tagged
    _fetchMyProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _fetchMyProfile() async {
    try {
      final data = await _profileService.getUserProfile(widget.currentUserId, widget.currentUserId);

      if (mounted) {
        setState(() {
          _postCount = data['postCount'] ?? 0;
          _followerCount = data['followerCount'] ?? 0;
          _followingCount = data['followingCount'] ?? 0;
          _posts = data['posts'] ?? [];

          if (data['user'] != null) {
            _name = data['user']['name'] ?? 'No Name'; // Tên hiển thị (Tên thật)
            _username = data['user']['username'] ?? 'username'; // Tên định danh
            _avatarUrl = data['user']['avatarUrl'] ?? '';
            _bio = data['user']['bio'] ?? '';
          } else {
            _name = 'Người dùng';
          }
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
    if (_isLoading) return const Scaffold(backgroundColor: Colors.white, body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.lock_outline, color: Colors.black, size: 18),
            const SizedBox(width: 5),
            Text(
              _username.isNotEmpty ? _username : "username",
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.black, size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. PHẦN HEADER (Avatar + Chỉ số)
                    Row(
                      children: [
                        // Avatar có viền gradient (Story ring)
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.purple, Colors.orange],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: CircleAvatar(
                              radius: 38,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                              child: _avatarUrl.isEmpty ? Text(_name[0].toUpperCase(), style: const TextStyle(fontSize: 30)) : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
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

                    // 2. PHẦN BIO (Tiểu sử)
                    const SizedBox(height: 12),
                    Text(_name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    if (_bio.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(_bio, style: const TextStyle(fontSize: 14)),
                    ],

                    // 3. NÚT EDIT PROFILE
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildActionButton("Edit profile")),
                        const SizedBox(width: 8),
                        Expanded(child: _buildActionButton("Share profile")),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFEFEF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.person_add_outlined, size: 20),
                        )
                      ],
                    ),

                    // 4. STORY HIGHLIGHTS (Tin nổi bật - Mock UI)
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildHighlightItem("Memories", Colors.grey[300]!),
                          _buildHighlightItem("Travel", Colors.grey[300]!),
                          _buildHighlightItem("Work", Colors.grey[300]!),
                          _buildHighlightItem("My Cat", Colors.grey[300]!),
                          _buildHighlightItem("New", Colors.white, isAdd: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ];
        },
        // 5. PHẦN TABS (Grid, Reels, Tagged)
        body: Column(
          children: [
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorWeight: 1,
              tabs: const [
                Tab(icon: Icon(Icons.grid_on_outlined, size: 26)),
                Tab(icon: Icon(Icons.video_library_outlined, size: 26)),
                Tab(icon: Icon(Icons.person_pin_outlined, size: 26)),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: GRID ẢNH (Dữ liệu thật)
                  _posts.isEmpty
                      ? _buildEmptyState("No posts yet", Icons.camera_alt_outlined)
                      : GridView.builder(
                    padding: const EdgeInsets.only(top: 2),
                    itemCount: _posts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemBuilder: (context, index) {
                      return Image.network(
                        _posts[index]['imageUrl'],
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(color: Colors.grey[200]),
                      );
                    },
                  ),

                  // TAB 2: REELS (Giao diện mẫu)
                  _buildEmptyState("Reels tab coming soon", Icons.video_collection_outlined),

                  // TAB 3: TAGGED (Giao diện mẫu)
                  _buildEmptyState("Photos of you", Icons.account_box_outlined),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CÁC WIDGET CON ĐỂ CODE GỌN HƠN ---

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildActionButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  Widget _buildHighlightItem(String label, Color color, {bool isAdd = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 1),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
                child: isAdd
                    ? const Icon(Icons.add, size: 30)
                    : const Icon(Icons.favorite, color: Colors.white), // Icon giả
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Icon(icon, size: 40, color: Colors.black),
          ),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
    );
  }
}

