import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'user_profile_screen.dart'; // Import trang cá nhân để bấm vào thì chuyển trang
import 'search_screen.dart';

class SearchScreen extends StatefulWidget {

  final String currentUserId;

  const SearchScreen({super.key, required this.currentUserId});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UserService _userService = UserService();

  List<dynamic> _searchResults = []; // Biến chứa danh sách kết quả tìm được
  bool _isLoading = false; // Biến để hiện vòng tròn xoay xoay khi đang tải

  // Hàm xử lý khi bấm nút Tìm (Enter) trên bàn phím
  void _performSearch() async {
    String query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true); // Bắt đầu xoay

    // Gọi Service đi tìm
    final results = await _userService.searchUsers(query);

    setState(() {
      _searchResults = results;
      _isLoading = false; // Tắt xoay
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Thanh tiêu đề chứa ô nhập liệu
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search, // Đổi nút Enter thành hình Kính lúp
          onSubmitted: (value) => _performSearch(), // Bấm Enter thì tìm ngay
          decoration: InputDecoration(
            hintText: 'Nhập tên bạn bè...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
          style: const TextStyle(color: Colors.black),
          autofocus: true, // Vào màn hình cái là hiện bàn phím luôn
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black), // Nút Back màu đen
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _performSearch, // Bấm nút kính lúp cũng tìm luôn
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Đang tìm thì xoay
          : _searchResults.isEmpty
          ? const Center(child: Text("Nhập tên để tìm kiếm..."))
          : ListView.builder( // Có kết quả thì hiện danh sách
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final user = _searchResults[index];

          // Lấy dữ liệu an toàn
          final String username = user['username'] ?? "User";
          final String name = user['name'] ?? username;
          final String avatar = user['avatarUrl'] ?? "";
          final String userId = user['_id'] ?? "";

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: (avatar.isNotEmpty) ? NetworkImage(avatar) : null,
              child: avatar.isEmpty ? const Icon(Icons.person) : null,
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("@$username"),
            onTap: () {
              // 👇 Bấm vào nick thì sang trang cá nhân người đó
              // (Bạn cần sửa lại chỗ currentUserId cho đúng logic app của bạn)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(
                    user: user,
                    userId: userId,             // 👈 THÊM DÒNG NÀY: ID của người bạn đang bấm vào
                    currentUserId: userId, // Tạm thời để userId chính họ để test xem profile
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}