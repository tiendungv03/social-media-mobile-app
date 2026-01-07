import 'package:flutter/material.dart';
import '../services/user_service.dart';

class UserProfileScreen extends StatefulWidget {
  final dynamic user;
  final String userId;
  final String currentUserId;

  const UserProfileScreen({
    super.key,
    this.user,
    required this.userId,
    required this.currentUserId,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserService _userService = UserService();
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  int _selectedTabIndex = 0; // 0: Grid Ảnh, 1: Danh bạ (Tags)

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  void _fetchProfileData() async {
    try {
      final data = await _userService.getUserProfile(widget.userId);
      if (mounted) {
        setState(() {
          _profileData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading profile: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 👇 Xử lý logic khi bấm nút Follow/Unfollow
  void _handleFollowAction(String currentStatus) async {
    bool success = false;
    String newStatus = currentStatus;

    if (currentStatus == 'none') {
      // Đang là người lạ -> Bấm để Gửi lời mời
      success = await _userService.sendFriendRequest(widget.userId);
      if (success) newStatus = 'pending';
    } else {
      // Đang là bạn hoặc đã gửi lời mời -> Bấm để Hủy
      success = await _userService.unfriend(widget.userId);
      if (success) newStatus = 'none';
    }

    if (success && mounted) {
      setState(() {
        _profileData!['relationStatus'] = newStatus;
        // Cập nhật lại số lượng nếu cần (logic này tùy server)
      });
    }
  }

  // 👇 Hàm hiển thị ảnh Avatar to đùng khi bấm vào
  void _showFullAvatar(String url) {
    if (url.isEmpty) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InteractiveViewer( // Cho phép zoom ảnh
              child: Image.network(url, fit: BoxFit.contain),
            ),
            const SizedBox(height: 10),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = _profileData?['user'] ?? widget.user;
    final String name = userData != null ? (userData['name'] ?? "") : "User";
    final String username = userData != null ? (userData['username'] ?? "") : "";
    final String avatarUrl = userData != null ? (userData['avatarUrl'] ?? "") : "";
    final String bio = userData != null ? (userData['bio'] ?? "") : "";

    final int postCount = _profileData?['postCount'] ?? 0;
    final int friendCount = _profileData?['followerCount'] ?? 0;
    final int followingCount = _profileData?['followingCount'] ?? 0;
    final List posts = _profileData?['posts'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(username, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading && _profileData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // 👇 AVATAR (Bấm vào để xem to)
                  GestureDetector(
                    onTap: () => _showFullAvatar(avatarUrl),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: (avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
                      child: (avatarUrl.isEmpty) ? const Icon(Icons.person, size: 40, color: Colors.grey) : null,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // 3 Cột chỉ số (Tiếng Anh)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem("Posts", postCount),
                        _buildStatItem("Followers", friendCount),
                        _buildStatItem("Following", followingCount),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- NAME & BIO ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(bio, style: const TextStyle(fontSize: 14)),
                  ]
                ],
              ),
            ),

            // --- ACTION BUTTONS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _buildActionButtons(),
            ),

            // --- TABS (Grid / Contact) ---
            Row(
              children: [
                _buildTabIcon(Icons.grid_on, 0),
                _buildTabIcon(Icons.person_pin_outlined, 1),
              ],
            ),
            const Divider(height: 1, thickness: 1),

            // --- BODY CONTENT (Thay đổi theo Tab) ---
            _selectedTabIndex == 0
                ? _buildGridPosts(posts) // Tab 0: Lưới ảnh
                : _buildContactTab(),    // Tab 1: Danh bạ/Tags
          ],
        ),
      ),
    );
  }

  // Widget hiển thị nút Tab
  Widget _buildTabIcon(IconData icon, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index; // Đổi tab
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 1.5
            )),
          ),
          child: Icon(icon, size: 28, color: isSelected ? Colors.black : Colors.grey),
        ),
      ),
    );
  }

  // Widget Grid Ảnh
  Widget _buildGridPosts(List posts) {
    if (posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 50),
        child: Center(child: Text("No posts yet", style: TextStyle(color: Colors.grey))),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        return Image.network(
          posts[index]['imageUrl'] ?? "",
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => Container(color: Colors.grey[200]),
        );
      },
    );
  }

  // Widget Tab Danh bạ (Demo)
  Widget _buildContactTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 200,
      alignment: Alignment.center,
      child: const Column(
        children: [
          Icon(Icons.assignment_ind_outlined, size: 40),
          SizedBox(height: 10),
          Text("Photos of you", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text("When people tag you in photos, they'll appear here.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(count.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (widget.userId == widget.currentUserId) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey[300]!),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          child: const Text("Edit Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      );
    }

    String status = _profileData?['relationStatus'] ?? 'none';

    // Logic nút bấm: Gọi hàm _handleFollowAction khi bấm
    if (status == 'friend') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], elevation: 0),
              child: const Text("Message", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(5)),
            child: IconButton(
              icon: const Icon(Icons.person_remove, size: 20, color: Colors.black),
              onPressed: () => _handleFollowAction(status), // Hủy kết bạn
            ),
          )
        ],
      );
    } else if (status == 'pending_received') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {}, // TODO: Accept API
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text("Confirm", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
    }

    // Nút Follow / Requested
    bool isPending = (status == 'pending');
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _handleFollowAction(status), // Gọi hàm xử lý Follow
        style: ElevatedButton.styleFrom(
          backgroundColor: isPending ? Colors.grey[200] : const Color(0xFF3797EF),
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
}