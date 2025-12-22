// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../main.dart'; // Để dùng authService toàn cục
import 'home_screen.dart'; // Import để chuyển sang màn hình Home

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
      // 👇 1. Gọi API Login
      final data = await authService.login(
        _usernameCtl.text.trim(),
        _passwordCtl.text.trim(),
      );

      if (!mounted) return;

      // 👇 2. IN LOG RA CONSOLE ĐỂ DEBUG (Quan trọng)
      print("🔍 DATA TẠI LOGIN SCREEN: $data");

      // 👇 3. LẤY ID AN TOÀN (Tránh lỗi Null)
      // Ép kiểu data['user'] thành Map để truy cập an toàn
      final userObj = data['user'] is Map ? data['user'] as Map<String, dynamic> : null;

      // Tìm ID ở mọi ngóc ngách có thể (user._id, user.id, data._id, data.id)
      String? userId = userObj?['_id'] ?? userObj?['id'] ?? data['_id'] ?? data['id'];

      // 👇 4. KIỂM TRA LẠI LẦN CUỐI
      if (userId == null) {
        throw Exception("Lỗi: Không tìm thấy ID người dùng.\nDữ liệu server trả về: $data");
      }

      print("✅ Đã tìm thấy User ID: $userId");

      // 👇 5. CHUYỂN TRANG
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(currentUserId: userId!),
        ),
      );

    } catch (e) {
      print("❌ Lỗi đăng nhập: $e");
      setState(() {
        // Hiển thị lỗi ngắn gọn cho người dùng đỡ sợ
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

  // --- PHẦN GIAO DIỆN (UI) GIỮ NGUYÊN NHƯ CŨ ---
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFFF2F2F2),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
        const BorderSide(color: Color(0xFFBDBDBD), width: 0.7),
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
                  onPressed: () {},
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
                // (Giữ nguyên phần còn lại của UI như nút Google, Sign up...)
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Google Sign-In
                  },
                  icon: const Icon(
                    Icons.g_mobiledata, // icon G tạm
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
                          // TODO: chuyển sang màn Register
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