import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/news_model.dart';
import '../repositories/reaction_repository.dart';
import 'comment_section.dart';
import 'reaction_button.dart';

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

    final prevReaction = _myReaction;
    final prevLike = _likeCount;
    final prevDislike = _dislikeCount;

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

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Xám đậm hiện đại
        borderRadius: BorderRadius.circular(20), // Bo góc sâu hơn
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)), // Viền mờ tinh tế
        boxShadow: [
          // Hiệu ứng đổ bóng 3D
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: const Offset(0, 8),
            blurRadius: 12,
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () async {
            final uri = Uri.parse(news.articleUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.inAppWebView);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Animation (Tag phải là duy nhất, ở đây dùng articleUrl)
              Hero(
                tag: news.articleUrl,
                child: Image.network(
                  news.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 200,
                    color: Colors.grey[800],
                    child: const Icon(Icons.image_not_supported, color: Colors.white24),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.formatTime(news.publishedAt),
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      news.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white10, height: 1),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Nút bình luận kiểu hiện đại
                        InkWell(
                          onTap: _showComments,
                          child: Row(
                            children: [
                              const Icon(Icons.chat_bubble_outline, color: Colors.greenAccent, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                'Bình luận',
                                style: TextStyle(color: Colors.grey[400], fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        ReactionButton(
                          icon: _myReaction == 'LIKE' ? Icons.thumb_up : Icons.thumb_up_outlined,
                          color: _myReaction == 'LIKE' ? Colors.blueAccent : Colors.grey,
                          count: _isLoading ? null : _likeCount,
                          onTap: () => _toggleReaction('LIKE'),
                        ),
                        const SizedBox(width: 12),
                        ReactionButton(
                          icon: _myReaction == 'DISLIKE' ? Icons.thumb_down : Icons.thumb_down_outlined,
                          color: _myReaction == 'DISLIKE' ? Colors.redAccent : Colors.grey,
                          count: _isLoading ? null : _dislikeCount,
                          onTap: () => _toggleReaction('DISLIKE'),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.ios_share, color: Colors.white54, size: 20),
                          onPressed: () {
                            final shareText = '🔥 ${news.title}\n\n👉 Xem ngay: ${news.articleUrl}';
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
      ),
    );
  }
}
