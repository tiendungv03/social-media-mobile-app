class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String text;
  final DateTime createdAt;
  final String username;
  final String avatarUrl;

  /// null = comment gốc, != null = reply của comment khác
  final String? parentCommentId;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    required this.createdAt,
    required this.username,
    required this.avatarUrl,
    this.parentCommentId,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] as Map?)?.cast<String, dynamic>() ?? {};
    return CommentModel(
      id: (json['_id'] ?? '').toString(),
      postId: (json['post'] ?? '').toString(),
      userId: (user['_id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      createdAt: DateTime.parse((json['createdAt'] ?? '').toString()),
      username: (user['username'] ?? '').toString(),
      avatarUrl: (user['avatarUrl'] ?? '').toString(),
      parentCommentId: json['parentCommentId']
          ?.toString(), // <== thêm field này
    );
  }

}
