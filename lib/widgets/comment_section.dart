import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import '../models/comment_model.dart';

/// Panel bình luận dạng bottom sheet, nhận articleUrl qua tham số
class CommentSection extends StatefulWidget {
  final String articleUrl;

  const CommentSection({super.key, required this.articleUrl});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _supabase = Supabase.instance.client;
  final _commentController = TextEditingController();
  List<CommentModel> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _getRelativeTime(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(date);
    }
    return timeago.format(date, locale: 'vi');
  }

  Future<void> _loadComments() async {
    try {
      final data = await _supabase
          .from('comments')
          .select()
          .eq('article_url', widget.articleUrl)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _comments = data.map((json) => CommentModel.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải bình luận: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitComment() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Vui lòng đăng nhập để bình luận!')),
      );
      return;
    }

    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    _commentController.clear();
    FocusScope.of(context).unfocus();

    try {
      await _supabase.from('comments').insert({
        'article_url': widget.articleUrl,
        'user_id': user.id,
        'user_name': user.userMetadata?['full_name'] ?? 'Fan Bóng Đá',
        'user_avatar': user.userMetadata?['avatar_url'] ?? '',
        'content': content,
      });
      _loadComments();
    } catch (e) {
      debugPrint('Lỗi đăng bình luận: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '💬 Bình luận',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const Divider(color: Colors.white24, height: 1),

        // Danh sách bình luận
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.greenAccent),
                )
              : _comments.isEmpty
              ? const Center(
                  child: Text(
                    'Hãy là người đầu tiên bình luận!',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final c = _comments[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: c.userAvatar.isNotEmpty
                            ? NetworkImage(c.userAvatar)
                            : null,
                        child: c.userAvatar.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        c.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        c.content,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Text(
                        _getRelativeTime(c.createdAt),
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Ô nhập bình luận
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          color: Colors.black,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Nhập bình luận của bạn...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.greenAccent,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.black),
                  onPressed: _submitComment,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
