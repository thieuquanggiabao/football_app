import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CommentedNewsScreen extends StatefulWidget {
  const CommentedNewsScreen({super.key});

  @override
  State<CommentedNewsScreen> createState() => _CommentedNewsScreenState();
}

class _CommentedNewsScreenState extends State<CommentedNewsScreen> {
  final _supabase = Supabase.instance.client;

  // MỚI: Dùng Map để nhóm bài báo và danh sách bình luận của bạn
  // Cấu trúc: { "url_bai_bao": { "news": Map, "my_comments": List } }
  Map<String, dynamic> _commentedData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyActivity();
  }

  Future<void> _fetchMyActivity() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Lấy tất cả bình luận của TÔI
      final myComments = await _supabase
          .from('comments')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (myComments.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      // 2. Lấy danh sách URL duy nhất
      final List<String> urls = myComments
          .map((c) => c['article_url'] as String)
          .toSet()
          .toList();

      // 3. Lấy thông tin bài báo tương ứng
      final newsData = await _supabase
          .from('news')
          .select()
          .inFilter('article_url', urls);

      // 4. NHÓM DỮ LIỆU
      Map<String, dynamic> grouped = {};
      for (var url in urls) {
        // Tìm bài báo
        final article = newsData.firstWhere(
          (n) => n['article_url'] == url,
          orElse: () => {},
        );
        // Lọc các bình luận của mình cho bài này
        final commentsForThisArticle = myComments
            .where((c) => c['article_url'] == url)
            .toList();

        if (article.isNotEmpty) {
          grouped[url] = {'news': article, 'comments': commentsForThisArticle};
        }
      }

      setState(() {
        _commentedData = grouped;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Lỗi: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatTime(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp).toLocal();
    final Duration difference = DateTime.now().difference(dateTime);
    if (difference.inHours > 24) return '${dateTime.day}/${dateTime.month}';
    return '${difference.inHours} giờ trước';
  }

  @override
  Widget build(BuildContext context) {
    final urls = _commentedData.keys.toList();

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
                final data = _commentedData[urls[index]];
                final news = data['news'];
                final List myComments = data['comments'];

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
                      // Phần 1: Thông tin bài báo (Thu nhỏ lại)
                      ListTile(
                        onTap: () async {
                          final Uri url = Uri.parse(news['article_url']);
                          if (await canLaunchUrl(url))
                            launchUrl(url, mode: LaunchMode.inAppWebView);
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            news['image_url'] ?? '',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(Icons.image),
                          ),
                        ),
                        title: Text(
                          news['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          _formatTime(news['published_at']),
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

                      // Phần 2: DANH SÁCH BÌNH LUẬN CỦA BẠN
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        color: Colors.white.withOpacity(0.03),
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
                            ...myComments
                                .map(
                                  (comment) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                comment['content'],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                _formatTime(
                                                  comment['created_at'],
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
                                )
                                .toList(),
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
