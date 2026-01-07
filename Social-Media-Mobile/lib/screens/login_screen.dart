// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 👇 1. Import thư viện này để lưu UserID
import '../main.dart'; // Để dùng authService và apiClient toàn cục
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import 'register_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Gọi API Login
      final data = await authService.login(
        _usernameCtl.text.trim(),
        _passwordCtl.text.trim(),
      );

      if (!mounted) return;

      print("🔍 DATA TẠI LOGIN SCREEN: $data");

      // --- BẮT ĐẦU PHẦN SỬA ĐỔI QUAN TRỌNG ---

      // 1. Lấy Token từ dữ liệu trả về
      final token = data['token'];
      if (token == null || token.toString().isEmpty) {
        throw Exception("Lỗi: Server không trả về Token.");
      }

      // 2. Lấy User ID an toàn
      final userObj = data['user'] is Map ? data['user'] as Map<String, dynamic> : null;
      String? userId = userObj?['_id'] ?? userObj?['id'] ?? data['_id'] ?? data['id'];

      if (userId == null) {
        throw Exception("Lỗi: Không tìm thấy ID người dùng.");
      }

      print("✅ Đã tìm thấy User ID: $userId");

      // 3. 👇 QUAN TRỌNG: LƯU DỮ LIỆU VÀO BỘ NHỚ MÁY
      // Bước này giúp main.dart có dữ liệu để tự động đăng nhập lần sau

      // a. Lưu Token (Hàm này trong ApiClient đã có lệnh lưu vào SharedPreferences key 'auth_token')
      await apiClient.setToken(token);

      // b. Lưu UserID (Để main.dart đọc được)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);

      // --- KẾT THÚC PHẦN SỬA ĐỔI ---

      // 4. Chuyển trang
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(currentUserId: userId!),
          ),
        );
      }

    } catch (e) {
      print("❌ Lỗi đăng nhập: $e");
      setState(() {
        _error = e.toString().contains("Exception:")
            ? e.toString().replaceAll("Exception: ", "")
            : "Đăng nhập thất bại. Vui lòng thử lại.";
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // --- PHẦN UI GIỮ NGUYÊN KHÔNG ĐỔI ---
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFFF2F2F2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFBDBDBD), width: 0.7),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Mini Instagram',
                  style: TextStyle(
                    fontFamily: 'Billabong',
                    fontSize: 42,
                    color: Colors.black,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 32),

                TextField(
                  controller: _usernameCtl,
                  style: const TextStyle(color: Colors.black),
                  decoration: _inputDecoration('Username hoặc Email'),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _passwordCtl,
                  style: const TextStyle(color: Colors.black),
                  decoration: _inputDecoration('Password'),
                  obscureText: true,
                ),

                const SizedBox(height: 8),
                if (_error != null)
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.redAccent, fontSize: 13),
                  ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3797EF),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                      const Color(0xFF3797EF).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                      CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                TextButton(
                  onPressed: () {Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  );},
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 0.5,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 0.5,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Google Sign-In
                  },
                  icon: const Icon(
                    Icons.g_mobiledata,
                    color: Colors.red,
                    size: 26,
                  ),
                  label: const Text(
                    'Log in with Google',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.shade300,
                        width: 0.5,
                      ),
                    ),
                  ),
                  padding:
                  const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                            color: Colors.black54, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign up.',
                          style: TextStyle(
                            color: Color(0xFF3797EF),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}