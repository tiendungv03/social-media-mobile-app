import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/post_service.dart';
import '../services/profile_service.dart';

class PostDetailScreen extends StatefulWidget {
  final dynamic post;
  final String currentUserId;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.currentUserId
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final PostService _postService = PostService(ApiClient());
  final ProfileService _profileService = ProfileService();

  List<dynamic> comments = [];
  bool _hasNewComment = false;
  Map<String, dynamic>? _myProfile;

  @override
  void initState() {
    super.initState();

    // 1. Load tạm comment cũ từ màn hình Home gửi sang
    try {
      var initialComments = (widget.post is Map)
          ? widget.post['comments']
          : widget.post.comments;
      if (initialComments != null) {
        comments = List.from(initialComments);
      }
    } catch (e) {
      print("Lỗi load comment cũ: $e");
    }

    // 2. Lấy thông tin nick của mình
    _fetchMyProfile();

    // 3. Gọi server lấy dữ liệu mới nhất (để hiển thị comment vừa đăng nếu có)
    _fetchLatestPostData();
  }

  // --- HÀM 1: Lấy thông tin cá nhân ---
  void _fetchMyProfile() async {
    try {
      final data = await _profileService.getUserProfile(widget.currentUserId, widget.currentUserId);
      if (mounted) {
        setState(() {
          _myProfile = data['user'];
        });
      }
    } catch (e) {
      print("Lỗi lấy profile: $e");
    }
  }

  // --- HÀM 2: Lấy dữ liệu bài viết mới nhất từ Server ---
  void _fetchLatestPostData() async {
    try {
      String postId = (widget.post is Map) ? (widget.post['_id'] ?? widget.post['id']) : widget.post.id;

      // 👇 THÊM DÒNG NÀY ĐỂ KIỂM TRA:
      print("🔍 CHECK ID BÀI VIẾT: $postId");
      if (postId == null || postId == 'null' || postId.isEmpty) {
        print("❌ LỖI: ID bài viết bị rỗng!");
        return;
      }

      final updatedPost = await _postService.getPostDetails(postId);

      if (updatedPost != null && mounted) {
        setState(() {
          if (updatedPost['comments'] != null) {
            comments = List.from(updatedPost['comments']);
          }
        });
      }
    } catch (e) {
      print("Lỗi tải dữ liệu mới: $e");
    }
  }

  // --- XỬ LÝ NÚT BACK ---
  void _onPop() {
    if (_hasNewComment) {
      Navigator.pop(context, {'action': 'comment'});
    } else {
      Navigator.pop(context, null);
    }
  }

  // --- XỬ LÝ XÓA BÀI ---
  void _handleDeletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa bài viết?"),
        content: const Text("Hành động này không thể hoàn tác."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Xóa", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      String postId = (widget.post is Map) ? (widget.post['_id'] ?? widget.post['id']) : widget.post.id;
      final success = await _postService.deletePost(postId);
      if (success && mounted) {
        Navigator.pop(context, {'action': 'deleted'});
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa bài viết!")));
      }
    }
  }

  // --- GỬI COMMENT (ĐÃ SỬA) ---
  void _handleSendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    String postId = (widget.post is Map) ? (widget.post['_id'] ?? widget.post['id']) : widget.post.id;

    // Gọi API thêm comment
    final newCommentFromServer = await _postService.addComment(postId, content);

    if (mounted) {
      // ✅ SỬA CHỖ NÀY: Chỉ thêm vào list khi Server trả về dữ liệu thành công
      if (newCommentFromServer != null) {
        setState(() {
          comments.add(newCommentFromServer);
          _commentController.clear();
          _hasNewComment = true;
        });
      } else {
        // ❌ NẾU LỖI: Hiện thông báo đỏ chứ KHÔNG thêm comment giả nữa
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Gửi thất bại! Hãy kiểm tra mạng hoặc đăng nhập lại."),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = (widget.post is Map) ? widget.post['imageUrl'] : widget.post.imageUrl;
    String caption = (widget.post is Map) ? (widget.post['caption'] ?? "") : widget.post.caption;

    String ownerId = '';
    try {
      if (widget.post is Map) {
        if (widget.post['user'] is Map) ownerId = widget.post['user']['id'] ?? widget.post['user']['_id'] ?? '';
        else ownerId = widget.post['user'] ?? '';
      } else {
        ownerId = widget.post.userId;
      }
    } catch (e) { ownerId = ''; }
    bool isOwner = (ownerId == widget.currentUserId);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) { if (didPop) return; _onPop(); },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: _onPop),
          title: const Text("Chi tiết", style: TextStyle(color: Colors.black)),
          actions: [
            if (isOwner) IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: _handleDeletePost)
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.black,
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 200, maxHeight: 500),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[900],
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.image_not_supported, color: Colors.white54, size: 50),
                                SizedBox(height: 8),
                                Text("Ảnh bị lỗi hoặc bị chặn", style: TextStyle(color: Colors.white54)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (caption.isNotEmpty) ...[
                            Text(caption, style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 10),
                            const Divider(),
                          ],
                          const Text("Bình luận", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          comments.isEmpty
                              ? const Padding(padding: EdgeInsets.only(top: 20), child: Center(child: Text("Chưa có bình luận nào.", style: TextStyle(color: Colors.grey))))
                              : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final c = comments[index];
                              String content = c is Map ? (c['content'] ?? "") : c.toString();

                              String username = "User";
                              String avatar = "";

                              if (c is Map) {
                                // 👇 SỬA Ở ĐÂY: Ưu tiên lấy 'owner' (Code mới), nếu không có thì lấy 'user' (Code cũ)
                                final userObj = c['owner'] ?? c['user'];

                                if (userObj is Map) {
                                  // Lấy username hoặc name tùy bạn
                                  username = userObj['username'] ?? "User";
                                  // Nếu muốn hiện tên thật (BUI DIEU) thì dùng dòng dưới này:
                                  // username = userObj['name'] ?? userObj['username'] ?? "User";

                                  avatar = userObj['avatarUrl'] ?? "";
                                } else if (c['username'] != null) {
                                  username = c['username'];
                                }
                              }

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: (avatar.isNotEmpty) ? NetworkImage(avatar) : null,
                                  child: avatar.isEmpty ? const Icon(Icons.person, size: 16) : null,
                                ),
                                title: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(color: Colors.black, fontSize: 14),
                                    children: [
                                      TextSpan(text: "$username ", style: const TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: content),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[300]!))),
              child: Row(
                children: [
                  Expanded(child: TextField(controller: _commentController, decoration: const InputDecoration(hintText: "Thêm bình luận...", border: InputBorder.none, isDense: true))),
                  IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: _handleSendComment),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}