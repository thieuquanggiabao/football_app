class AppConstants {
  // Supabase credentials
  static const String supabaseUrl = 'https://azkdjgapwcpneciblelr.supabase.co';

  // Google OAuth Server Client ID
  static const String googleServerClientId =
      '485933277797-j5bgvt32ia25gt8d9ucv6f173b8tc3lb.apps.googleusercontent.com';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF6a2RqZ2Fwd2NwbmVjaWJsZWxyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM2OTY4MDQsImV4cCI6MjA4OTI3MjgwNH0.QBbfsqaWoYQuKOM4QypI-qt_CeC148qQe3tFBZuPBb4';

  // Bản đồ mã giải đấu → tên tiếng Việt (dùng chung toàn app)
  static const Map<String, String> leagueNames = {
    'PL': 'Ngoại hạng Anh',
    'PD': 'La Liga',
    'BL1': 'Bundesliga',
    'SA': 'Serie A',
    'FL1': 'Ligue 1',
    'BSA': 'VĐQG Brazil',
    'CL': 'Champions League',
    'EL': 'Europa League',
    'WC': 'FIFA World Cup',
  };

  /// Trả về tên giải đấu từ mã code. Nếu không tìm thấy, trả về code gốc.
  static String getLeagueName(String code) {
    return leagueNames[code] ?? (code.isNotEmpty ? code : 'Giao hữu');
  }

  // Tên các giải hiển thị trong BXH (theo thứ tự)
  static const List<Map<String, String>> standingsLeagues = [
    {'name': 'Ngoại Hạng Anh', 'code': 'PL'},
    {'name': 'La Liga', 'code': 'PD'},
    {'name': 'Bundesliga', 'code': 'BL1'},
    {'name': 'Serie A', 'code': 'SA'},
    {'name': 'Ligue 1', 'code': 'FL1'},
  ];
}
