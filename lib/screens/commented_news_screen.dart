import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/comment_model.dart';
import '../models/news_model.dart';

class CommentedNewsScreen extends StatefulWidget {
  const CommentedNewsScreen({super.key});

  @override
  State<CommentedNewsScreen> createState() => _CommentedNewsScreenState();
}

class _CommentedNewsScreenState extends State<CommentedNewsScreen> {
  final _supabase = Supabase.instance.client;

  // Cấu trúc: { "article_url": { "news": NewsModel, "comments": List<CommentModel> } }
  Map<String, Map<String, dynamic>> _groupedData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyActivity();
  }

  Future<void> _fetchMyActivity() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 1. Lấy tất cả bình luận của user hiện tại
      final rawComments = await _supabase
          .from('comments')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (rawComments.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final myComments =
          rawComments.map((json) => CommentModel.fromJson(json)).toList();

      // 2. Lấy danh sách URL duy nhất
      final urls =
          myComments.map((c) => c.articleUrl).toSet().toList();

      // 3. Lấy thông tin bài báo tương ứng
      final rawNews =
          await _supabase.from('news').select().inFilter('article_url', urls);

      final newsList =
          rawNews.map((json) => NewsModel.fromJson(json)).toList();

      // 4. Nhóm dữ liệu theo articleUrl
      final Map<String, Map<String, dynamic>> grouped = {};
      for (final url in urls) {
        final article = newsList.where((n) => n.articleUrl == url).firstOrNull;
        final commentsForArticle =
            myComments.where((c) => c.articleUrl == url).toList();

        if (article != null) {
          grouped[url] = {'news': article, 'comments': commentsForArticle};
        }
      }

      if (mounted) {
        setState(() {
          _groupedData = grouped;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải nhật ký bình luận: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatTime(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp).toLocal();
    final Duration difference = DateTime.now().difference(dateTime);
    if (difference.inHours > 24) {
      return '${dateTime.day}/${dateTime.month}';
    }
    return '${difference.inHours} giờ trước';
  }

  @override
  Widget build(BuildContext context) {
    final urls = _groupedData.keys.toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Nhật ký bình luận',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.greenAccent,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            )
          : urls.isEmpty
          ? const Center(
              child: Text(
                'Bạn chưa có bình luận nào.',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: urls.length,
              itemBuilder: (context, index) {
                final data = _groupedData[urls[index]]!;
                final NewsModel news = data['news'];
                final List<CommentModel> comments = data['comments'];

                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thông tin bài báo
                      ListTile(
                        onTap: () async {
                          final uri = Uri.parse(news.articleUrl);
                          if (await canLaunchUrl(uri)) {
                            launchUrl(uri, mode: LaunchMode.inAppWebView);
                          }
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            news.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) =>
                                const Icon(Icons.image),
                          ),
                        ),
                        title: Text(
                          news.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          _formatTime(news.publishedAt),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.open_in_new,
                          color: Colors.white24,
                          size: 18,
                        ),
                      ),

                      const Divider(color: Colors.white10, height: 1),

                      // Danh sách bình luận của user
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        color: Colors.white.withValues(alpha: 0.03),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bình luận của bạn:',
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...comments.map(
                              (comment) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.subdirectory_arrow_right,
                                      color: Colors.greenAccent,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            comment.content,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            _formatTime(
                                              comment.createdAt.toIso8601String(),
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white38,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
