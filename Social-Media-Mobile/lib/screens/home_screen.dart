// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/post.dart';
import '../widgets/post_list.dart';
import '../widgets/friends_tab.dart';
import '../widgets/profile_tab.dart';
import 'create_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
        return const FriendsTab();
      case 2:
        return const ProfileTab();
      default:
        return PostList(
          future: _future,
          postService: postService,
          onReload: _reload,
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
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _buildBody(),
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
        showUnselectedLabels: true,
        onTap: (i) {
          setState(() {
            _currentIndex = i;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
