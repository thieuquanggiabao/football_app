class Player {
  final String name;
  final String position;
  final String dateOfBirth;
  final String nationality;

  Player({
    required this.name,
    required this.position,
    required this.dateOfBirth,
    required this.nationality,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    // Chuyển đổi vị trí tiếng Anh sang tiếng Việt cho thân thiện
    String translatePosition(String? pos) {
      switch (pos) {
        case 'Goalkeeper':
          return 'Thủ môn';
        case 'Defence':
          return 'Hậu vệ';
        case 'Midfield':
          return 'Tiền vệ';
        case 'Offence':
          return 'Tiền đạo';
        default:
          return pos ?? 'Không rõ';
      }
    }

    return Player(
      name: json['name'] ?? 'Đang cập nhật',
      position: translatePosition(json['position']),
      dateOfBirth:
          json['dateOfBirth']?.toString().split('T')[0] ??
          'Đang cập nhật', // Cắt lấy ngày, bỏ giờ
      nationality: json['nationality'] ?? '',
    );
  }
}

class TeamProfileModel {
  // Thông tin cơ bản
  final String name;
  final String shortName;
  final String crest;
  final int founded;
  final String website;
  final String clubColors;

  // Sân vận động
  final String venue;
  final String address;

  // HLV
  final String coachName;

  // Đội hình
  final List<Player> squad;

  TeamProfileModel({
    required this.name,
    required this.shortName,
    required this.crest,
    required this.founded,
    required this.website,
    required this.clubColors,
    required this.venue,
    required this.address,
    required this.coachName,
    required this.squad,
  });

  factory TeamProfileModel.fromJson(Map<String, dynamic> json) {
    var squadList = json['squad'] as List? ?? [];
    List<Player> parsedSquad = squadList
        .map((i) => Player.fromJson(i))
        .toList();

    return TeamProfileModel(
      name: json['name'] ?? '',
      shortName: json['shortName'] ?? '',
      crest: json['crest'] ?? '',
      founded: json['founded'] ?? 0,
      website: json['website'] ?? 'Không có',
      clubColors: json['clubColors'] ?? 'Đang cập nhật',
      venue: json['venue'] ?? 'Đang cập nhật',
      address: json['address'] ?? 'Đang cập nhật',
      coachName: json['coach']?['name'] ?? 'Chưa rõ',
      squad: parsedSquad,
    );
  }
}
