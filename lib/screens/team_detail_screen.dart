import 'package:flutter/material.dart';
import '../models/team_profile_model.dart';
import '../repositories/team_repository.dart';

class TeamDetailScreen extends StatefulWidget {
  final int teamId;
  final String teamName;
  final String teamLogo;

  const TeamDetailScreen({
    super.key,
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
  });

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  final TeamRepository _repository = TeamRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<TeamProfileModel>(
        future: _repository.getTeamDetail(widget.teamId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Lỗi: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final team = snapshot.data!;

          return CustomScrollView(
            slivers: [
              // SLIVER APP BAR: Tạo hiệu ứng cuộn mượt mà cho Header
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                backgroundColor: Colors.grey[900],
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    widget.teamName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Nơi đáp cánh của Hero Animation từ màn hình tìm kiếm
                        Hero(
                          tag: 'team_logo_${widget.teamId}',
                          child: Image.network(widget.teamLogo, height: 100),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Thành lập: ${team.founded}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // PHẦN THÔNG TIN CHI TIẾT
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Thông tin chung
                      _buildInfoCard(
                        icon: Icons.stadium,
                        title: 'Sân vận động',
                        content: '${team.venue}\n${team.address}',
                      ),
                      const SizedBox(height: 10),
                      _buildInfoCard(
                        icon: Icons.person,
                        title: 'Huấn luyện viên',
                        content: team.coachName,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'ĐỘI HÌNH THI ĐẤU',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              // DANH SÁCH CẦU THỦ
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final player = team.squad[index];
                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Text(
                          player.position[0],
                          style: const TextStyle(color: Colors.greenAccent),
                        ), // Chữ cái đầu của Vị trí
                      ),
                      title: Text(
                        player.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${player.position} • ${player.nationality}',
                        style: const TextStyle(color: Colors.white54),
                      ),
                      trailing: Text(
                        player.dateOfBirth.split('-').reversed.join('/'),
                        style: const TextStyle(color: Colors.white30),
                      ),
                    ),
                  );
                }, childCount: team.squad.length),
              ),

              // Khoảng trống dưới cùng
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }

  // Hàm phụ trợ vẽ các hộp thông tin cho đẹp
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[850]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.greenAccent, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
