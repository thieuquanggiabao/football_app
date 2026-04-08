class StandingModel {
  final int position;
  final String teamName;
  final String teamLogo;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalDifference;
  final int points;

  StandingModel({
    required this.position,
    required this.teamName,
    required this.teamLogo,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalDifference,
    required this.points,
  });

  factory StandingModel.fromJson(Map<String, dynamic> json) {
    return StandingModel(
      position: json['position'] ?? 0,
      teamName: json['team_name'] ?? 'Đang cập nhật',
      teamLogo: json['team_logo'] ?? '',
      played: json['played'] ?? 0,
      won: json['won'] ?? 0,
      drawn: json['drawn'] ?? 0,
      lost: json['lost'] ?? 0,
      goalDifference: json['goal_difference'] ?? 0,
      points: json['points'] ?? 0,
    );
  }
}
