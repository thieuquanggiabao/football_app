import 'package:flutter/material.dart';
import '../core/supabase_client.dart'; // File chứa biến supabase của bạn
import 'team_detail_screen.dart';

class TeamSearchScreen extends StatefulWidget {
  const TeamSearchScreen({super.key});

  @override
  State<TeamSearchScreen> createState() => _TeamSearchScreenState();
}

class _TeamSearchScreenState extends State<TeamSearchScreen> {
  List<Map<String, dynamic>> allTeams = [];
  List<Map<String, dynamic>> filteredTeams = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeamsFromSupabase();
  }

  // Lấy danh sách đội bóng có sẵn trong bảng standings
  Future<void> _fetchTeamsFromSupabase() async {
    final response = await supabase
        .from('standings')
        .select('team_id, team_name, team_logo')
        .order('team_name'); // Sắp xếp theo tên A-Z

    // Lọc bỏ các đội bị trùng lặp (vì 1 đội có thể nằm ở nhiều dòng nếu lưu lịch sử)
    final uniqueTeams = <int, Map<String, dynamic>>{};
    for (var row in response) {
      uniqueTeams[row['team_id']] = row;
    }

    setState(() {
      allTeams = uniqueTeams.values.toList();
      filteredTeams = allTeams;
      isLoading = false;
    });
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = allTeams;
    } else {
      results = allTeams
          .where(
            (team) => team['team_name'].toLowerCase().contains(
              enteredKeyword.toLowerCase(),
            ),
          )
          .toList();
    }
    setState(() {
      filteredTeams = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextField(
          onChanged: (value) => _runFilter(value),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Nhập tên Câu lạc bộ...',
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: const Icon(Icons.search, color: Colors.greenAccent),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            )
          : ListView.builder(
              itemCount: filteredTeams.length,
              itemBuilder: (context, index) {
                final team = filteredTeams[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  // KỸ THUẬT HERO ANIMATION: Bọc Logo trong Hero widget với tag là ID đội bóng
                  leading: Hero(
                    tag: 'team_logo_${team['team_id']}',
                    child: Image.network(
                      team['team_logo'],
                      width: 50,
                      height: 50,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.shield,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                  title: Text(
                    team['team_name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                    size: 16,
                  ),
                  onTap: () {
                    // Chuyển sang màn hình chi tiết, mang theo ID, Tên và Logo
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamDetailScreen(
                          teamId: team['team_id'],
                          teamName: team['team_name'],
                          teamLogo: team['team_logo'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
