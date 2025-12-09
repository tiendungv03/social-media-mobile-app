import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient api;
  AppUser? currentUser;

  AuthService(this.api);

  Future<void> login(String usernameOrEmail, String password) async {
    final data = await api.post('/auth/login', {
      'usernameOrEmail': usernameOrEmail,
      'password': password,
    });
    final token = data['token'] as String;
    api.setToken(token);
    currentUser = AppUser.fromJson(data['user']);
  }

  Future<void> register(String name, String username, String email, String password) async {
    final data = await api.post('/auth/register', {
      'name': name,
      'username': username,
      'email': email,
      'password': password,
    });
    final token = data['token'] as String;
    api.setToken(token);
    currentUser = AppUser.fromJson(data['user']);
  }
}
