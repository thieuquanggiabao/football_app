import 'package:flutter/material.dart';
import '../models/ui_models.dart';
import 'match_card_modern.dart';
import 'standings_table_modern.dart';

class FootballUIDemo extends StatelessWidget {
  const FootballUIDemo({Key? key}) : super(key: key);

  // Sample match data
  List<MatchUI> get _sampleMatches => [
    MatchUI(
      homeTeam: 'Manchester United',
      awayTeam: 'Liverpool',
      homeTeamLogo: 'https://upload.wikimedia.org/wikipedia/en/7/7a/Manchester_United_FC_badge.png',
      awayTeamLogo: 'https://upload.wikimedia.org/wikipedia/en/0/0c/Liverpool_FC.svg',
      homeScore: 2,
      awayScore: 1,
      status: 'LIVE',
      matchTime: '67\'',
    ),
    MatchUI(
      homeTeam: 'Arsenal',
      awayTeam: 'Chelsea',
      homeTeamLogo: 'https://upload.wikimedia.org/wikipedia/en/5/53/Arsenal_FC.svg',
      awayTeamLogo: 'https://upload.wikimedia.org/wikipedia/en/0/0c/Chelsea_FC.svg',
      homeScore: 1,
      awayScore: 1,
      status: 'FINISHED',
      matchTime: '90+3\'',
    ),
    MatchUI(
      homeTeam: 'Manchester City',
      awayTeam: 'Tottenham',
      homeTeamLogo: 'https://upload.wikimedia.org/wikipedia/en/e/eb/Manchester_City_FC_badge.svg',
      awayTeamLogo: 'https://upload.wikimedia.org/wikipedia/en/e/e8/Tottenham_Hotspur.svg',
      homeScore: 0,
      awayScore: 0,
      status: 'SCHEDULED',
      matchTime: '20:00',
    ),
  ];

  // Sample standings data
  List<StandingUI> get _sampleStandings => [
    StandingUI(
      rank: 1,
      teamName: 'Manchester City',
      teamLogo: 'https://upload.wikimedia.org/wikipedia/en/e/eb/Manchester_City_FC_badge.svg',
      played: 12,
      won: 10,
      drawn: 1,
      lost: 1,
      goals: 35,
      goalsAgainst: 8,
      points: 31,
      isFavorite: true,
      zone: 'champions',
    ),
    StandingUI(
      rank: 2,
      teamName: 'Arsenal',
      teamLogo: 'https://upload.wikimedia.org/wikipedia/en/5/53/Arsenal_FC.svg',
      played: 12,
      won: 9,
      drawn: 2,
      lost: 1,
      goals: 32,
      goalsAgainst: 10,
      points: 29,
      isFavorite: false,
      zone: 'champions',
    ),
    StandingUI(
      rank: 3,
      teamName: 'Liverpool',
      teamLogo: 'https://upload.wikimedia.org/wikipedia/en/0/0c/Liverpool_FC.svg',
      played: 12,
      won: 8,
      drawn: 3,
      lost: 1,
      goals: 28,
      goalsAgainst: 9,
      points: 27,
      isFavorite: false,
      zone: 'champions',
    ),
    StandingUI(
      rank: 4,
      teamName: 'Chelsea',
      teamLogo: 'https://upload.wikimedia.org/wikipedia/en/0/0c/Chelsea_FC.svg',
      played: 12,
      won: 7,
      drawn: 2,
      lost: 3,
      goals: 25,
      goalsAgainst: 14,
      points: 23,
      isFavorite: false,
      zone: 'europa',
    ),
    StandingUI(
      rank: 5,
      teamName: 'Manchester United',
      teamLogo: 'https://upload.wikimedia.org/wikipedia/en/7/7a/Manchester_United_FC_badge.png',
      played: 12,
      won: 6,
      drawn: 3,
      lost: 3,
      goals: 22,
      goalsAgainst: 15,
      points: 21,
      isFavorite: false,
      zone: 'europa',
    ),
    StandingUI(
      rank: 6,
      teamName: 'Tottenham',
      teamLogo: 'https://upload.wikimedia.org/wikipedia/en/e/e8/Tottenham_Hotspur.svg',
      played: 12,
      won: 5,
      drawn: 4,
      lost: 3,
      goals: 19,
      goalsAgainst: 16,
      points: 19,
      isFavorite: false,
      zone: 'playoff',
    ),
    StandingUI(
      rank: 17,
      teamName: 'Luton Town',
      teamLogo: 'https://upload.wikimedia.org/wikipedia/en/5/51/Luton_Town_FC.svg',
      played: 12,
      won: 1,
      drawn: 2,
      lost: 9,
      goals: 8,
      goalsAgainst: 28,
      points: 5,
      isFavorite: false,
      zone: 'relegation',
    ),
    StandingUI(
      rank: 18,
      teamName: 'Nottingham Forest',
      teamLogo: 'https://upload.wikimedia.org/wikipedia/en/e/e5/Nottingham_Forest_FC_logo.svg',
      played: 12,
      won: 1,
      drawn: 1,
      lost: 10,
      goals: 6,
      goalsAgainst: 30,
      points: 4,
      isFavorite: false,
      zone: 'relegation',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade950,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        elevation: 0,
        title: const Text(
          'Football UI Demo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Tab Bar
            TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.5),
              indicatorColor: const Color(0xFF3B82F6),
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Matches'),
                Tab(text: 'Standings'),
              ],
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  // Matches Tab
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _sampleMatches.length,
                    itemBuilder: (context, index) {
                      return MatchCard(
                        match: _sampleMatches[index],
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${_sampleMatches[index].homeTeam} vs ${_sampleMatches[index].awayTeam}',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // Standings Tab
                  StandingsTable(
                    standings: _sampleStandings,
                    favoriteTeam: 'Manchester City',
                    onTeamTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Team tapped'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
