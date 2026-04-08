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
        appBar: AppBar(
          title: const Text(
            'BẢNG XẾP HẠNG',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).textTheme.bodySmall?.color,
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
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Chưa có dữ liệu cho giải đấu này',
                      style: Theme.of(context).textTheme.bodySmall,
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
                      color: Theme.of(context).appBarTheme.backgroundColor,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 25,
                            child: Text(
                              '#',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'CÂU LẠC BỘ',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 25,
                            child: Text(
                              'Tr',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          SizedBox(
                            width: 25,
                            child: Text(
                              'T',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                          SizedBox(
                            width: 25,
                            child: Text(
                              'H',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                          SizedBox(
                            width: 25,
                            child: Text(
                              'B',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                          SizedBox(
                            width: 30,
                            child: Text(
                              'HS',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          SizedBox(
                            width: 30,
                            child: Text(
                              'Pts',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
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
