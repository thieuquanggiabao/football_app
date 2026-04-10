import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/news_model.dart';
import '../repositories/reaction_repository.dart';
import 'comment_section.dart';
import 'reaction_button.dart';

/// Thẻ hiển thị một bài báo đơn lẻ với các chức năng tương tác (Like, Comment, Share)
class NewsCard extends StatefulWidget {
  final NewsModel news; // Dữ liệu bài báo
  final String Function(String) formatTime; // Hàm định dạng thời gian từ bên ngoài truyền vào

  const NewsCard({
    super.key,
    required this.news,
    required this.formatTime,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  final _repo = ReactionRepository(); // Lớp xử lý dữ liệu cảm xúc (Database)
  final _supabase = Supabase.instance.client;

  // CÁC BIẾN QUẢN LÝ TRẠNG THÁI TẠI CHỖ (LOCAL STATE)
  int _likeCount = 0; // Tổng số lượt thích
  int _dislikeCount = 0; // Tổng số lượt không thích
  String? _myReaction; // Cảm xúc của chính người dùng hiện tại ('LIKE', 'DISLIKE' hoặc null)
  bool _isLoading = true; // Trạng thái đang tải lượt tương tác từ server

  @override
  void initState() {
    super.initState();
    _loadReactions(); // Tải số lượng Like/Dislike ngay khi thẻ hiện lên
  }

  /// Tải thông tin tương tác từ Database dựa trên URL bài báo
  Future<void> _loadReactions() async {
    final userId = _supabase.auth.currentUser?.id;
    try {
      final result = await _repo.getReactions(widget.news.articleUrl, userId);
      if (mounted) {
        setState(() {
          _likeCount = result.likeCount;
          _dislikeCount = result.dislikeCount;
          _myReaction = result.myReaction;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi load reaction: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// KỸ THUẬT OPTIMISTIC UI: Cập nhật giao diện ngay lập tức trước khi server phản hồi
  Future<void> _toggleReaction(String type) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Vui lòng đăng nhập để thả cảm xúc!')),
      );
      return;
    }

    // SAO LƯU TRẠNG THÁI CŨ (Để dùng nếu cần hoàn tác - Rollback)
    final prevReaction = _myReaction;
    final prevLike = _likeCount;
    final prevDislike = _dislikeCount;

    // BƯỚC 1: CẬP NHẬT GIAO DIỆN NGAY LẬP TỨC (SETSTATE)
    setState(() {
      if (_myReaction == type) {
        // Nếu nhấn lại vào nút đã chọn -> Huỷ chọn (Unlike/Undislike)
        _myReaction = null;
        if (type == 'LIKE') _likeCount = (_likeCount - 1).clamp(0, 999999);
        else _dislikeCount = (_dislikeCount - 1).clamp(0, 999999);
      } else {
        // Nếu chuyển từ Like sang Dislike hoặc ngược lại
        if (_myReaction == 'LIKE') _likeCount = (_likeCount - 1).clamp(0, 999999);
        if (_myReaction == 'DISLIKE') _dislikeCount = (_dislikeCount - 1).clamp(0, 999999);
        
        _myReaction = type;
        if (type == 'LIKE') _likeCount += 1;
        else _dislikeCount += 1;
      }
    });

    // BƯỚC 2: GỬI LỆNH LÊN SERVER (DATABASE)
    try {
      if (prevReaction == type) {
        await _repo.deleteReaction(articleUrl: widget.news.articleUrl, userId: user.id);
      } else {
        await _repo.upsertReaction(articleUrl: widget.news.articleUrl, userId: user.id, reactionType: type);
      }
    } catch (e) {
      // BƯỚC 3: HOÀN TÁC (ROLLBACK) NẾU LỖI MẠNG
      if (mounted) {
        setState(() {
          _myReaction = prevReaction;
          _likeCount = prevLike;
          _dislikeCount = prevDislike;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Lỗi kết nối, đã hoàn tác tương tác!'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  /// Hiển thị bảng bình luận (Bottom Sheet)
  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.6,
          child: CommentSection(articleUrl: widget.news.articleUrl),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final news = widget.news;

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          // Mở bài báo gốc qua trình duyệt tích hợp
          final uri = Uri.parse(news.articleUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.inAppWebView);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh minh họa bài báo
            Image.network(
              news.imageUrl,
              height: 180, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 180, color: Colors.grey[800], child: const Icon(Icons.image_not_supported, color: Colors.white24)),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thời gian xuất bản
                  Text(widget.formatTime(news.publishedAt), style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),

                  // Tiêu đề chính bài báo
                  Text(news.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24, height: 1),

                  // THANH HÀNH ĐỘNG (Bình luận, Like, Dislike, Share)
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _showComments,
                        icon: const Icon(Icons.comment, color: Colors.greenAccent, size: 20),
                        label: const Text('Bình luận', style: TextStyle(color: Colors.greenAccent)),
                      ),
                      const Spacer(),
                      // Nút Like
                      ReactionButton(
                        icon: _myReaction == 'LIKE' ? Icons.thumb_up : Icons.thumb_up_outlined,
                        color: _myReaction == 'LIKE' ? Colors.blueAccent : Colors.white54,
                        count: _isLoading ? null : _likeCount,
                        onTap: () => _toggleReaction('LIKE'),
                      ),
                      const SizedBox(width: 4),
                      // Nút Dislike
                      ReactionButton(
                        icon: _myReaction == 'DISLIKE' ? Icons.thumb_down : Icons.thumb_down_outlined,
                        color: _myReaction == 'DISLIKE' ? Colors.redAccent : Colors.white54,
                        count: _isLoading ? null : _dislikeCount,
                        onTap: () => _toggleReaction('DISLIKE'),
                      ),
                      const SizedBox(width: 4),
                      // Nút Share (Chia sẻ)
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white54, size: 20),
                        onPressed: () {
                          final shareText = '🔥 Đọc ngay: ${news.title}\n👉 Chi tiết tại: ${news.articleUrl}';
                          SharePlus.instance.share(ShareParams(text: shareText));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
