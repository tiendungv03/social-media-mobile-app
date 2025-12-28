// // lib/models/user.dart

// class AppUser {
//   // 1. Tất cả đều là final (Không cho sửa trực tiếp)
//   final String id;
//   final String name;
//   final String username;
//   final String email;
//   final String avatarUrl;
//   final String bio;
//   // final String status;

//   AppUser({
//     required this.id,
//     required this.name,
//     required this.username,
//     required this.email,
//     required this.avatarUrl,
//     required this.bio,
//     // this.status = 'none',
//   });

//   factory AppUser.fromJson(Map<String, dynamic> json) {
//     return AppUser(
//       id: json['id'] ?? json['_id'] ?? '',
//       name: json['name'] ?? '',
//       username: json['username'] ?? '',
//       email: json['email'] ?? '',
//       avatarUrl: json['avatarUrl'] ?? '',
//       bio: json['bio'] ?? '',
//       // status: json['status'] ?? 'none',
//     );
//   }

//   // 2. Hàm copyWith (Đặt ở cuối class)
//   // Nhiệm vụ: Tạo ra một bản sao (clone) của user hiện tại, 
//   // nhưng cho phép thay đổi một vài thông tin mới.
//   AppUser copyWith({
//     String? id,
//     String? name,
//     String? username,
//     String? email,
//     String? avatarUrl,
//     String? bio,
//     String? status,
//   }) {
//     return AppUser(
//       id: id ?? this.id,                     // Nếu có id mới thì lấy, không thì giữ id cũ
//       name: name ?? this.name,               // Tương tự...
//       username: username ?? this.username,
//       email: email ?? this.email,
//       avatarUrl: avatarUrl ?? this.avatarUrl,
//       bio: bio ?? this.bio,
//       // status: status ?? this.status,         // Quan trọng nhất là dòng này
//     );
//   }
// }


// lib/models/user.dart

class AppUser {
  // 1. Giữ nguyên final để đảm bảo tính toàn vẹn dữ liệu
  final String id;
  final String name;
  final String username;
  final String email;
  final String avatarUrl;
  final String bio;
  
  // 👇 Đã mở lại trường này (Kiểu String để lưu trạng thái kết bạn)
  final String status; 

  AppUser({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.bio,
    this.status = 'none', // Mặc định là 'none' (Chưa kết bạn)
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      bio: json['bio'] ?? '',
      
      // 👇 LOGIC FIX XUNG ĐỘT (QUAN TRỌNG NHẤT) 👇
      // Giải thích: 
      // - Nếu MongoDB trả về true/false (Active status) -> Bỏ qua, gán là 'none'.
      // - Nếu MongoDB trả về chuỗi (VD: "pending", "friend") -> Lấy giá trị đó.
      status: (json['status'] is String) ? json['status'] : 'none',
    );
  }

  // 2. Hàm copyWith đã được bỏ comment để hoạt động
  AppUser copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    String? avatarUrl,
    String? bio,
    String? status, // Cho phép truyền status mới vào để sửa
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      
      // 👇 Cập nhật status mới (nếu có), không thì giữ nguyên cái cũ
      status: status ?? this.status, 
    );
  }
}