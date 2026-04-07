import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/supabase_client.dart';
import '../models/team_model.dart';
import '../models/team_profile_model.dart';

class TeamRepository {
  final String _baseUrl = 'https://football-backend-7cqp.onrender.com/api';

  /// Lấy danh sách đội bóng duy nhất từ bảng standings (dùng cho Search & Profile)
  Future<List<TeamModel>> getUniqueTeams() async {
    final response = await supabase
        .from('standings')
        .select('team_id, team_name, team_logo')
        .order('team_name');

    // Lọc bỏ trùng lặp theo team_id
    final Map<int, TeamModel> uniqueMap = {};
    for (final row in response) {
      final id = row['team_id'] as int?;
      if (id != null) {
        uniqueMap[id] = TeamModel.fromJson(row);
      }
    }

    return uniqueMap.values.toList();
  }

  /// Lấy thông tin chi tiết một đội bóng từ backend API
  Future<TeamProfileModel> getTeamDetail(int teamId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/teams/$teamId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return TeamProfileModel.fromJson(data);
    } else {
      throw Exception('Lỗi kết nối đến máy chủ');
    }
  }
}
