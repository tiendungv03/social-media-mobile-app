import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;
  final String currentName;
  final String currentBio;
  final String currentAvatar;

  const EditProfileScreen({
    super.key,
    required this.userId,
    required this.currentName,
    required this.currentBio,
    required this.currentAvatar,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtl = TextEditingController();
  final _bioCtl = TextEditingController();
  final _avatarCtl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtl.text = widget.currentName;
    _bioCtl.text = widget.currentBio;
    _avatarCtl.text = widget.currentAvatar;
  }

  void _saveProfile() async {
    setState(() => _isLoading = true);
    final service = ProfileService();
    // Gọi API lưu
    bool success = await service.updateProfile(
      widget.userId, 
      _nameCtl.text, 
      _bioCtl.text, 
      _avatarCtl.text
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true); // Trả về 'true' để báo cho màn hình trước biết là cần load lại
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi cập nhật")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Edit Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
              : const Icon(Icons.check, color: Colors.blue, size: 30),
            onPressed: _isLoading ? null : _saveProfile,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar input (Tạm thời dùng link ảnh)
            CircleAvatar(radius: 40, backgroundImage: NetworkImage(_avatarCtl.text.isNotEmpty ? _avatarCtl.text : widget.currentAvatar)),
            TextButton(onPressed: () {}, child: const Text("Change profile photo")),
            const SizedBox(height: 20),
            
            // Input Name
            TextField(controller: _nameCtl, decoration: const InputDecoration(labelText: "Name")),
            const SizedBox(height: 10),
            
            // Input Bio
            TextField(controller: _bioCtl, decoration: const InputDecoration(labelText: "Bio")),
            const SizedBox(height: 10),

             // Input Avatar URL (Tạm thời nhập link)
            TextField(controller: _avatarCtl, decoration: const InputDecoration(labelText: "Avatar URL (Link ảnh)")),
          ],
        ),
      ),
    );
  }
}