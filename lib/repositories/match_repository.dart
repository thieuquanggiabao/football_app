import '../core/supabase_client.dart';
import '../models/match_model.dart';

class MatchRepository {
  /// Hàm này mở một "đường ống" (Stream) lắng nghe bảng live_matches 24/7
  Stream<List<MatchModel>> getLiveMatchesStream() {
    return supabase
        .from('live_matches') // 1. Chỉ định bảng cần lấy dữ liệu
        .stream(
          primaryKey: ['api_match_id'],
        ) // 2. Bật chế độ Realtime dựa trên khóa chính
        .order(
          'started_at',
          ascending: false,
        ) // 3. Sắp xếp: Trận nào mới đá lên đầu
        .map((List<Map<String, dynamic>> rawData) {
          // 4. Biến đổi dữ liệu thô (JSON) thành danh sách các khuôn đúc MatchModel
          return rawData.map((json) => MatchModel.fromJson(json)).toList();
        });
  }
}
