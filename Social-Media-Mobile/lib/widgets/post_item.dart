import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/post_service.dart';
import '../screens/post_detail_screen.dart';

class PostItem extends StatefulWidget {
  final dynamic post;
  final String currentUserId;
  final VoidCallback? onDeleted;

  const PostItem({
    super.key,
    required this.post,
    required this.currentUserId,
    this.onDeleted,
  });

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  bool _isLiked = false;
  bool _isSaved = false;
  int _likeCount = 0;
  int _commentCount = 0;
  final PostService _postService = PostService(ApiClient());

  @override
  void initState() {
    super.initState();
    // 1. Like logic
    List likes = (widget.post['likes'] as List?) ?? [];
    _isLiked = likes.contains(widget.currentUserId);
    _likeCount = likes.length;

    // 2. Comment count logic
    _commentCount = (widget.post['comments'] as List?)?.length ??
        widget.post['commentsCount'] ?? 0;
  }

  void _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    try {
      String postId = widget.post['id'] ?? widget.post['_id'];
      await _postService.toggleLike(postId);
    } catch (e) {
      print("Lỗi like: $e");
    }
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isSaved ? "Đã lưu bài viết" : "Đã bỏ lưu"), duration: const Duration(milliseconds: 500))
    );
  }

  void _sharePost() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã sao chép liên kết! 🚀"), duration: Duration(seconds: 1))
    );
  }

  // --- HÀM MỞ TRANG CHI TIẾT ---
  void _openPostDetail() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(
            post: widget.post,
            currentUserId: widget.currentUserId
        ),
      ),
    );

    if (result != null && result is Map) {
      if (result['action'] == 'deleted') {
        widget.onDeleted?.call();
      } else if (result['action'] == 'comment') {
        setState(() {
          _commentCount++; // Tăng số comment nếu quay lại từ trang chi tiết
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String avatarUrl = '';
    String username = 'User';
    if (widget.post['user'] != null && widget.post['user'] is Map) {
      avatarUrl = widget.post['user']['avatarUrl'] ?? '';
      username = widget.post['user']['username'] ?? 'User';
    }

    String imageUrl = widget.post['imageUrl'] ?? '';
    String caption = widget.post['caption'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. HEADER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              ClipOval(
                child: Container(
                  width: 32, height: 32,
                  color: Colors.grey[200],
                  child: avatarUrl.isNotEmpty
                      ? Image.network(avatarUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.person))
                      : const Icon(Icons.person),
                ),
              ),
              const SizedBox(width: 10),
              Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        // 2. ẢNH BÀI VIẾT (Bấm vào ảnh cũng mở chi tiết)
        GestureDetector(
          onTap: _openPostDetail, // 👈 Bấm vào ảnh -> Mở chi tiết
          child: Container(
            color: Colors.grey[100],
            constraints: const BoxConstraints(maxHeight: 400),
            width: double.infinity,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (c,e,s) => const SizedBox(height: 200, child: Icon(Icons.broken_image)),
            ),
          ),
        ),

        // 3. HÀNG NÚT BẤM
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: _isLiked ? Colors.red : Colors.black, size: 28),
                onPressed: _toggleLike,
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, size: 26),
                onPressed: _openPostDetail, // 👈 Bấm nút chat -> Mở chi tiết
              ),
              Transform.rotate(
                angle: -0.6,
                child: IconButton(icon: const Icon(Icons.send_outlined, size: 26), onPressed: _sharePost),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border, size: 28),
                onPressed: _toggleSave,
              ),
            ],
          ),
        ),

        // 4. THÔNG TIN (LIKE, CAPTION, COMMENT)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_likeCount > 0)
                Text("$_likeCount lượt thích", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(text: "$username ", style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: caption),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // 👇 PHẦN QUAN TRỌNG BẠN CẦN ĐÂY 👇
              if (_commentCount > 0)
                GestureDetector(
                  onTap: _openPostDetail, // ✅ GỌI HÀM MỞ TRANG CHI TIẾT TẠI ĐÂY
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2), // Tăng diện tích bấm
                    child: Text(
                        "Xem tất cả $_commentCount bình luận",
                        style: const TextStyle(color: Colors.grey, fontSize: 13)
                    ),
                  ),
                ),
              // 👆 HẾT PHẦN QUAN TRỌNG 👆

              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}