// lib/models/friends.dart

class FriendRequest {
  final String id;
  final String requesterId; // ID người gửi
  final String recipientId; // ID người nhận
  // final String status;      // 'pending', 'accepted', 'rejected'
  final String createdAt;

  FriendRequest({
    required this.id,
    required this.requesterId,
    required this.recipientId,
    // required this.status,
    required this.createdAt,
  });

  // Hàm này giúp chuyển dữ liệu JSON từ Server thành Object Dart
  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['_id'] ?? '', // MongoDB thường trả về _id
      requesterId: json['requester'] ?? '',
      recipientId: json['recipient'] ?? '',
      // status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] ?? '',
    );
  }
}