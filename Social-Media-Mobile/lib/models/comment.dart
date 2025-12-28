class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String text;
  final DateTime createdAt;
  final String username;
  final String avatarUrl;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    required this.createdAt,
    required this.username,
    required this.avatarUrl,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return CommentModel(
      id: json['_id'],
      postId: json['post'],
      userId: user['_id'] ?? '',
      text: json['text'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      username: user['username'] ?? '',
      avatarUrl: user['avatarUrl'] ?? '',
    );
  }
}
