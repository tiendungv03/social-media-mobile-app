// models/friends.dart
class Friends {
  final String id;
  final String senderId;
  final String receiverId;
  final String status; // 'pending', 'accepted', 'blocked'

  Friends({required this.id, required this.senderId, required this.receiverId, required this.status});
}