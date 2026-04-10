import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/news_model.dart';
import '../repositories/news_repository.dart';
import '../widgets/news_card.dart';
import '../widgets/news_shimmer.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  // --- Các thành phần xử lý dữ liệu ---
  final _client = Supabase.instance.client; // Kết nối tới hệ thống Supabase
  final _repository = NewsRepository(); // Lớp truy vấn dữ liệu tin tức
  
  // Trạng thái người dùng
  String _preferredClub = ''; 

  @override
  void initState() {
    super.initState();
    _fetchUserPreferences(); // Lấy thông tin cá nhân hóa khi khởi tạo
  }

  /// Truy xuất tên đội bóng yêu thích từ metadata của User
  void _fetchUserPreferences() {
    final user = _client.auth.currentUser;
    if (mounted) {
      setState(() {
        _preferredClub = user?.userMetadata?['favorite_team'] ?? '';
      });
    }
  }

  /// Logic xử lý hiển thị thời gian (Helper)
  String _getRelativeTimeString(String isoTimestamp) {
    final DateTime publishedDate = DateTime.parse(isoTimestamp).toLocal();
    final Duration diff = DateTime.now().difference(publishedDate);

    if (diff.inHours > 24) {
      return '${publishedDate.day}/${publishedDate.month}/${publishedDate.year}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} phút trước';
    }
    return 'Vừa đăng';
  }

  /// Widget hiển thị khi tab "Đội của bạn" chưa có dữ liệu cấu hình
  Widget _buildEmptyStateInfo() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 70, color: Colors.grey[850]),
            const SizedBox(height: 24),
            const Text(
              'Chưa chọn đội bóng yêu thích',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Vui lòng cập nhật trong phần Tài khoản để theo dõi tin tức riêng biệt.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  /// Hàm xây dựng danh sách bài viết (Sử dụng cho cả 2 Tab)
  Widget _renderNewsList(Future<List<NewsModel>> dataFuture, String fallbackMsg) {
    return FutureBuilder<List<NewsModel>>(
      future: dataFuture,
      builder: (context, snapshot) {
        // Trạng thái: Đang tải
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const NewsShimmer();
        }
        
        // Trạng thái: Lỗi mạng/Hệ thống
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              '⚠️ Không thể kết nối dữ liệu',
              style: TextStyle(color: Colors.redAccent),
            ),
          );
        }

        // Trạng thái: Không có dữ liệu trả về
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              fallbackMsg,
              style: const TextStyle(color: Colors.white30),
            ),
          );
        }

        final newsItems = snapshot.data!;

        return RefreshIndicator(
          color: Colors.greenAccent,
          onRefresh: () async => setState(() {}),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
            itemCount: newsItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemBuilder: (context, index) => NewsCard(
              news: newsItems[index],
              formatTime: _getRelativeTimeString,
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
          backgroundColor: Colors.black,
          foregroundColor: Colors.greenAccent,
          centerTitle: true,
          elevation: 0,
          title: const Text(
            'TIN TỨC BÓNG ĐÁ',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.greenAccent,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Colors.greenAccent,
            unselectedLabelColor: Colors.white30,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Mới nhất'),
              Tab(text: 'CLB của tôi'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Toàn bộ tin tức
            _renderNewsList(
              _repository.getLatestNews(),
              'Không có tin tức nào được tìm thấy.',
            ),
            
            // Tab 2: Tin tức cá nhân hóa
            _preferredClub.isEmpty
                ? _buildEmptyStateInfo()
                : _renderNewsList(
                    _repository.getNewsByTeam(_preferredClub),
                    'Chưa có bài báo nào về $_preferredClub.',
                  ),
          ],
        ),
      ),
    );
  }
}
