import 'package:flutter/material.dart';
import '../services/comment_service.dart';

class CommentScreen extends StatefulWidget {
  final String postId;

  const CommentScreen({super.key, required this.postId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final CommentService _service = CommentService();
  final TextEditingController _textCtl = TextEditingController();

  bool _loading = true;
  bool _sending = false;
  List<dynamic> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final data = await _service.getComments(widget.postId);
      setState(() {
        _comments = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _sendComment() async {
    if (_textCtl.text.trim().isEmpty) return;

    setState(() => _sending = true);

    try {
      final newComment = await _service.createComment(
        widget.postId,
        _textCtl.text.trim(),
      );

      setState(() {
        _comments.add(newComment);
        _textCtl.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không gửi được comment')),
      );
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _comments.length,
              itemBuilder: (_, i) {
                final c = _comments[i];
                final user = c['user'];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user['avatarUrl'] != null
                        ? NetworkImage(user['avatarUrl'])
                        : null,
                    child: user['avatarUrl'] == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(
                    user['username'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(c['text'] ?? ''),
                );
              },
            ),
          ),

          // input comment
          SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textCtl,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: _sending
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.send),
                    onPressed: _sending ? null : _sendComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
