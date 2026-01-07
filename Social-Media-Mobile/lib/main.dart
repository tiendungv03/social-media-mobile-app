import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/post_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

// Khởi tạo các Service
// Vì ApiClient là Singleton nên gọi ApiClient() ở đâu cũng là một instance duy nhất
final apiClient = ApiClient();
final authService = AuthService();
final postService = PostService(apiClient);

void main() async {
  // 1. Đảm bảo Flutter binding đã khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  // 2. 👇 QUAN TRỌNG: Gọi hàm này để ApiClient tự nạp Token từ ổ cứng lên RAM
  // Nếu không có dòng này, ApiClient sẽ bị rỗng (No token) dù đã đăng nhập.
  await apiClient.loadTokenFromStorage();

  // 3. Lấy dữ liệu từ bộ nhớ để quyết định màn hình bắt đầu
  final prefs = await SharedPreferences.getInstance();

  // ⚠️ LƯU Ý: Phải dùng key 'auth_token' cho khớp với file api_client.dart
  final String? token = prefs.getString('auth_token');
  final String? userId = prefs.getString('userId'); // (Đảm bảo bạn đã lưu userId lúc login)

  Widget startScreen;

  // 4. Logic điều hướng
  if (token != null && token.isNotEmpty) {
    print("✅ Đã đăng nhập, vào thẳng Home. User: $userId");
    // Không cần gọi apiClient.setToken(token) nữa vì hàm loadTokenFromStorage đã làm rồi
    startScreen = HomeScreen(currentUserId: userId ?? '');
  } else {
    print("⚠️ Chưa có token, vào Login.");
    startScreen = const LoginScreen();
  }

  runApp(MyApp(startScreen: startScreen));
}

class MyApp extends StatelessWidget {
  final Widget startScreen;

  const MyApp({super.key, required this.startScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mini Instagram',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: startScreen,
    );
  }
}