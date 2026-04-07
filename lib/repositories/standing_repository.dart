import '../core/supabase_client.dart';
import '../models/standing_model.dart';

class StandingRepository {
  // Dùng Future để lấy dữ liệu 1 lần thay vì Stream
  Future<List<StandingModel>> getStandingsByLeague(String leagueCode) async {
    final response = await supabase
        .from('standings')
        .select()
        .eq('league_code', leagueCode) // Lọc đúng giải đấu cần lấy
        .order('position', ascending: true); // Sắp xếp từ Hạng 1 đến Hạng 20
    return response.map((json) => StandingModel.fromJson(json)).toList();
  }
}
