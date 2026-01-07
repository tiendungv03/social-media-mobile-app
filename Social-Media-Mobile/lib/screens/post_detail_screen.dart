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
  final FocusNode _commentFocusNode = FocusNode();
  final PostService _postService = PostService(ApiClient());

  String? _replyToCommentId;
  String? _replyToUsername;

  // Danh sách comment ĐÃ ĐƯỢC SẮP XẾP (Cha trước -> Con sau)
  List<Map<String, dynamic>> displayComments = [];
  bool _hasNewComment = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  // ================== LOGIC SẮP XẾP COMMENT (QUAN TRỌNG NHẤT) ==================
  // Hàm này biến danh sách lộn xộn thành: Cha -> Con của nó -> Cha tiếp theo...
  List<Map<String, dynamic>> _organizeComments(List<dynamic> inputList) {
    List<Map<String, dynamic>> rawList = List<Map<String, dynamic>>.from(inputList);

    // 1. Tạo Map để gom nhóm: Key là ID cha, Value là danh sách các con
    Map<String, List<Map<String, dynamic>>> childrenMap = {};
    List<Map<String, dynamic>> rootComments = [];

    // Phân loại Cha và Con
    for (var c in rawList) {
      String? parentId = c['parentId'];

      // Nếu không có parentId hoặc parentId rỗng -> Là Cha (Root)
      if (parentId == null || parentId.toString().isEmpty) {
        rootComments.add(c);
      } else {
        // Là Con -> Gom vào danh sách con của ParentId đó
        if (!childrenMap.containsKey(parentId)) {
          childrenMap[parentId] = [];
        }
        childrenMap[parentId]!.add(c);
      }
    }

    // 2. Dùng hàm đệ quy để trải phẳng danh sách theo thứ tự cây
    List<Map<String, dynamic>> output = [];

    void addNodeAndChildren(Map<String, dynamic> node) {
      output.add(node); // Thêm cha vào danh sách hiển thị

      String nodeId = node['_id'];
      // Kiểm tra xem ông này có con không?
      if (childrenMap.containsKey(nodeId)) {
        // Nếu có, lôi hết con ra thêm vào ngay sau cha
        for (var child in childrenMap[nodeId]!) {
          addNodeAndChildren(child); // Đệ quy (để xử lý trường hợp con của con)
        }
      }
    }

    // Bắt đầu duyệt từ các ông Cha gốc
    for (var root in rootComments) {
      addNodeAndChildren(root);
    }

    return output;
  }

  // ================== LOAD COMMENTS ==================
  Future<void> _loadComments() async {
    try {
      final postId = _getPostId();
      if (postId.isEmpty) return;

      final data = await _postService.getPostDetails(postId);
      final List list = (data != null && data['comments'] != null && data['comments'] is List)
          ? data['comments']
          : [];

      if (mounted) {
        setState(() {
          // Gọi hàm sắp xếp trước khi hiển thị
          displayComments = _organizeComments(list);
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
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final parentId = _replyToCommentId;

    try {
      final postId = _getPostId();
      await _postService.addComment(postId, text, parentId: parentId);

      _commentController.clear();
      _hasNewComment = true;
      FocusScope.of(context).unfocus(); // Ẩn bàn phím

      setState(() {
        _replyToCommentId = null;
        _replyToUsername = null;
      });

      await _loadComments(); // Load lại để thấy comment mới chui vào đúng chỗ
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gửi bình luận thất bại"), backgroundColor: Colors.red),
      );
    }
  }

  // ================== HELPER UI ==================
  List<InlineSpan> _buildCommentContent(String content) {
    if (content.startsWith('@') && content.contains(' ')) {
      int firstSpaceIndex = content.indexOf(' ');
      String userTag = content.substring(0, firstSpaceIndex);
      String message = content.substring(firstSpaceIndex);

      return [
        TextSpan(
          text: userTag,
          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        TextSpan(text: message),
      ];
    }
    return [TextSpan(text: content)];
  }

  void _onBack() {
    Navigator.pop(context, _hasNewComment ? {'updated': true} : null);
  }

  // ================== MAIN BUILD ==================
  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.post is Map ? widget.post['imageUrl'] : widget.post.imageUrl;
    final caption = widget.post is Map ? widget.post['caption'] ?? '' : widget.post.caption;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _onBack),
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
                  const Text("Bình luận", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  if (displayComments.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("Chưa có bình luận nào"),
                    ))
                  else
                  // Dùng list đã sắp xếp (displayComments)
                    ...displayComments.map((c) {
                      final owner = c['owner'] as Map<String, dynamic>?;
                      final username = owner?['username'] ?? 'User';
                      final avatar = owner?['avatarUrl'] ?? '';
                      final content = c['content'] ?? '';
                      final String commentId = (c['_id'] ?? '').toString();

                      // Kiểm tra xem đây có phải là comment con không (có parentId)
                      final bool isReply = (c['parentId'] != null && c['parentId'].toString().isNotEmpty);

                      // Likes Logic
                      // Likes Logic (FIX: handle String or populated user object)
                      final List rawLikes = (c['likes'] as List?) ?? [];

                      final Set<String> likes = rawLikes.map((e) {
                        if (e is String) return e;
                        if (e is Map && e['_id'] != null) return e['_id'].toString(); // populated user
                        return e.toString();
                      }).toSet();

                      final String myId = widget.currentUserId.toString();
                      final bool isLiked = likes.contains(myId);
                      final int likeCount = likes.length;


                      return Padding(
                        // 🔥 ĐÂY LÀ CHỖ TẠO THỤT ĐẦU DÒNG
                        // Nếu là reply -> Thụt vào 45px, ngược lại -> 0
                        padding: EdgeInsets.only(
                            bottom: 12,
                            left: isReply ? 45.0 : 0.0
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar logic: Reply thì nhỏ hơn (size 12), Gốc thì to (size 18)
                            CircleAvatar(
                              radius: isReply ? 14 : 18,
                              backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                              child: avatar.isEmpty ? Icon(Icons.person, size: isReply ? 14 : 18) : null,
                            ),
                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Tên + Nội dung
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(color: Colors.black, fontSize: 14),
                                      children: [
                                        TextSpan(
                                          text: "$username ",
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        ..._buildCommentContent(content),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  // Nút Like + Reply
                                  Row(
                                    children: [
                                      // ❤️ LIKE BUTTON
                                      // ❤️ LIKE BUTTON (ĐÃ FIX LỖI MẤT TIM)
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(20),
                                          onTap: () async {
                                            // 1. Debug xem ID đang xử lý là gì
                                            debugPrint("❤️ Thao tác Like comment: $commentId");

                                            setState(() {
                                              // Lấy danh sách like hiện tại của comment này
                                              List currentLikes = (c['likes'] as List?) ?? [];

                                              if (isLiked) {
                                                // 🔴 UNLIKE (BỎ TIM)
                                                currentLikes.removeWhere((item) {
                                                  String itemId = (item is Map) ? item['_id'].toString() : item.toString();
                                                  return itemId == widget.currentUserId.toString();
                                                });
                                              } else {
                                                // 🟢 LIKE (THẢ TIM)
                                                currentLikes.add(widget.currentUserId);
                                              }
                                              c['likes'] = currentLikes; // Cập nhật UI ngay lập tức
                                            });

                                            // 2. Gọi API
                                            try {
                                              await _postService.likeComment(commentId);
                                            } catch (e) {
                                              // 🔥 PHẦN QUAN TRỌNG MỚI THÊM: Hiện lỗi ra màn hình
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text("Lỗi thả tim: $e"), // In lỗi chi tiết
                                                    backgroundColor: Colors.red,
                                                    duration: const Duration(seconds: 3),
                                                  ),
                                                );
                                              }

                                              debugPrint("❌ Lỗi API Like: $e");

                                              // Load lại danh sách để hoàn tác (revert) trạng thái tim về cũ
                                              await _loadComments();
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(0, 4, 12, 4),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                                  size: 14,
                                                  color: isLiked ? Colors.red : Colors.grey,
                                                ),
                                                if (likeCount > 0) ...[
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    likeCount.toString(),
                                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      // 💬 REPLY BUTTON
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(5),
                                          onTap: () {
                                            setState(() {
                                              // LOGIC THÔNG MINH:
                                              // Nếu bấm reply vào một reply khác -> Lấy ID cha gốc của nó để gom nhóm
                                              String realParentId = (isReply) ? c['parentId'] : commentId;

                                              _replyToCommentId = realParentId;
                                              _replyToUsername = username;

                                              _commentController.text = "@$username ";
                                              _commentController.selection = TextSelection.fromPosition(
                                                  TextPosition(offset: _commentController.text.length)
                                              );
                                            });
                                            FocusScope.of(context).requestFocus(_commentFocusNode);
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            child: Text("Reply", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
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

            // Thanh hiển thị "Đang trả lời..."
            if (_replyToUsername != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: Colors.grey[200],
                child: Row(
                  children: [
                    Expanded(child: Text("Đang trả lời @$_replyToUsername", style: const TextStyle(fontSize: 13))),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _replyToCommentId = null;
                          _replyToUsername = null;
                          _commentController.clear();
                          FocusScope.of(context).unfocus();
                        });
                      },
                      child: const Icon(Icons.close, size: 18),
                    )
                  ],
                ),
              ),

            // Input Area
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        focusNode: _commentFocusNode,
                        decoration: const InputDecoration(
                          hintText: "Thêm bình luận...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
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
