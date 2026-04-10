import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import '../models/comment_model.dart';

/// Panel bình luận dạng bottom sheet, nhận articleUrl qua tham số làm định danh để lọc dữ liệu
class CommentSection extends StatefulWidget {
  final String articleUrl; // Đường dẫn bài báo dùng làm "khóa" để lọc bình luận

  const CommentSection({super.key, required this.articleUrl});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  // 1. KHỞI TẠO CÁC BIẾN QUẢN LÝ TRẠNG THÁI VÀ KẾT NỐI
  final _supabase = Supabase.instance.client; // Kết nối tới dự án Supabase
  final _commentController = TextEditingController(); // Quản lý nội dung trong ô nhập văn bản
  List<CommentModel> _comments = []; // Danh sách các bình luận lấy từ server về
  bool _isLoading = true; // Biến trạng thái để hiển thị vòng xoay đang tải (Loading)

  @override
  void initState() {
    super.initState();
    _loadComments(); // Vừa mở bảng lên là gọi hàm tải dữ liệu ngay
  }

  @override
  void dispose() {
    _commentController.dispose(); // Hủy controller khi đóng bảng để tránh rò rỉ bộ nhớ
    super.dispose();
  }

  /// Hàm hỗ trợ: Chuyển đổi thời gian từ máy chủ sang ngôn ngữ tự nhiên (vi)
  String _getRelativeTime(DateTime date) {
    final difference = DateTime.now().difference(date);
    // Nếu quá 7 ngày thì hiện ngày tháng năm cụ thể, ngược lại hiện "x phút/giờ trước"
    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(date);
    }
    return timeago.format(date, locale: 'vi');
  }

  /// LUỒNG DỮ LIỆU RA (OUTPUT): Tải bình luận từ Database về App
  Future<void> _loadComments() async {
    try {
      // Truy vấn bảng 'comments' lọc theo bài báo và sắp xếp mới nhất lên đầu
      final data = await _supabase
          .from('comments')
          .select()
          .eq('article_url', widget.articleUrl) // Chỉ lấy bình luận của bài báo này
          .order('created_at', ascending: false); // Bình luận mới nhất xếp lên đầu

      if (mounted) {
        setState(() {
          // Chuyển đổi dữ liệu JSON từ server thành danh sách đối tượng CommentModel
          _comments = data.map((json) => CommentModel.fromJson(json)).toList();
          _isLoading = false; // Tắt trạng thái Loading
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải bình luận: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// LUỒNG DỮ LIỆU VÀO (INPUT): Đẩy bình luận mới từ App lên Database
  Future<void> _submitComment() async {
    final user = _supabase.auth.currentUser; // Lấy thông tin người dùng hiện tại
    
    // Kiểm tra quyền: Phải đăng nhập mới được bình luận
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Vui lòng đăng nhập để bình luận!')),
      );
      return;
    }

    final content = _commentController.text.trim();
    if (content.isEmpty) return; // Nếu ô nhập trống thì không làm gì cả

    // Xóa nội dung ô nhập và ẩn bàn phím ngay để tạo cảm giác mượt mà (UX)
    _commentController.clear();
    FocusScope.of(context).unfocus();

    try {
      // Đẩy dữ liệu lên bảng 'comments' (Thực hiện lệnh INSERT)
      await _supabase.from('comments').insert({
        'article_url': widget.articleUrl, // Link bài báo làm định danh
        'user_id': user.id, // ID người dùng (khóa ngoại)
        'user_name': user.userMetadata?['full_name'] ?? 'Fan Bóng Đá', // Tên từ Metadata
        'user_avatar': user.userMetadata?['avatar_url'] ?? '', // Lấy ảnh đại diện
        'content': content, // Nội dung bình luận
      });
      
      // Sau khi đăng thành công, gọi lại hàm tải để cập nhật danh sách mới
      _loadComments();
    } catch (e) {
      debugPrint('Lỗi đăng bình luận: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PHẦN TIÊU ĐỀ BẢNG
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

        // PHẦN HIỂN THỊ DANH SÁCH BÌNH LUẬN (Dùng Expanded để chiếm trọn không gian còn lại)
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.greenAccent),
                ) // Trạng thái đang tải
              : _comments.isEmpty
              ? const Center(
                  child: Text(
                    'Hãy là người đầu tiên bình luận!',
                    style: TextStyle(color: Colors.white54),
                  ),
                ) // Trạng thái trống
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

        // PHẦN Ô NHẬP VĂN BẢN (Giao diện Dark Mode)
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
              // Nút gửi bài viết với màu xanh neon nổi bật
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
