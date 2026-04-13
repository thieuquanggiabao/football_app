import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final _supabase = Supabase.instance.client;

  /// Lấy thông tin user hiện tại từ bảng profiles
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      return response;
    } catch (e) {
      // Bỏ qua lỗi và trả về null nếu có lỗi truy vấn
      print('Lỗi khi lấy thông tin profile: $e');
      return null;
    }
  }

  /// Kiểm tra xem user có quyền xem trận đấu không
  bool canWatchMatch(String matchLeagueCode, Map<String, dynamic>? profile) {
    if (profile == null) return false;

    // Kiểm tra trạng thái premium
    final isPremium = profile['is_premium'] == true;
    if (!isPremium) return false;

    // Nếu là gói SUPER_PRO thì xem được tất cả
    final planCode = profile['plan_code'] as String?;
    if (planCode == 'SUPER_PRO') return true;

    // Kiểm tra xem giải đấu có nằm trong danh sách được mở khóa không
    final unlockedLeagues = List<dynamic>.from(profile['unlocked_leagues'] ?? []);
    return unlockedLeagues.contains(matchLeagueCode);
  }

}
