import 'package:flutter/material.dart';
import '../models/standing_model.dart';
import '../repositories/standing_repository.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  final StandingRepository _repository = StandingRepository();

  final List<Map<String, String>> leagues = [
    {'name': 'Ngoại Hạng Anh', 'code': 'PL'},
    {'name': 'La Liga', 'code': 'PD'},
    {'name': 'Bundesliga', 'code': 'BL1'},
    {'name': 'Serie A', 'code': 'SA'},
    {'name': 'Ligue 1', 'code': 'FL1'},
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: leagues.length,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text(
            'BẢNG XẾP HẠNG',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.greenAccent,
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.greenAccent,
            labelColor: Colors.greenAccent,
            unselectedLabelColor: Colors.white54,
            tabs: leagues.map((league) => Tab(text: league['name'])).toList(),
          ),
        ),
        body: TabBarView(
          children: leagues.map((league) {
            return FutureBuilder<List<StandingModel>>(
              // Gọi repository để lấy dữ liệu theo mã giải (PL, PD...)
              future: _repository.getStandingsByLeague(league['code']!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.greenAccent),
                  );
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Chưa có dữ liệu cho giải đấu này',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                final standings = snapshot.data!;

                return Column(
                  children: [
                    // Thanh tiêu đề các cột (Hạng, Đội, Trận, HS, Điểm)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      color: Colors.grey[900],
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 30,
                            child: Text(
                              '#',
                              style: TextStyle(
                                color: Colors.white54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'CÂU LẠC BỘ',
                              style: TextStyle(
                                color: Colors.white54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 30,
                            child: Text(
                              'Tr',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Text(
                              'HS',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                          SizedBox(
                            width: 35,
                            child: Text(
                              'Pts',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Danh sách 20 đội bóng
                    Expanded(
                      child: ListView.builder(
                        itemCount: standings.length,
                        itemBuilder: (context, index) {
                          final team = standings[index];
                          // Nổi bật top 4 (vùng dự Cúp C1)
                          final isTop4 = team.position <= 4;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[850]!,
                                  width: 1,
                                ),
                              ),
                              color: isTop4
                                  ? Colors.greenAccent.withOpacity(0.05)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                // Thứ hạng
                                SizedBox(
                                  width: 30,
                                  child: Text(
                                    '${team.position}',
                                    style: TextStyle(
                                      color: isTop4
                                          ? Colors.greenAccent
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                // Logo và Tên đội
                                Expanded(
                                  child: Row(
                                    children: [
                                      Image.network(
                                        team.teamLogo,
                                        width: 24,
                                        height: 24,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.shield,
                                                  color: Colors.white54,
                                                  size: 24,
                                                ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          team.teamName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow
                                              .ellipsis, // Cắt chữ nếu tên quá dài
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Số trận
                                SizedBox(
                                  width: 30,
                                  child: Text(
                                    '${team.played}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                // Hiệu số bàn thắng
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    '${team.goalDifference > 0 ? '+' : ''}${team.goalDifference}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                // Điểm số
                                SizedBox(
                                  width: 35,
                                  child: Text(
                                    '${team.points}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.greenAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
