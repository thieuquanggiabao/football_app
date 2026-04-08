import 'package:flutter/material.dart';
import '../models/standing_model.dart';

/// Widget hiển thị một hàng đội bóng trong bảng xếp hạng
class StandingsRow extends StatelessWidget {
  final StandingModel team;

  const StandingsRow({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    final isTop4 = team.position <= 4;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        color: isTop4
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
            : Colors.transparent,
      ),
      child: Row(
        children: [
          // Thứ hạng
          SizedBox(
            width: 25,
            child: Text(
              '${team.position}',
              style: TextStyle(
                color: isTop4
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          // Logo + Tên đội
          Expanded(
            child: Row(
              children: [
                Image.network(
                  team.teamLogo,
                  width: 24,
                  height: 24,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.shield,
                    color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    team.teamName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ) ?? const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Số trận
          SizedBox(
            width: 25,
            child: Text(
              '${team.played}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          // Thắng
          SizedBox(
            width: 25,
            child: Text(
              '${team.won}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ),

          // Hòa
          SizedBox(
            width: 25,
            child: Text(
              '${team.drawn}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ),

          // Thua
          SizedBox(
            width: 25,
            child: Text(
              '${team.lost}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ),

          // Hiệu số
          SizedBox(
            width: 30,
            child: Text(
              '${team.goalDifference > 0 ? '+' : ''}${team.goalDifference}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          // Điểm
          SizedBox(
            width: 30,
            child: Text(
              '${team.points}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ) ?? const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
