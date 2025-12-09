class AppUser {
  final String id;
  final String name;
  final String username;
  final String email;
  final String avatarUrl;
  final String bio;

  AppUser({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.bio,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? json['_id'],
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      bio: json['bio'] ?? '',
    );
  }
}
