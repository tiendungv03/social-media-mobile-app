import 'dart:convert';
import 'api_client.dart'; // Import file ApiClient cũ của bạn

class UserService {
  final ApiClient apiClient = ApiClient();

  //1. TÌM KIẾM NGƯỜI DÙNG
  // Hàm này nhận vào chữ 'query' (ví dụ: "dieu") và trả về danh sách người
  Future<List<dynamic>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];

      // Gọi lên Server: /users/search?q=dieu
      final response = await apiClient.get('/users/search?q=$query');

      if (response.statusCode == 200) {
        final List<dynamic> users = jsonDecode(response.body);
        return users;
      } else {
        return [];
      }
    } catch (e) {
      print("Lỗi tìm kiếm: $e");
      return [];
    }
  }

  // 👇 THÊM HÀM NÀY: Lấy thông tin chi tiết 1 người (bao gồm cả trạng thái bạn bè)
  Future<Map<String, dynamic>?> getUserProfile(String targetUserId) async {
    try {
      // Gọi API: /users/profile/ID_NGUOI_KIA
      // (Lưu ý: Nếu server của bạn cần currentUserId để check bạn bè thì truyền thêm vào query)
      final response = await apiClient.get('/users/profile/$targetUserId');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Lỗi lấy profile: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối profile: $e");
      return null;
    }
  }

  // 👇 3. Gửi lời mời kết bạn (Follow)
  Future<bool> sendFriendRequest(String targetUserId) async {
    try {
      // Chỉ cần gọi hàm post, nếu server OK nó sẽ trả về dữ liệu
      await apiClient.post('/friends/request/$targetUserId', {});

      // Nếu chạy đến đây mà không bị nhảy xuống catch -> Thành công
      return true;
    } catch (e) {
      print("Lỗi gửi kết bạn: $e");
      return false;
    }
  }

  // 👇 4. Hủy kết bạn / Hủy lời mời (Đã sửa lỗi statusCode)
  Future<bool> unfriend(String targetUserId) async {
    try {
      await apiClient.post('/friends/unfriend/$targetUserId', {});

      // Nếu chạy đến đây -> Thành công
      return true;
    } catch (e) {
      print("Lỗi hủy kết bạn: $e");
      return false;
    }
  }
}




