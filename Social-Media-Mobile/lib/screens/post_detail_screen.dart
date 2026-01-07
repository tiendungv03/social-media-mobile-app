import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/post_service.dart';

class PostDetailScreen extends StatefulWidget {
  final dynamic post;
  final String currentUserId;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.currentUserId,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final PostService _postService = PostService(ApiClient());

  String? _replyToCommentId;
  String? _replyToUsername;


  List<Map<String, dynamic>> comments = [];
  bool _hasNewComment = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  // ================== LOAD COMMENTS ==================
  Future<void> _loadComments() async {
    try {
      final postId = _getPostId();
      if (postId.isEmpty) return;

      final data = await _postService.getPostDetails(postId);

      debugPrint("🔥 FULL POST API = $data");

      final List list =
      (data != null && data['comments'] != null && data['comments'] is List) ? data['comments'] : [];

      debugPrint("🔥 COMMENTS API = $list");

      if (mounted) {
        setState(() {
          comments = List<Map<String, dynamic>>.from(list);
        });
      }
    } catch (e) {
      debugPrint("❌ Load comments error: $e");
    }
  }

  String _getPostId() {
    return (widget.post is Map)
        ? (widget.post['_id'] ?? widget.post['id'] ?? '')
        : widget.post.id;
  }

  // ================== SEND COMMENT ==================
  Future<void> _handleSendComment() async {

    setState(() {
      _replyToCommentId = null;
      _replyToUsername = null;
    });

    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    try {
      final postId = _getPostId();
      await _postService.addComment(postId, text,  parentId: _replyToCommentId);

      _commentController.clear();
      _hasNewComment = true;

      setState(() {
        _replyToCommentId = null;
        _replyToUsername = null;
      });

      await _loadComments(); // load lại comment từ server
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gửi bình luận thất bại"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================== BACK ==================
  void _onBack() {
    Navigator.pop(context, _hasNewComment ? {'updated': true} : null);
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    final imageUrl =
    widget.post is Map ? widget.post['imageUrl'] : widget.post.imageUrl;
    final caption =
    widget.post is Map ? widget.post['caption'] ?? '' : widget.post.caption;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _onBack,
          ),
          title: const Text("Chi tiết"),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Image.network(imageUrl, fit: BoxFit.cover),
                  if (caption.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(caption, style: const TextStyle(fontSize: 16)),
                    const Divider(),
                  ],
                  const Text(
                    "Bình luận",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  if (comments.isEmpty)
                    const Center(child: Text("Chưa có bình luận nào"))
                  else
                    ...comments.map((c) {
                      final owner = c['owner'] as Map<String, dynamic>?;
                      final username = owner?['username'] ?? 'User';
                      final avatar = owner?['avatarUrl'] ?? '';
                      final content = c['content'] ?? '';
                      final commentId = c['_id'];

                      final List likes = (c['likes'] as List?) ?? [];
                      final bool isLiked = likes.contains(widget.currentUserId);
                      final int likeCount = likes.length;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage:
                              avatar.isNotEmpty ? NetworkImage(avatar) : null,
                              child: avatar.isEmpty
                                  ? const Icon(Icons.person, size: 16)
                                  : null,
                            ),
                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // USERNAME + CONTENT
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(color: Colors.black),
                                      children: [
                                        TextSpan(
                                          text: "$username ",
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(text: content),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  // LIKE + REPLY
                                  Row(
                                  children: [
                                  // ❤️ LIKE
                                  Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                  onTap: () async {
                                  debugPrint("❤️ CLICK LIKE $commentId");
                                  await _postService.likeComment(commentId);
                                  await _loadComments();
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  child: Row(
                                  children: [
                                  Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  size: 16,
                                  color: isLiked ? Colors.red : Colors.grey,
                      ),
                      if (likeCount > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                      likeCount.toString(),
                      style: const TextStyle(fontSize: 12),
                      ),
                      ],
                      ],
                      ),
                      ),
                      ),
                      ),

                      const SizedBox(width: 16),

                      // 💬 REPLY
                      Material(
                      color: Colors.transparent,
                      child: InkWell(
                      onTap: () {
                      debugPrint("💬 REPLY TO $commentId");
                      setState(() {
                      _replyToCommentId = commentId;
                      _replyToUsername = username;
                      });
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Text(
                      "Reply",
                      style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      ),
                      ),
                      ),
                      ),
                      ),
                      ],
                      )

                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                ],
              ),
            ),
            if (_replyToUsername != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Đang trả lời @$_replyToUsername",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _replyToCommentId = null;
                          _replyToUsername = null;
                        });
                      },
                      child: const Icon(Icons.close, size: 16),
                    )
                  ],
                ),
              ),



            // ================== INPUT ==================
            SafeArea(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: "Thêm bình luận...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send,
                          color: Colors.blue),
                      onPressed: _handleSendComment,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
