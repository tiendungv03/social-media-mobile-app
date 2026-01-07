import 'package:flutter/material.dart';
import '../main.dart'; // dùng authService

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtl = TextEditingController();
  bool _loading = false;
  String? _message;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
      _message = null;
    });

    try {
      final res =
      await authService.forgotPassword(_emailCtl.text.trim());

      setState(() {
        _message = res['message'] ?? 'Vui lòng kiểm tra email';
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quên mật khẩu')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Nhập email để nhận link đặt lại mật khẩu',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _emailCtl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            if (_error != null)
              Text(_error!,
                  style: const TextStyle(color: Colors.red)),

            if (_message != null)
              Text(_message!,
                  style: const TextStyle(color: Colors.green)),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Gửi link reset'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
