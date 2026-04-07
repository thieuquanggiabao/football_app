import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/news_model.dart';
import '../repositories/reaction_repository.dart';
import 'comment_section.dart';
import 'reaction_button.dart';

/// Card tin tức với trạng thái Like/Dislike độc lập (Optimistic UI)
class NewsCard extends StatefulWidget {
  final NewsModel news;
  final String Function(String) formatTime;

  const NewsCard({
    super.key,
    required this.news,
    required this.formatTime,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  final _repo = ReactionRepository();
  final _supabase = Supabase.instance.client;

  int _likeCount = 0;
  int _dislikeCount = 0;
  String? _myReaction;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReactions();
  }

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

  Future<void> _toggleReaction(String type) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Vui lòng đăng nhập để thả cảm xúc!')),
      );
      return;
    }

    // Snapshot trạng thái cũ để rollback nếu lỗi
    final prevReaction = _myReaction;
    final prevLike = _likeCount;
    final prevDislike = _dislikeCount;

    // --- OPTIMISTIC UI ---
    setState(() {
      if (_myReaction == type) {
        _myReaction = null;
        if (type == 'LIKE') {
          _likeCount = (_likeCount - 1).clamp(0, 999999);
        } else {
          _dislikeCount = (_dislikeCount - 1).clamp(0, 999999);
        }
      } else {
        if (_myReaction == 'LIKE') _likeCount = (_likeCount - 1).clamp(0, 999999);
        if (_myReaction == 'DISLIKE') _dislikeCount = (_dislikeCount - 1).clamp(0, 999999);
        _myReaction = type;
        if (type == 'LIKE') {
          _likeCount += 1;
        } else {
          _dislikeCount += 1;
        }
      }
    });

    // --- DB operation ---
    try {
      if (prevReaction == type) {
        await _repo.deleteReaction(
          articleUrl: widget.news.articleUrl,
          userId: user.id,
        );
      } else {
        await _repo.upsertReaction(
          articleUrl: widget.news.articleUrl,
          userId: user.id,
          reactionType: type,
        );
      }
    } catch (e) {
      debugPrint('Lỗi toggle reaction: $e');
      // --- ROLLBACK ---
      if (mounted) {
        setState(() {
          _myReaction = prevReaction;
          _likeCount = prevLike;
          _dislikeCount = prevDislike;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Có lỗi xảy ra, vui lòng thử lại!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
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
          final uri = Uri.parse(news.articleUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.inAppWebView);
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('❌ Không thể mở bài báo này!')),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh bìa
            Image.network(
              news.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 180,
                color: Colors.grey[800],
                child: const Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.white54,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thời gian
                  Text(
                    widget.formatTime(news.publishedAt),
                    style: TextStyle(
                      color: Colors.greenAccent[400],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Tiêu đề
                  Text(
                    news.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24, height: 1),

                  // Hàng nút tương tác
                  Row(
                    children: [
                      // Bình luận
                      TextButton.icon(
                        onPressed: _showComments,
                        icon: const Icon(
                          Icons.comment,
                          color: Colors.greenAccent,
                          size: 20,
                        ),
                        label: const Text(
                          'Bình luận',
                          style: TextStyle(color: Colors.greenAccent),
                        ),
                      ),

                      const Spacer(),

                      // Like
                      ReactionButton(
                        icon: _myReaction == 'LIKE'
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        color: _myReaction == 'LIKE'
                            ? Colors.blueAccent
                            : Colors.white54,
                        count: _isLoading ? null : _likeCount,
                        onTap: () => _toggleReaction('LIKE'),
                      ),

                      const SizedBox(width: 4),

                      // Dislike
                      ReactionButton(
                        icon: _myReaction == 'DISLIKE'
                            ? Icons.thumb_down
                            : Icons.thumb_down_outlined,
                        color: _myReaction == 'DISLIKE'
                            ? Colors.redAccent
                            : Colors.white54,
                        count: _isLoading ? null : _dislikeCount,
                        onTap: () => _toggleReaction('DISLIKE'),
                      ),

                      const SizedBox(width: 4),

                      // Chia sẻ
                      IconButton(
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white54,
                          size: 20,
                        ),
                        onPressed: () {
                          final shareText =
                              '🔥 Đọc ngay tin nóng: ${news.title}\n\n👉 Chi tiết tại: ${news.articleUrl}';
                           SharePlus.instance.share(
                              ShareParams(text: shareText),
                            );
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
