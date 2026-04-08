import 'package:flutter/material.dart';
import '../models/ui_models.dart';
import '../models/match_model.dart';
import '../models/standing_model.dart';
import 'match_card_modern.dart';
import 'standings_table_modern.dart';

/// Integration helper to convert app models to UI models
class UIModelConverter {
  /// Convert MatchModel to MatchUI
  static MatchUI convertMatchToUI(dynamic match) {
    // Adjust based on your MatchModel structure
    // This is an example - modify according to your actual model
    return MatchUI(
      homeTeam: match.homeTeam ?? 'Unknown',
      awayTeam: match.awayTeam ?? 'Unknown',
      homeTeamLogo: match.homeTeamLogo ?? '',
      awayTeamLogo: match.awayTeamLogo ?? '',
      homeScore: match.homeScore ?? 0,
      awayScore: match.awayScore ?? 0,
      status: match.status ?? 'SCHEDULED',
      matchTime: match.matchTime,
    );
  }

  /// Convert StandingModel to StandingUI
  static StandingUI convertStandingToUI(
    dynamic standing,
    String? favoriteTeam,
  ) {
    // Adjust based on your StandingModel structure
    // This is an example - modify according to your actual model
    final zone = _getZoneFromRank(standing.rank ?? 20);
    return StandingUI(
      rank: standing.rank ?? 0,
      teamName: standing.teamName ?? 'Unknown',
      teamLogo: standing.teamLogo ?? '',
      played: standing.played ?? 0,
      won: standing.won ?? 0,
      drawn: standing.drawn ?? 0,
      lost: standing.lost ?? 0,
      goals: standing.goalFor ?? 0,
      goalsAgainst: standing.goalAgainst ?? 0,
      points: standing.points ?? 0,
      isFavorite: standing.teamName == favoriteTeam,
      zone: zone,
    );
  }

  /// Determine zone based on rank
  static String _getZoneFromRank(int rank) {
    if (rank <= 4) return 'champions';
    if (rank <= 6) return 'europa';
    if (rank <= 8) return 'playoff';
    if (rank > 18) return 'relegation';
    return 'regular';
  }

  /// Convert multiple matches
  static List<MatchUI> convertMatches(List<dynamic> matches) {
    return matches.map((m) => convertMatchToUI(m)).toList();
  }

  /// Convert multiple standings
  static List<StandingUI> convertStandings(
    List<dynamic> standings,
    String? favoriteTeam,
  ) {
    return standings
        .map((s) => convertStandingToUI(s, favoriteTeam))
        .toList();
  }
}

/// Example integration screen with real data fetching
class ModernMatchesScreen extends StatefulWidget {
  const ModernMatchesScreen({Key? key}) : super(key: key);

  @override
  State<ModernMatchesScreen> createState() => _ModernMatchesScreenState();
}

class _ModernMatchesScreenState extends State<ModernMatchesScreen> {
  // Add your repository here
  // final MatchRepository _matchRepository = MatchRepository();
  
  List<MatchUI> matches = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() => isLoading = true);
    try {
      // Example: Uncomment and connect to your repository
      // final matchModels = await _matchRepository.getMatches();
      // final uiMatches = UIModelConverter.convertMatches(matchModels);
      
      // setState(() {
      //   matches = uiMatches;
      //   isLoading = false;
      // });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading matches: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer,
              size: 48,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No matches found',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        return MatchCard(
          match: matches[index],
          onTap: () => _handleMatchTap(matches[index]),
        );
      },
    );
  }

  void _handleMatchTap(MatchUI match) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${match.homeTeam} vs ${match.awayTeam}'),
        duration: const Duration(seconds: 2),
      ),
    );
    // Navigation example:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => MatchDetailsScreen(match: match),
    //   ),
    // );
  }
}

/// Example integration screen for standings
class ModernStandingsScreen extends StatefulWidget {
  const ModernStandingsScreen({Key? key}) : super(key: key);

  @override
  State<ModernStandingsScreen> createState() => _ModernStandingsScreenState();
}

class _ModernStandingsScreenState extends State<ModernStandingsScreen> {
  // Add your repository here
  // final StandingRepository _standingRepository = StandingRepository();
  
  List<StandingUI> standings = [];
  String? favoriteTeam = 'Your Team'; // Get from preferences/state
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStandings();
  }

  Future<void> _loadStandings() async {
    setState(() => isLoading = true);
    try {
      // Example: Uncomment and connect to your repository
      // final standingModels = await _standingRepository.getStandings();
      // final uiStandings = UIModelConverter.convertStandings(
      //   standingModels,
      //   favoriteTeam,
      // );
      
      // setState(() {
      //   standings = uiStandings;
      //   isLoading = false;
      // });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading standings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (standings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard,
              size: 48,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No standings data',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return StandingsTable(
      standings: standings,
      favoriteTeam: favoriteTeam,
      onTeamTap: () => _handleTeamTap(),
    );
  }

  void _handleTeamTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Team selected'),
        duration: Duration(seconds: 1),
      ),
    );
    // Navigation example:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => TeamDetailScreen(team: team),
    //   ),
    // );
  }
}

/// Example: Combine both components in a tabbed interface
class ModernFootballScreen extends StatefulWidget {
  const ModernFootballScreen({Key? key}) : super(key: key);

  @override
  State<ModernFootballScreen> createState() => _ModernFootballScreenState();
}

class _ModernFootballScreenState extends State<ModernFootballScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade950,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        elevation: 0,
        title: const Text(
          'Football',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.5),
          indicatorColor: const Color(0xFF3B82F6),
          indicatorWeight: 3,
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_soccer, size: 20),
                  SizedBox(width: 8),
                  Text('Matches'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.leaderboard, size: 20),
                  SizedBox(width: 8),
                  Text('Standings'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ModernMatchesScreen(),
          ModernStandingsScreen(),
        ],
      ),
    );
  }
}
