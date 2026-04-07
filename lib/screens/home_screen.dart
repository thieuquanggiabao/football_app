import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../repositories/match_repository.dart';
import '../widgets/match_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo repository để lấy đường ống dữ liệu
    final matchRepository = MatchRepository();

    return Scaffold(
      backgroundColor: Colors.black, // Nền đen sâu
      appBar: AppBar(
        title: const Text(
          'LIVE FOOTBALL',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.greenAccent, // Chữ xanh dạ quang
        elevation: 0,
      ),
      body: Container(
        // Hiệu ứng ánh sáng xanh hắt từ trên xuống
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.greenAccent.withValues(alpha: 0.1), Colors.black],
            stops: const [0.0, 0.3],
          ),
        ),
        child: StreamBuilder<List<MatchModel>>(
          stream: matchRepository.getLiveMatchesStream(),
          builder: (context, snapshot) {
            // Trạng thái 1: Đang tải dữ liệu ban đầu
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.greenAccent),
              );
            }

            // Trạng thái 2: Lỗi đường truyền hoặc Database
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Lỗi kết nối: ${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            }

            // Trạng thái 3: Không có trận đấu nào
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'Hôm nay không có trận đấu nào diễn ra ⚽',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              );
            }

            // Trạng thái 4: Có dữ liệu! Hiển thị danh sách
            final matches = snapshot.data!;

            return ListView.builder(
              physics: const BouncingScrollPhysics(), // Hiệu ứng cuộn mượt mà
              padding: const EdgeInsets.only(top: 10, bottom: 30),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                return MatchCard(match: matches[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
