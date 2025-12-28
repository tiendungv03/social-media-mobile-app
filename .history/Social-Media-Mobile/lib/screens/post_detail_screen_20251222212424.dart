import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/post_service.dart';
// import '../models/post.dart'; // Bỏ comment nếu bạn muốn dùng PostModel

class PostDetailScreen extends StatefulWidget {
  // Thay vì chỉ nhận imageUrl, ta cần nhận cả object bài viết để lấy ID
  final dynamic post; 
  final String currentUserId; // Để kiểm tra xem có phải chủ bài viết không

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
  final PostService _postService = PostService(ApiClient()); // Khởi tạo service
  
  List<dynamic> comments = []; // Danh sách comment

  @override
  void initState() {
    super.initState();
    // Lấy dữ liệu comments từ bài viết (nếu có sẵn)
    try {
      // Xử lý linh hoạt cho cả Map và PostModel
      var initialComments = (widget.post is Map) 
          ? widget.post['comments'] 
          : widget.post.comments; 
          
      if (initialComments != null) {
        comments = List.from(initialComments);
      }
    } catch (e) {
      print("Không tải được comment cũ: $e");
    }
  }

  // --- 1. XỬ LÝ XÓA BÀI VIẾT ---
  void _handleDeletePost() async {
    // Hiện hộp thoại xác nhận
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa bài viết?"),
        content: const Text("Bạn có chắc chắn muốn xóa bài này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text("Xóa", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Lấy ID (xử lý linh hoạt Map hoặc Model)
      String postId = (widget.post is Map) ? (widget.post['_id'] ?? widget.post['id']) : widget.post.id;
      
      final success = await _postService.deletePost(postId);
      
      if (success && mounted) {
        Navigator.pop(context, true); // Quay về và báo thành công
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa bài viết!")));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi khi xóa!")));
      }
    }
  }

  // --- 2. XỬ LÝ GỬI COMMENT ---
  void _handleSendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    String postId = (widget.post is Map) ? (widget.post['_id'] ?? widget.post['id']) : widget.post.id;

    // Gọi API thêm comment
    final newComment = await _postService.addComment(postId, content);

    if (mounted) {
      setState(() {
        if (newComment != null) {
          comments.add(newComment); // Thêm comment thật từ server
        } else {
          // Nếu API trả về null (lỗi nhẹ), ta tự tạo comment giả để hiện cho mượt
          comments.add({'content': content, 'username': 'Me'}); 
        }
        _commentController.clear(); // Xóa ô nhập
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin hiển thị (Map hoặc Model)
    String imageUrl = (widget.post is Map) ? widget.post['imageUrl'] : widget.post.imageUrl;
    String caption = (widget.post is Map) ? (widget.post['caption'] ?? "") : widget.post.caption;
    
    // Kiểm tra quyền sở hữu để hiện nút xóa
    String ownerId = '';
    try {
      if (widget.post is Map) {
         // Tùy cấu trúc API trả về user là object hay string id
         if (widget.post['user'] is Map) {
           ownerId = widget.post['user']['id'] ?? widget.post['user']['_id'] ?? '';
         } else {
           ownerId = widget.post['user'] ?? '';
         }
      } else {
         ownerId = widget.post.userId; // Nếu là Model
      }
    } catch (e) { ownerId = ''; }

    bool isOwner = (ownerId == widget.currentUserId);

    return Scaffold(
      backgroundColor: Colors.white, // Chuyển sang nền trắng cho dễ đọc comment
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Chi tiết", style: TextStyle(color: Colors.black)),
        actions: [
          // 👇 NÚT XÓA (Chỉ hiện nếu là chủ bài viết)
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _handleDeletePost,
            )
        ],
      ),
      body: Column(
        children: [
          // Phần nội dung cuộn được (Ảnh + Caption + List Comment)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ảnh
                  Container(
                    color: Colors.black, // Nền đen cho ảnh để nổi bật
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 200, maxHeight: 500),
                    child: Image.network(imageUrl, fit: BoxFit.contain),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Caption
                        if (caption.isNotEmpty) ...[
                          Text(caption, style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 10),
                          const Divider(),
                        ],
                        
                        // Tiêu đề bình luận
                        const Text("Bình luận", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        
                        // Danh sách Comments
                        comments.isEmpty 
                          ? const Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Center(child: Text("Chưa có bình luận nào.", style: TextStyle(color: Colors.grey))),
                            )
                          : ListView.builder(
                              shrinkWrap: true, // Quan trọng để nằm trong ScrollView
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final c = comments[index];
                                String content = c is Map ? (c['content'] ?? "") : c.toString();
                                // Xử lý tên người comment
                                String username = "User";
                                if (c is Map) {
                                  if (c['user'] is Map) username = c['user']['username'] ?? "User";
                                  else if (c['username'] != null) username = c['username'];
                                }
                                
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: RichText(
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

          // 👇 THANH NHẬP BÌNH LUẬN (Ghim đáy màn hình)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Thêm bình luận...",
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _handleSendComment,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}