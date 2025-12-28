import 'package:flutter/material.dart';
import 'services/api_client.dart';
import 'screens/login_screen.dart';

final apiClient = ApiClient();

void main() {
  // 👇 Chỉ gọi MyApp đơn giản, không truyền tham số gì cả
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // 👇 Constructor đơn giản, không đòi startScreen nữa
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mini Instagram',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // 👇 Luôn luôn mở màn hình Login đầu tiên
      home: const LoginScreen(),
    );
  }
}