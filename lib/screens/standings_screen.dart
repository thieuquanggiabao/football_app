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

class _StandingsScreenState extends State<StandingsScreen>
    with SingleTickerProviderStateMixin {
  final StandingRepository _repository = StandingRepository();

  // Màu Champions League
  static const Color _clNavy = Color(0xFF0D0D2B);
  static const Color _clBlue = Color(0xFF1A2A6E);
  static const Color _clGold = Color(0xFFFAC917);
  static const Color _clSilver = Color(0xFFB8C6DB);

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
          children: leagues.asMap().entries.map((entry) {
            final league = entry.value;
            final isCL = league['code'] == 'CL';

            return FutureBuilder<List<StandingModel>>(
              future: _repository.getStandingsByLeague(league['code']!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: isCL
                              ? _clGold
                              : Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Đang tải dữ liệu...',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCL
                              ? Icons.emoji_events_outlined
                              : Icons.format_list_numbered,
                          size: 48,
                          color: isCL
                              ? _clGold.withValues(alpha: 0.5)
                              : Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Chưa có dữ liệu cho giải đấu này',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }

                final standings = snapshot.data!;

                return Column(
                  children: [
                    // Header đặc biệt cho Champions League
                    if (isCL) _buildCLHeader(context),

                    // Thanh tiêu đề cột
                    _buildColumnHeader(context, isCL),

                    // Ghi chú cho Champions League
                    if (isCL) _buildCLLegend(context),

                    // Danh sách đội bóng
                    Expanded(
                      child: ListView.builder(
                        itemCount: standings.length,
                        itemBuilder: (context, index) => StandingsRow(
                          team: standings[index],
                          isChampionsLeague: isCL,
                        ),
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

  /// Header banner đặc trưng Champions League
  Widget _buildCLHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_clNavy, _clBlue, Color(0xFF1E3A8A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          // Biểu tượng cúp C1
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _clGold.withValues(alpha: 0.15),
              border: Border.all(
                color: _clGold.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: const Icon(Icons.emoji_events, color: _clGold, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'UEFA Champions League',
                style: TextStyle(
                  color: _clGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Mùa giải 2024/25',
                style: TextStyle(
                  color: _clSilver.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Ngôi sao trang trí
          Row(
            children: List.generate(
              5,
              (i) => Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Icon(
                  Icons.star,
                  size: 8,
                  color: _clGold.withValues(alpha: 0.5 + i * 0.1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Thanh tiêu đề cột
  Widget _buildColumnHeader(BuildContext context, bool isCL) {
    final borderColor = isCL
        ? _clGold.withValues(alpha: 0.2)
        : Colors.transparent;
    final bgColor = isCL
        ? _clNavy.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark ? 0.6 : 0.08,
          )
        : Theme.of(context).appBarTheme.backgroundColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 25,
            child: Text(
              '#',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isCL ? _clGold : null,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'CÂU LẠC BỘ',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isCL ? _clGold : null,
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
                color: isCL ? _clGold : Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Chú thích màu sắc Champions League
  Widget _buildCLLegend(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _clNavy.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.4 : 0.05,
      ),
      child: Row(
        children: [
          _legendDot(_clGold),
          const SizedBox(width: 6),
          Text(
            'Top 8: Vào vòng loại trực tiếp',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
          const SizedBox(width: 16),
          _legendDot(Colors.grey),
          const SizedBox(width: 6),
          Text(
            'Dưới 8: Bị loại',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
