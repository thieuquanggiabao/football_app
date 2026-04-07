import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/standing_model.dart';
import '../repositories/standing_repository.dart';
import '../widgets/standings_row.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  final StandingRepository _repository = StandingRepository();

  @override
  Widget build(BuildContext context) {
    final leagues = AppConstants.standingsLeagues;

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
            tabs: leagues.map((l) => Tab(text: l['name'])).toList(),
          ),
        ),
        body: TabBarView(
          children: leagues.map((league) {
            return FutureBuilder<List<StandingModel>>(
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
                    // Thanh tiêu đề cột
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

                    // Danh sách đội bóng
                    Expanded(
                      child: ListView.builder(
                        itemCount: standings.length,
                        itemBuilder: (context, index) =>
                            StandingsRow(team: standings[index]),
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
