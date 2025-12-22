import '../models/user.dart';
import 'mock_users.dart';

class MockFriendsRepo {
  Future<List<AppUser>> suggestions() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return mockUsers;
  }
}
