import 'package:flutter/material.dart';
import '../main.dart'; // Import authService

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Dùng Form để validate dễ hơn
  bool _loading = false;

  // Hàm kiểm tra định dạng email
  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  Future<void> _submit() async {
    // 1. Ẩn bàn phím ngay lập tức
    FocusScope.of(context).unfocus();

    final email = _emailCtl.text.trim();

    // 2. Validate phía Client trước
    if (email.isEmpty) {
      _showSnackBar('Vui lòng nhập email', isError: true);
      return;
    }
    if (!_isValidEmail(email)) {
      _showSnackBar('Định dạng email không hợp lệ', isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      // 3. Gọi API
      final res = await authService.forgotPassword(email);

      if (!mounted) return;

      // 4. Thành công -> Hiện Dialog xịn xò
      _showSuccessDialog(res?['message'] ?? 'Vui lòng kiểm tra email của bạn.');

    } catch (e) {
      if (!mounted) return;
      // 5. Lỗi -> Hiện SnackBar
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      _showSnackBar(errorMsg, isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green,
        behavior: SnackBarBehavior.floating, // Nổi lên đẹp hơn
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Bắt buộc bấm nút OK
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text("Đã gửi mail!"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Đóng dialog
              Navigator.pop(context); // Quay về màn hình Login
            },
            child: const Text("Về trang đăng nhập"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
        elevation: 0,
      ),
      body: SingleChildScrollView( // Chống tràn khi bàn phím hiện
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Icon minh họa cho đẹp
            Icon(Icons.lock_reset, size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 20),

            const Text(
              'Đừng lo lắng!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Nhập email đã đăng ký, chúng tôi sẽ gửi hướng dẫn đặt lại mật khẩu cho bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: _emailCtl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done, // Nút Enter trên phím -> Done
              onSubmitted: (_) => _submit(), // Bấm Enter là submit luôn
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'vidu@gmail.com',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                )
                    : const Text('Gửi yêu cầu', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}