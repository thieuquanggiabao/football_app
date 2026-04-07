import '../core/supabase_client.dart';
import '../models/news_model.dart';

class NewsRepository {
  /// Lấy danh sách tin tức mới nhất (tất cả giải đấu)
  Future<List<NewsModel>> getLatestNews({int limit = 20}) async {
    final response = await supabase
        .from('news')
        .select()
        .order('published_at', ascending: false)
        .limit(limit);

    return response.map((json) => NewsModel.fromJson(json)).toList();
  }

  /// Lấy tin tức theo từ khóa tên đội bóng yêu thích
  Future<List<NewsModel>> getNewsByTeam(
    String teamName, {
    int limit = 20,
  }) async {
    final response = await supabase
        .from('news')
        .select()
        .or('title.ilike.%$teamName%,description.ilike.%$teamName%')
        .order('published_at', ascending: false)
        .limit(limit);

    return response.map((json) => NewsModel.fromJson(json)).toList();
  }
}
