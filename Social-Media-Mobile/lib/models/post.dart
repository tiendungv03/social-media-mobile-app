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
  });

  factory PostModel.fromJson(dynamic raw) {
    final Map<String, dynamic> json = Map<String, dynamic>.from(raw as Map);

    // owner có thể là object hoặc chỉ là string id
    final dynamic ownerRaw = json['owner'];
    String ownerId = '';
    String ownerName = '';
    String ownerAvatar = '';

    if (ownerRaw is Map) {
      final owner = Map<String, dynamic>.from(ownerRaw);
      ownerId = (owner['_id'] ?? owner['id'] ?? '').toString();
      ownerName = (owner['username'] ?? owner['name'] ?? '').toString();
      ownerAvatar = (owner['avatarUrl'] ?? '').toString();
    } else if (ownerRaw != null) {
      ownerId = ownerRaw.toString();
    }

    // createdAt có thể null → dùng now
    final createdAtRaw = json['createdAt'];
    DateTime created;
    if (createdAtRaw is String) {
      created = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
    } else {
      created = DateTime.now();
    }

    final tagsRaw = json['tags'];
    final likesRaw = json['likes'];

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
    );
  }
}
