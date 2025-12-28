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
import '../screens/edit_profile_screen.dart'; // Import màn hình Edit
import '../screens/post_detail_screen.dart';  // Import màn hình Post Detail
import '../screens/home_screen.dart'; // Để dùng chung logic danh sách bạn bè nếu cần

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

  // --- 1. XỬ LÝ SỰ KIỆN CLICK EDIT ---
  void _onTapEditProfile() async {
    // Chuyển sang màn hình Edit và chờ kết quả trả về
    final result = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => EditProfileScreen(
        userId: widget.currentUserId,
        currentName: _name,
        currentBio: _bio,
        currentAvatar: _avatarUrl,
      ))
    );

    // Nếu sửa xong (result == true) thì tải lại Profile
    if (result == true) {
      _fetchMyProfile();
    }
  }

  // --- 2. XỬ LÝ SỰ KIỆN SHARE ---
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

  // --- 3. XỬ LÝ CLICK POST ---
  void _onTapPost(String imageUrl) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailScreen(imageUrl: imageUrl)));
  }

  // --- 4. XỬ LÝ CLICK FOLLOWER/FOLLOWING ---
  void _onTapFollowList(String title) {
    // Tạm thời hiển thị danh sách đơn giản (Vì logic backend Follower/Following đang dùng chung friends)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        builder: (_, controller) => Container(
          color: Colors.white,
          child: Column(
            children: [
              Padding(padding: const EdgeInsets.all(16), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
              const Divider(),
              Expanded(
                child: Center(child: Text("Danh sách $title đang được cập nhật...")), // Sau này sẽ gắn ListUser vào đây
              ),
            ],
          ),
        ),
      )
    );
  }

  // --- 5. XỬ LÝ CLICK TIN NỔI BẬT (STORY) ---
  void _onTapStory(String title) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Image.network("https://robohash.org/$title?set=set2", fit: BoxFit.contain)),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))
            ],
          ),
        ),
      )
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
          IconButton(icon: const Icon(Icons.add_box_outlined, color: Colors.black, size: 28), onPressed: () {}),
          IconButton(icon: const Icon(Icons.menu, color: Colors.black, size: 28), onPressed: () {}),
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
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.purple, Colors.orange])),
                          child: CircleAvatar(
                            radius: 38, 
                            backgroundImage: _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                            backgroundColor: Colors.white,
                            child: _avatarUrl.isEmpty ? Text(_name[0].toUpperCase()) : null,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatItem("Posts", _postCount),
                              // 👇 GẮN SỰ KIỆN CLICK FOLLOWER
                              GestureDetector(onTap: () => _onTapFollowList("Followers"), child: _buildStatItem("Followers", _followerCount)),
                              // 👇 GẮN SỰ KIỆN CLICK FOLLOWING
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
                        // 👇 GẮN SỰ KIỆN EDIT
                        Expanded(child: GestureDetector(onTap: _onTapEditProfile, child: _buildActionButton("Edit profile"))),
                        const SizedBox(width: 8),
                        // 👇 GẮN SỰ KIỆN SHARE
                        Expanded(child: GestureDetector(onTap: _onTapShareProfile, child: _buildActionButton("Share profile"))),
                        const SizedBox(width: 8),
                        Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: const Color(0xFFEFEFEF), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.person_add_outlined, size: 20))
                      ],
                    ),

                    // Story Highlights
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildHighlightItem("Memories", Colors.grey[300]!),
                          _buildHighlightItem("Travel", Colors.grey[300]!),
                          _buildHighlightItem("Work", Colors.grey[300]!),
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
                  // Tab Grid Posts
                  _posts.isEmpty
                      ? const Center(child: Text("No posts yet"))
                      : GridView.builder(
                          itemCount: _posts.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
                          itemBuilder: (context, index) {
                            // 👇 GẮN SỰ KIỆN CLICK ẢNH
                            return GestureDetector(
                              onTap: () => _onTapPost(_posts[index]['imageUrl']),
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

  Widget _buildHighlightItem(String label, Color color, {bool isAdd = false}) {
    return GestureDetector(
      onTap: () => isAdd ? {} : _onTapStory(label), // Click xem story
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 65, height: 65,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey[300]!), color: Colors.white),
              child: Padding(padding: const EdgeInsets.all(4), child: Container(decoration: BoxDecoration(shape: BoxShape.circle, color: color), child: isAdd ? const Icon(Icons.add) : null)),
            ),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}