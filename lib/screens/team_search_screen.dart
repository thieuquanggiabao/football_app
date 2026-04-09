import 'package:flutter/material.dart';
import '../models/team_model.dart';
import '../repositories/team_repository.dart';
import 'team_detail_screen.dart';

class TeamSearchScreen extends StatefulWidget {
  const TeamSearchScreen({super.key});

  @override
  State<TeamSearchScreen> createState() => _TeamSearchScreenState();
}

class _TeamSearchScreenState extends State<TeamSearchScreen> {
  final _teamRepo = TeamRepository();

  List<TeamModel> _allTeams = [];
  List<TeamModel> _filteredTeams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    try {
      final teams = await _teamRepo.getUniqueTeams();
      setState(() {
        _allTeams = teams;
        _filteredTeams = teams;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Lỗi tải đội bóng: $e');
      setState(() => _isLoading = false);
    }
  }

  void _runFilter(String keyword) {
    setState(() {
      _filteredTeams = keyword.isEmpty
          ? _allTeams
          : _allTeams
              .where((team) =>
                  team.teamName.toLowerCase().contains(keyword.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextField(
          onChanged: _runFilter,
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            )
          : ListView.builder(
              itemCount: _filteredTeams.length,
              itemBuilder: (context, index) {
                final team = _filteredTeams[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: Hero(
                    tag: 'team_logo_${team.teamId}',
                    child: Image.network(
                      team.teamLogo,
                      width: 50,
                      height: 50,
                      errorBuilder: (ctx, err, stack) => const Icon(
                        Icons.shield,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                  title: Text(
                    team.teamName,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamDetailScreen(
                          teamId: team.teamId,
                          teamName: team.teamName,
                          teamLogo: team.teamLogo,
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
