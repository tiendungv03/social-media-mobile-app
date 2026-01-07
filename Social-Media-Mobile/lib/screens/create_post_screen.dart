import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart'; // authService, postService
import '../services/cloudinary_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _captionCtl = TextEditingController();
  final _tagsCtl = TextEditingController();

  bool _isSubmitting = false;
  String? _error;

  final _picker = ImagePicker();
  Uint8List? _pickedBytes;
  String? _pickedName;

  // ✅ SỬA LỖI TẠI ĐÂY: Dùng defaultConfig để lấy ID thật
  late final CloudinaryService _cloudinary = CloudinaryService.defaultConfig();

  @override
  void dispose() {
    _captionCtl.dispose();
    _tagsCtl.dispose();
    super.dispose();
  }

  List<String> _parseTags(String raw) {
    return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  Future<void> _pickImage() async {
    try {
      final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (x == null) return;
      final bytes = await x.readAsBytes();
      if (!mounted) return;
      setState(() {
        _pickedBytes = bytes;
        _pickedName = x.name;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = "Lỗi chọn ảnh: $e");
    }
  }

  Future<void> _submitProcess() async {
    if (_pickedBytes == null) {
      setState(() => _error = 'Vui lòng chọn ảnh trước khi đăng!');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      // 1. Upload ảnh lên Cloudinary
      final imageUrl = await _cloudinary.uploadBytes(
        bytes: _pickedBytes!,
        filename: _pickedName ?? 'image.jpg',
        folder: 'posts',
      );

      // 2. Tạo bài viết với URL ảnh vừa có
      await postService.createPost(
        _captionCtl.text.trim(),
        imageUrl,
        _parseTags(_tagsCtl.text),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        // Xóa chữ "Exception: " để thông báo đẹp hơn
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitProcess,
            child: _isSubmitting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Share', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Caption Input
            TextField(
              controller: _captionCtl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Viết chú thích...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Tags Input
            TextField(
              controller: _tagsCtl,
              decoration: const InputDecoration(
                hintText: 'Tags (ví dụ: travel, food)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
              ),
            ),
            const SizedBox(height: 20),

            // Nút chọn ảnh
            if (_pickedBytes == null)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                      Text("Nhấn để chọn ảnh"),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(_pickedBytes!, fit: BoxFit.cover),
                  ),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Chọn ảnh khác"),
                  )
                ],
              ),

            // Hiển thị lỗi đỏ nếu có
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}