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
import '../models/user.dart';
import '../services/profile_service.dart';
import '../services/friend_service.dart';
import '../services/auth_service.dart'; // ✅ Import để Đăng xuất

// Import các màn hình
import '../screens/edit_profile_screen.dart';
import '../screens/post_detail_screen.dart';
import '../screens/create_post_screen.dart'; // ✅ Import màn hình đăng bài
import '../screens/login_screen.dart'; // ✅ Import màn hình đăng nhập

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
  String _username = '';
  String _avatarUrl = '';
  String _bio = '';
  int _postCount = 0;
  int _followerCount = 0;
  int _followingCount = 0;
  List<dynamic> _posts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchMyProfile();
  }

  // Hàm tải dữ liệu
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
            _name = data['user']['name'] ?? 'No Name';
            _username = data['user']['username'] ?? 'username';
            _avatarUrl = data['user']['avatarUrl'] ?? '';
            _bio = data['user']['bio'] ?? '';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 1. XỬ LÝ SỰ KIỆN MENU (ĐĂNG XUẤT) ---
  void _onTapMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.black),
              title: const Text("Cài đặt"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
              onTap: () async {
                // Đăng xuất và quay về màn hình Login
                await AuthService().logout();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. XỬ LÝ SỰ KIỆN CLICK EDIT ---
  void _onTapEditProfile() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditProfileScreen(
          userId: widget.currentUserId,
          currentName: _name,
          currentBio: _bio,
          currentAvatar: _avatarUrl,
        ))
    );

    if (result == true) {
      _fetchMyProfile();
    }
  }

  // --- 3. XỬ LÝ SỰ KIỆN SHARE ---
  void _onTapShareProfile() {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          height: 200,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text("Share Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              const Text("Link profile của bạn:"),
              Text("minigram.com/u/$_username", style: const TextStyle(color: Colors.blue)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Sao chép Link"))
            ],
          ),
        )
    );
  }

 // --- 4. XỬ LÝ CLICK POST (ĐÃ SỬA) ---
  // Thay đổi tham số từ String imageUrl thành dynamic post
  void _onTapPost(dynamic postItem) {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => PostDetailScreen(
        post: postItem, // Truyền toàn bộ object bài viết sang
        currentUserId: widget.currentUserId, // Truyền ID người đang dùng
      ))
    );
  }

  // --- 5. XỬ LÝ CLICK FOLLOWER/FOLLOWING ---
  void _onTapFollowList(String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(),
            Expanded(
              child: FutureBuilder<List<AppUser>>(
                future: FriendService().getAcceptedFriends(widget.currentUserId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError) return Center(child: Text("Lỗi: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("Chưa có ${title.toLowerCase()} nào.", style: const TextStyle(color: Colors.grey)));
                  }
                  final users = snapshot.data!;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        leading: CircleAvatar(backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null, child: user.avatarUrl.isEmpty ? Text(user.name[0]) : null),
                        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("@${user.username}"),
                        trailing: ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black, elevation: 0), child: const Text("Message")),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
            Text(_username.isNotEmpty ? _username : "username", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
        actions: [
          // 👇 NÚT TẠO BÀI VIẾT (DẤU +) - Đã sửa
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.black, size: 28),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePostScreen()));
            },
          ),
          // 👇 NÚT MENU (3 GẠCH) - Đã sửa
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 28),
            onPressed: _onTapMenu,
          ),
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
                    // Header Stats
                    Row(
                      children: [
                        // Avatar (Đã bỏ viền Gradient Story cho gọn)
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.grey[200],
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                            backgroundColor: Colors.white,
                            child: _avatarUrl.isEmpty ? Text(_name[0].toUpperCase(), style: const TextStyle(fontSize: 30)) : null,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatItem("Posts", _postCount),
                              GestureDetector(onTap: () => _onTapFollowList("Followers"), child: _buildStatItem("Followers", _followerCount)),
                              GestureDetector(onTap: () => _onTapFollowList("Following"), child: _buildStatItem("Following", _followingCount)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    if (_bio.isNotEmpty) Text(_bio),
                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(child: GestureDetector(onTap: _onTapEditProfile, child: _buildActionButton("Edit profile"))),
                        const SizedBox(width: 8),
                        Expanded(child: GestureDetector(onTap: _onTapShareProfile, child: _buildActionButton("Share profile"))),
                        const SizedBox(width: 8),
                        Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: const Color(0xFFEFEFEF), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.person_add_outlined, size: 20))
                      ],
                    ),

                    // 🔥 ĐÃ XÓA HOÀN TOÀN PHẦN TIN NỔI BẬT (HIGHLIGHTS) TẠI ĐÂY

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(icon: Icon(Icons.grid_on_outlined)),
                Tab(icon: Icon(Icons.video_library_outlined)),
                Tab(icon: Icon(Icons.person_pin_outlined)),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _posts.isEmpty
                      ? const Center(child: Text("No posts yet"))
                      : GridView.builder(
                    itemCount: _posts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _onTapPost(_posts[index]),
                        child: Image.network(_posts[index]['imageUrl'], fit: BoxFit.cover),
                      );
                    },
                  ),
                  const Center(child: Text("Reels coming soon")),
                  const Center(child: Text("Tagged photos")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(children: [Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text(label, style: const TextStyle(fontSize: 14))]);
  }

  Widget _buildActionButton(String label) {
    return Container(padding: const EdgeInsets.symmetric(vertical: 8), alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFEFEFEF), borderRadius: BorderRadius.circular(8)), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)));
  }
}