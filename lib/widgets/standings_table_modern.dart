import 'package:flutter/material.dart';
import '../models/ui_models.dart';

class StandingsTable extends StatelessWidget {
  final List<StandingUI> standings;
  final String? favoriteTeam;
  final VoidCallback? onTeamTap;

  const StandingsTable({
    Key? key,
    required this.standings,
    this.favoriteTeam,
    this.onTeamTap,
  }) : super(key: key);

  Color _getZoneColor(String zone) {
    switch (zone) {
      case 'champions':
        return const Color(0xFF10B981).withOpacity(0.15);
      case 'europa':
        return const Color(0xFF3B82F6).withOpacity(0.15);
      case 'playoff':
        return const Color(0xFFF59E0B).withOpacity(0.15);
      case 'relegation':
        return const Color(0xFFEF4444).withOpacity(0.15);
      default:
        return Colors.transparent;
    }
  }

  Color _getZoneBorderColor(String zone) {
    switch (zone) {
      case 'champions':
        return const Color(0xFF10B981);
      case 'europa':
        return const Color(0xFF3B82F6);
      case 'playoff':
        return const Color(0xFFF59E0B);
      case 'relegation':
        return const Color(0xFFEF4444);
      default:
        return Colors.transparent;
    }
  }

  String _getZoneLabel(String zone) {
    switch (zone) {
      case 'champions':
        return 'CL';
      case 'europa':
        return 'EL';
      case 'playoff':
        return 'PO';
      case 'relegation':
        return 'REL';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sticky Header
        _buildHeader(),

        // Standings List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 0),
            itemCount: standings.length,
            itemBuilder: (context, index) {
              final standing = standings[index];
              final isFavorite = standing.teamName == favoriteTeam;

              return _buildStandingRow(
                context,
                standing,
                isFavorite,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                'Rank',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Team',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                'Played',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                'Pts',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandingRow(
    BuildContext context,
    StandingUI standing,
    bool isFavorite,
  ) {
    final backgroundColor = _getZoneColor(standing.zone);
    final borderColor = _getZoneBorderColor(standing.zone);
    final zoneLabel = _getZoneLabel(standing.zone);

    return GestureDetector(
      onTap: onTeamTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isFavorite
              ? [
                  BoxShadow(
                    color: borderColor.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${standing.rank}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (zoneLabel.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: borderColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: borderColor,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          zoneLabel,
                          style: TextStyle(
                            color: borderColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Team Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      // Team Logo
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade800,
                        ),
                        child: ClipOval(
                          child: Image.network(
                            standing.teamLogo,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.sports_soccer,
                                color: Colors.white.withOpacity(0.5),
                                size: 20,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Team Name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              standing.teamName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isFavorite
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'W${standing.won} D${standing.drawn} L${standing.lost}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Played
              SizedBox(
                width: 50,
                child: Text(
                  '${standing.played}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),

              // Points
              SizedBox(
                width: 50,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                  child: Text(
                    '${standing.points}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
