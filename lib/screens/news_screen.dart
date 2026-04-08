import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/news_model.dart';
import '../repositories/news_repository.dart';
import '../widgets/news_card.dart';
import '../widgets/news_shimmer.dart'; // Thêm import shimmer

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final _supabase = Supabase.instance.client;
  final _newsRepo = NewsRepository();
  String _favoriteTeam = '';

  @override
  void initState() {
    super.initState();
    _loadFavoriteTeam();
  }

  void _loadFavoriteTeam() {
    final user = _supabase.auth.currentUser;
    setState(() {
      _favoriteTeam = user?.userMetadata?['favorite_team'] ?? '';
    });
  }

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

  Widget _buildNewsFeed(Future<List<NewsModel>> futureData, String emptyMessage) {
    return FutureBuilder<List<NewsModel>>(
      future: futureData,
      builder: (context, snapshot) {
        // THAY ĐỔI: Sử dụng NewsShimmer thay cho vòng quay tròn nhàm chán
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              '❌ Lỗi tải tin tức!',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              emptyMessage,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }

        final newsList = snapshot.data!;

        return RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: newsList.length,
            itemBuilder: (context, index) => NewsCard(
              news: newsList[index],
              formatTime: _formatTime,
            ),
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
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).textTheme.bodySmall?.color,
            tabs: const [
              Tab(icon: Icon(Icons.article), text: 'Mới nhất'),
              Tab(icon: Icon(Icons.shield), text: 'Đội của bạn'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNewsFeed(
              _newsRepo.getLatestNews(),
              'Chưa có tin tức nào.',
            ),
            _favoriteTeam.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 80,
                          color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bạn chưa chọn đội bóng yêu thích!',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hãy chọn ở mục Tài khoản nhé.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )
                : _buildNewsFeed(
                    _newsRepo.getNewsByTeam(_favoriteTeam),
                    'Hiện chưa có bài báo nào nhắc đến $_favoriteTeam.',
                  ),
          ],
        ),
      ),
    );
  }
}
