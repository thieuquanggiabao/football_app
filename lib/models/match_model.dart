class MatchModel {
  final int apiMatchId;
  final String homeTeam;
  final String awayTeam;
  final int homeScore;
  final int awayScore;
  final String status;
  final DateTime startedAt;
  final String homeLogo;
  final String awayLogo;
  final String leagueCode;
  // Constructor (Hàm khởi tạo)
  MatchModel({
    required this.apiMatchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.status,
    required this.startedAt,
    required this.homeLogo,
    required this.awayLogo,
    required this.leagueCode,
  });

  // Hàm "ma thuật" để biến cục JSON từ Supabase thành đối tượng MatchModel trong Dart
  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      // Các chữ màu xanh lá cây bên trong ngoặc vuông [] phải gõ CHÍNH XÁC
      // y hệt như tên cột bạn đã tạo trong bảng live_matches trên Supabase
      apiMatchId: json['api_match_id'] ?? 0,
      homeTeam: json['home_team'] ?? 'Đang cập nhật',
      awayTeam: json['away_team'] ?? 'Đang cập nhật',
      homeScore: json['home_score'] ?? 0,
      awayScore: json['away_score'] ?? 0,
      status: json['status'] ?? '',
      // Chuyển đổi chuỗi thời gian thành kiểu DateTime của Dart
      startedAt: DateTime.parse(json['started_at']),
      homeLogo: json['home_logo'] ?? '',
      awayLogo: json['away_logo'] ?? '',
      leagueCode: json['league_code'] ?? '',
    );
  }
}
