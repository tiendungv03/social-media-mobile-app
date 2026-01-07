import 'package:flutter/material.dart';
import '../main.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtl = TextEditingController();
  final _usernameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();

  bool _loading = false;
  String? _error;

  InputDecoration _input(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: const Color(0xFFF2F2F2),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
  );

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await authService.register(
        _nameCtl.text.trim(),
        _usernameCtl.text.trim(),
        _emailCtl.text.trim(),
        _passwordCtl.text.trim(),
      );

      if (!mounted) return;

      if (data == null) {
        setState(() => _error = "Đăng ký thất bại");
        return;
      }

      final u = data['user'];
      final userId = (u is Map) ? (u['_id'] ?? u['id']) : null;

      if (userId == null) {
        setState(() => _error = "Thiếu userId từ server");
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(currentUserId: userId.toString())),
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _usernameCtl.dispose();
    _emailCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Sign up"), backgroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _nameCtl, decoration: _input("Name")),
            const SizedBox(height: 12),
            TextField(controller: _usernameCtl, decoration: _input("Username")),
            const SizedBox(height: 12),
            TextField(controller: _emailCtl, decoration: _input("Email")),
            const SizedBox(height: 12),
            TextField(controller: _passwordCtl, decoration: _input("Password"), obscureText: true),

            const SizedBox(height: 12),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("Create account"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
