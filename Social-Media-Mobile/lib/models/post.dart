// lib/models/post.dart

class PostModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String ownerAvatar;
  final String caption;
  final String imageUrl;
  final List<String> tags;
  final List<String> likes;
  final int commentsCount;
  final DateTime createdAt;

  // 👇 1. THÊM BIẾN NÀY ĐỂ CHỨA COMMENT THẬT
  final List<dynamic> comments;

  PostModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerAvatar,
    required this.caption,
    required this.imageUrl,
    required this.tags,
    required this.likes,
    required this.commentsCount,
    required this.createdAt,
    required this.comments, // 👇 Thêm vào constructor
  });

  // --- HÀM FROM JSON (Đọc dữ liệu từ Server) ---
  factory PostModel.fromJson(dynamic raw) {
    final Map<String, dynamic> json = Map<String, dynamic>.from(raw as Map);

    // Xử lý Owner
    final dynamic ownerRaw = json['owner'] ?? json['user'];
    String ownerId = '';
    String ownerName = '';
    String ownerAvatar = '';

    if (ownerRaw is Map) {
      final owner = Map<String, dynamic>.from(ownerRaw);
      ownerId = (owner['_id'] ?? owner['id'] ?? '').toString();
      ownerName = (owner['username'] ?? owner['name'] ?? 'User').toString();
      ownerAvatar = (owner['avatarUrl'] ?? '').toString();
    } else if (ownerRaw != null) {
      ownerId = ownerRaw.toString();
    }

    // Xử lý ngày tháng
    final createdAtRaw = json['createdAt'];
    DateTime created;
    if (createdAtRaw is String) {
      created = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
    } else {
      created = DateTime.now();
    }

    final tagsRaw = json['tags'];
    final likesRaw = json['likes'];

    // 👇 Xử lý Comments thật từ Server
    final commentsRaw = json['comments'];
    List<dynamic> realComments = [];
    if (commentsRaw is List) {
      realComments = commentsRaw;
    }

    return PostModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      ownerId: ownerId,
      ownerName: ownerName,
      ownerAvatar: ownerAvatar,
      caption: (json['caption'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      tags: (tagsRaw is List)
          ? tagsRaw.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList()
          : <String>[],
      likes: (likesRaw is List)
          ? likesRaw.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList()
          : <String>[],
      commentsCount: (json['commentsCount'] ?? 0) is int
          ? json['commentsCount'] as int
          : int.tryParse(json['commentsCount'].toString()) ?? 0,
      createdAt: created,
      comments: realComments, // 👇 Gán dữ liệu thật vào đây
    );
  }

  // --- HÀM TO JSON (Trả dữ liệu ra để hiển thị) ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'caption': caption,
      'imageUrl': imageUrl,
      'tags': tags,
      'likes': likes,
      'commentsCount': commentsCount,
      'createdAt': createdAt.toIso8601String(),

      // Tái tạo object user
      'user': {
        'id': ownerId,
        '_id': ownerId,
        'username': ownerName,
        'name': ownerName,
        'avatarUrl': ownerAvatar,
      },

      // 👇 TRẢ VỀ LIST COMMENT THẬT (Không còn rỗng nữa)
      'comments': comments,
    };
  }
}