// lib/screens/login_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart'; // dùng apiClient + authService global
import '../services/google_auth_service.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import 'register_screen.dart'; // nhớ tạo màn này

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  final _googleAuth = GoogleAuthService();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  Future<void> _saveAuthAndGoHome({
    required String token,
    required String userId,
  }) async {
    // ✅ lưu token theo đúng key "auth_token" (khớp ApiClient + main.dart)
    await apiClient.setToken(token);

    // ✅ lưu userId
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(currentUserId: userId)),
    );
  }

  // -------------------------
  // LOGIN USERNAME/PASSWORD
  // -------------------------
  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await authService.login(
        _usernameCtl.text.trim(),
        _passwordCtl.text.trim(),
      );

      if (!mounted) return;

      if (data == null) {
        setState(() => _error = "Đăng nhập thất bại");
        return;
      }

      final token = data['token']?.toString();
      final userObj = data['user'];
      final userId = (userObj is Map)
          ? (userObj['_id'] ?? userObj['id'])?.toString()
          : null;

      if (token == null || token.isEmpty) {
        throw Exception("Server không trả về token");
      }
      if (userId == null || userId.isEmpty) {
        throw Exception("Không tìm thấy userId");
      }

      await _saveAuthAndGoHome(token: token, userId: userId);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll("Exception: ", "");
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // -------------------------
  // LOGIN GOOGLE -> BACKEND /auth/google
  // -------------------------
  Future<void> _loginWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1) Firebase sign-in (web popup / mobile native)
      final fbUser = await _googleAuth.signInWithGoogle();
      if (fbUser == null) {
        setState(() => _error = "Bạn đã hủy đăng nhập Google");
        return;
      }

      // 2) lấy ID TOKEN để gửi về server
      final idToken = await fbUser.getIdToken();
      if (idToken!.isEmpty) throw Exception("Không lấy được Google idToken");

      // 3) gọi backend: POST /api/auth/google  body: { idToken }
      final res = await apiClient.post('/auth/google', {'idToken': idToken});

      if (res.statusCode != 200) {
        String msg = "Google login thất bại";
        try {
          final j = jsonDecode(res.body);
          msg = (j is Map && j['message'] != null) ? j['message'].toString() : msg;
        } catch (_) {}
        throw Exception(msg);
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final token = data['token']?.toString();

      final userObj = data['user'];
      final userId = (userObj is Map)
          ? (userObj['_id'] ?? userObj['id'])?.toString()
          : null;

      if (token == null || token.isEmpty) throw Exception("Server không trả về token");
      if (userId == null || userId.isEmpty) throw Exception("Không tìm thấy userId");

      await _saveAuthAndGoHome(token: token, userId: userId);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll("Exception: ", "");
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                    textAlign: TextAlign.center,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Log In',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                    Expanded(child: Container(height: 0.5, color: Colors.grey.shade400)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(child: Container(height: 0.5, color: Colors.grey.shade400)),
                  ],
                ),

                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _loading ? null : _loginWithGoogle,
                  icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 26),
                  label: const Text(
                    'Log in with Google',
                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),

                const SizedBox(height: 32),

                Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          'Sign up.',
                          style: TextStyle(color: Color(0xFF3797EF), fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
