// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../main.dart'; // Chứa biến toàn cục postService
import '../models/post.dart';
// import '../widgets/post_list.dart'; // ❌ Bỏ cái cũ này đi
import '../widgets/friends_tab.dart';
import '../widgets/profile_tab.dart';
import '../widgets/post_item.dart'; // ✅ Import cái mới để hiển thị bài viết xịn hơn
import 'create_post_screen.dart';
import 'search_screen.dart'; // 👈 BẮT BUỘC THÊM DÒNG NÀY

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  const HomeScreen({super.key, required this.currentUserId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<PostModel>> _future;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _future = postService.getFeed();
  }

  // Hàm reload lại trang khi kéo xuống hoặc đăng bài xong
  Future<void> _reload() async {
    setState(() {
      _future = postService.getFeed();
    });
  }

  void _openCreate() async {
    final created = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreatePostScreen()),
    );
    // Nếu đăng bài thành công (trả về true) thì tải lại Feed
    if (created == true) {
      _reload();
    }
  }

  String _appBarTitle() {
    switch (_currentIndex) {
      case 1:
        return 'Friends';
      case 2:
        return 'Profile';
      default:
        return 'Mini Instagram';
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 1:
        return FriendsTab(currentUserId: widget.currentUserId);
      case 2:
        return ProfileTab(currentUserId: widget.currentUserId);
      default:
      // 👇 THAY ĐỔI Ở ĐÂY: Dùng FutureBuilder + PostItem trực tiếp
        return RefreshIndicator(
          onRefresh: _reload, // Kéo xuống để refresh
          child: FutureBuilder<List<PostModel>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Lỗi: ${snapshot.error}"));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("Chưa có bài viết nào"));
              }

              final posts = snapshot.data!;

              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final postModel = posts[index];

                  // 👇 Gọi Widget PostItem (Code mới có nút Like/Comment)
                  // Lưu ý: postModel.toJson() giúp chuyển đổi Model sang Map để PostItem đọc được
                  return PostItem(
                    post: postModel.toJson(),
                    currentUserId: widget.currentUserId,

                    // 👇 THÊM DÒNG NÀY: Khi bài viết bị xóa, tải lại Feed ngay
                    onDeleted: () {
                      _reload();
                    },
                  );
                },
              );
            },
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          _appBarTitle(),
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            // Giữ nguyên logic font chữ của bạn
            fontFamily: _currentIndex == 0 ? 'Billabong' : null,
            fontSize: _currentIndex == 0 ? 30 : 20,
          ),
        ),

        // 👇👇👇 ĐÂY LÀ ĐOẠN MỚI THÊM VÀO 👇👇👇
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 28),
            onPressed: () {
              // Chuyển sang màn hình tìm kiếm
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _buildBody(),

      // Nút đăng bài (Chỉ hiện ở trang Home)
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
        onPressed: _openCreate,
        backgroundColor: const Color(0xFF3797EF),
        child: const Icon(Icons.add),
      )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF3797EF),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false, // Ẩn chữ cho giống Instagram
        showSelectedLabels: false,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          setState(() {
            _currentIndex = i;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 30),
            activeIcon: Icon(Icons.home, size: 30),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined, size: 30),
            activeIcon: Icon(Icons.group, size: 30),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 30),
            activeIcon: Icon(Icons.person, size: 30),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}