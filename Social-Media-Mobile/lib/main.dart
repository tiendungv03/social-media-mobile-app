import 'package:flutter/material.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/post_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

final apiClient = ApiClient();
final authService = AuthService(apiClient);
final postService = PostService(apiClient);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Instagram',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      initialRoute: '/',
    );
  }
}
