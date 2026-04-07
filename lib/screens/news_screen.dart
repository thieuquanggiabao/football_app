import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final _supabase = Supabase.instance.client;
  String _favoriteTeam = '';

  @override
  void initState() {
    super.initState();
    _loadFavoriteTeam();
  }

  // Kéo tên đội bóng yêu thích từ hồ sơ người dùng
  void _loadFavoriteTeam() {
    final user = _supabase.auth.currentUser;
    setState(() {
      _favoriteTeam = user?.userMetadata?['favorite_team'] ?? '';
    });
  }

  // Hàm mở Bảng trượt Bình luận
  void _showComments(BuildContext context, String articleUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: CommentSection(articleUrl: articleUrl),
        ),
      ),
    );
  }

  // Chuyển đổi chuỗi thời gian
  String _formatTime(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp).toLocal();
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inHours > 24) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  // Hàm gom logic vẽ Danh sách tin tức
  Widget _buildNewsFeed(
    Future<List<Map<String, dynamic>>> futureData,
    String emptyMessage,
  ) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.greenAccent),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              '❌ Lỗi tải tin tức!',
              style: TextStyle(color: Colors.redAccent),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              emptyMessage,
              style: const TextStyle(color: Colors.white54),
            ),
          );
        }

        final newsList = snapshot.data!;

        return RefreshIndicator(
          color: Colors.greenAccent,
          onRefresh: () async {
            setState(() {}); // Kích hoạt tải lại luồng tin
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              // Mỗi item là một NewsCard StatefulWidget riêng biệt
              return NewsCard(
                news: news,
                formatTime: _formatTime,
                onCommentTap: () =>
                    _showComments(context, news['article_url']),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text(
            'Tin tức Bóng đá',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.black,
          foregroundColor: Colors.greenAccent,
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.greenAccent,
            labelColor: Colors.greenAccent,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(icon: Icon(Icons.article), text: 'Mới nhất'),
              Tab(icon: Icon(Icons.shield), text: 'Đội của bạn'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Load toàn bộ tin mới nhất
            _buildNewsFeed(
              _supabase
                  .from('news')
                  .select()
                  .order('published_at', ascending: false)
                  .limit(20),
              'Chưa có tin tức nào.',
            ),

            // Tab 2: Load tin theo từ khóa đội bóng
            _favoriteTeam.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 80,
                          color: Colors.grey[800],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Bạn chưa chọn đội bóng yêu thích!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Hãy chọn ở mục Tài khoản nhé.',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  )
                : _buildNewsFeed(
                    _supabase
                        .from('news')
                        .select()
                        .or(
                          'title.ilike.%$_favoriteTeam%,description.ilike.%$_favoriteTeam%',
                        )
                        .order('published_at', ascending: false)
                        .limit(20),
                    'Hiện chưa có bài báo nào nhắc đến $_favoriteTeam.',
                  ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET CARD TIN TỨC (StatefulWidget riêng)
// ==========================================
class NewsCard extends StatefulWidget {
  final Map<String, dynamic> news;
  final String Function(String) formatTime;
  final VoidCallback onCommentTap;

  const NewsCard({
    super.key,
    required this.news,
    required this.formatTime,
    required this.onCommentTap,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  final _supabase = Supabase.instance.client;

  int _likeCount = 0;
  int _dislikeCount = 0;
  String? _myReaction; // 'LIKE', 'DISLIKE', hoặc null
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReactions();
  }

  // Tải số lượng Like/Dislike và trạng thái của user hiện tại
  Future<void> _loadReactions() async {
    final user = _supabase.auth.currentUser;
    final articleUrl = widget.news['article_url'] as String;

    try {
      // 1. Đếm tổng số LIKE
      final likeRes = await _supabase
          .from('article_reactions')
          .select('id')
          .eq('article_url', articleUrl)
          .eq('reaction_type', 'LIKE')
          .count(CountOption.exact);

      // 2. Đếm tổng số DISLIKE
      final dislikeRes = await _supabase
          .from('article_reactions')
          .select('id')
          .eq('article_url', articleUrl)
          .eq('reaction_type', 'DISLIKE')
          .count(CountOption.exact);

      // 3. Kiểm tra xem user hiện tại đã react chưa
      String? myStatus;
      if (user != null) {
        final myRes = await _supabase
            .from('article_reactions')
            .select('reaction_type')
            .eq('article_url', articleUrl)
            .eq('user_id', user.id)
            .maybeSingle();
        if (myRes != null) myStatus = myRes['reaction_type'];
      }

      if (mounted) {
        setState(() {
          _likeCount = likeRes.count;
          _dislikeCount = dislikeRes.count;
          _myReaction = myStatus;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi load reaction: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Toggle Like hoặc Dislike với Optimistic UI
  Future<void> _toggleReaction(String type) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Vui lòng đăng nhập để thả cảm xúc!'),
        ),
      );
      return;
    }

    final articleUrl = widget.news['article_url'] as String;

    // --- Lưu trạng thái cũ để rollback nếu lỗi ---
    final prevReaction = _myReaction;
    final prevLikeCount = _likeCount;
    final prevDislikeCount = _dislikeCount;

    // --- OPTIMISTIC UI: Cập nhật giao diện NGAY LẬP TỨC ---
    setState(() {
      if (_myReaction == type) {
        // Bấm lại vào icon đang chọn → Hủy reaction
        _myReaction = null;
        if (type == 'LIKE') {
          _likeCount = (_likeCount - 1).clamp(0, 999999);
        } else {
          _dislikeCount = (_dislikeCount - 1).clamp(0, 999999);
        }
      } else {
        // Bấm vào icon khác hoặc chưa chọn → Đổi/thêm mới
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

    // --- Thực thi thao tác DB sau khi UI đã cập nhật ---
    try {
      if (prevReaction == type) {
        // Hủy: Xóa record khỏi DB
        await _supabase
            .from('article_reactions')
            .delete()
            .eq('article_url', articleUrl)
            .eq('user_id', user.id);
      } else {
        // Thêm hoặc đổi: Dùng upsert với onConflict để ghi đè nếu đã tồn tại
        await _supabase.from('article_reactions').upsert(
          {
            'article_url': articleUrl,
            'user_id': user.id,
            'reaction_type': type,
          },
          onConflict: 'article_url,user_id',
        );
      }
    } catch (e) {
      debugPrint('Lỗi toggle reaction: $e');
      // --- ROLLBACK: Hoàn tác nếu DB lỗi ---
      if (mounted) {
        setState(() {
          _myReaction = prevReaction;
          _likeCount = prevLikeCount;
          _dislikeCount = prevDislikeCount;
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

  @override
  Widget build(BuildContext context) {
    final news = widget.news;

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          final Uri url = Uri.parse(news['article_url']);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.inAppWebView);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('❌ Không thể mở bài báo này!'),
                ),
              );
            }
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh bìa bài báo
            Image.network(
              news['image_url'] ?? '',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.white54,
                  ),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thời gian đăng
                  Text(
                    widget.formatTime(news['published_at']),
                    style: TextStyle(
                      color: Colors.greenAccent[400],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Tiêu đề bài báo
                  Text(
                    news['title'],
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
                      // Nút Bình luận
                      TextButton.icon(
                        onPressed: widget.onCommentTap,
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

                      // Nút Like
                      _ReactionButton(
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

                      // Nút Dislike
                      _ReactionButton(
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

                      // Nút Chia sẻ
                      IconButton(
                        icon: const Icon(
                          Icons.share,
                          color: Colors.white54,
                          size: 20,
                        ),
                        onPressed: () {
                          final String shareText =
                              '🔥 Đọc ngay tin nóng: ${news['title']}\n\n👉 Chi tiết tại: ${news['article_url']}';
                          Share.share(shareText);
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

// ==========================================
// WIDGET NÚT REACTION (Like / Dislike)
// ==========================================
class _ReactionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int? count; // null = đang loading
  final VoidCallback onTap;

  const _ReactionButton({
    required this.icon,
    required this.color,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                icon,
                key: ValueKey(icon),
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 4),
            count == null
                ? SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Colors.white38,
                    ),
                  )
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      '$count',
                      key: ValueKey(count),
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET BẢNG TRƯỢT BÌNH LUẬN
// ==========================================
class CommentSection extends StatefulWidget {
  final String articleUrl;
  const CommentSection({super.key, required this.articleUrl});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _supabase = Supabase.instance.client;
  final _commentController = TextEditingController();
  List<dynamic> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  String getRelativeTime(dynamic createdAt) {
    DateTime date;
    if (createdAt is String) {
      date = DateTime.parse(createdAt).toLocal();
    } else {
      date = createdAt as DateTime;
    }

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(date);
    }

    return timeago.format(date, locale: 'vi');
  }

  // Tải bình luận từ Supabase
  Future<void> _loadComments() async {
    try {
      final data = await _supabase
          .from('comments')
          .select()
          .eq('article_url', widget.articleUrl)
          .order('created_at', ascending: false);

      setState(() {
        _comments = data.map((comment) {
          comment['created_at'] = DateTime.parse(
            comment['created_at'],
          ).toLocal();
          return comment;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Lỗi tải bình luận: $e');
    }
  }

  // Gửi bình luận mới
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
                        backgroundImage: c['user_avatar'] != ''
                            ? NetworkImage(c['user_avatar'])
                            : null,
                        child: c['user_avatar'] == ''
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        c['user_name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        c['content'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Text(
                        getRelativeTime(c['created_at']),
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

        // Ô nhập bình luận ở dưới đáy
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
