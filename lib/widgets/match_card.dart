import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../models/match_model.dart';
import '../screens/live_player_screen.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final localTime = match.startedAt.toLocal();
    final timeString = DateFormat('HH:mm - dd/MM').format(localTime);

    final isLive = match.status == 'IN_PLAY' || match.status == 'PAUSED';
    final statusColor = isLive ? Theme.of(context).colorScheme.primary : Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : Colors.grey.shade100,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LivePlayerScreen(match: match),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Dòng trên: Trạng thái và Thời gian + Tên giải
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      isLive ? 'LIVE' : match.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  // Dùng AppConstants thay vì hàm nội bộ
                  Text(
                    '${AppConstants.getLeagueName(match.leagueCode)} • $timeString',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dòng giữa: Đội nhà — Tỉ số — Đội khách
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Đội nhà
                  Expanded(
                    child: Column(
                      children: [
                        Image.network(
                          match.homeLogo,
                          height: 50,
                          width: 50,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.shield,
                            color: Colors.white54,
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          match.homeTeam,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ) ?? const TextStyle(
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tỉ số
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      '${match.homeScore} - ${match.awayScore}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isLive
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),

                  // Đội khách
                  Expanded(
                    child: Column(
                      children: [
                        Image.network(
                          match.awayLogo,
                          height: 50,
                          width: 50,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.shield,
                            color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          match.awayTeam,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ) ?? const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
