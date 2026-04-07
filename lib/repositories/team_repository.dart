import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/team_profile_model.dart';
// Đảm bảo bạn đã import supabase_client nếu cần

class TeamRepository {
  // Thay bằng link Render thật của bạn
  final String baseUrl = 'https://football-backend-7cqp.onrender.com/api';

  Future<TeamProfileModel> getTeamDetail(int teamId) async {
    final response = await http.get(Uri.parse('$baseUrl/teams/$teamId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return TeamProfileModel.fromJson(data);
    } else {
      throw Exception('Lỗi kết nối đến máy chủ');
    }
  }
}
