// Data models for UI components

class MatchUI {
  final String homeTeam;
  final String awayTeam;
  final String homeTeamLogo;
  final String awayTeamLogo;
  final int homeScore;
  final int awayScore;
  final String status; // LIVE, SCHEDULED, FINISHED
  final String? matchTime; // e.g., "45+2", "90", "20:00"

  MatchUI({
    required this.homeTeam,
    required this.awayTeam,
    required this.homeTeamLogo,
    required this.awayTeamLogo,
    required this.homeScore,
    required this.awayScore,
    required this.status,
    this.matchTime,
  });
}

class StandingUI {
  final int rank;
  final String teamName;
  final String teamLogo;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goals;
  final int goalsAgainst;
  final int points;
  final bool isFavorite;
  final String zone; // 'champions', 'europa', 'playoff', 'relegation'

  StandingUI({
    required this.rank,
    required this.teamName,
    required this.teamLogo,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goals,
    required this.goalsAgainst,
    required this.points,
    required this.isFavorite,
    required this.zone,
  });
}
