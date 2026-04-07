class TeamModel {
  final int teamId;
  final String teamName;
  final String teamLogo;

  const TeamModel({
    required this.teamId,
    required this.teamName,
    required this.teamLogo,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      teamId: json['team_id'] as int,
      teamName: json['team_name'] ?? '',
      teamLogo: json['team_logo'] ?? '',
    );
  }
}
