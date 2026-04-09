import 'package:flutter/material.dart';

/// Quick start example - Copy this to your main.dart to see the modern UI in action
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football App - Modern UI',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey.shade950,
      ),
      home: const QuickStartScreen(),
    );
  }
}

class QuickStartScreen extends StatelessWidget {
  const QuickStartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade950,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Modern Football UI - Quick Start'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionHeader(title: '✨ Features'),
          const SizedBox(height: 8),
          FeatureCard(
            title: 'Match Card',
            description: 'Glassmorphism effect with animated LIVE indicator',
            icon: Icons.sports_soccer,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          FeatureCard(
            title: 'Standings Table',
            description: 'Color-coded league zones with sticky header',
            icon: Icons.leaderboard,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          FeatureCard(
            title: 'Animations',
            description: 'Smooth pulsing effects and transitions',
            icon: Icons.animation,
            color: Colors.purple,
          ),
          const SizedBox(height: 20),
          SectionHeader(title: '📁 File Structure'),
          const SizedBox(height: 12),
          CodeBlock(code: '''lib/
├── models/
│   └── ui_models.dart
├── widgets/
│   ├── match_card_modern.dart
│   ├── standings_table_modern.dart
│   ├── football_ui_demo.dart
│   ├── modern_ui_integration.dart
│   └── MODERN_UI_GUIDE.md'''),
          const SizedBox(height: 20),
          SectionHeader(title: '🚀 Integration Steps'),
          const SizedBox(height: 12),
          _buildStep(1, 'Import the models',
              'import "lib/models/ui_models.dart";'),
          const SizedBox(height: 12),
          _buildStep(2, 'Import the widgets',
              'import "lib/widgets/match_card_modern.dart";\nimport "lib/widgets/standings_table_modern.dart";'),
          const SizedBox(height: 12),
          _buildStep(3, 'Create UI models from your data',
              'final match = MatchUI(...)\nfinal standing = StandingUI(...);'),
          const SizedBox(height: 12),
          _buildStep(4, 'Display in your UI',
              'MatchCard(match: match)\nStandingsTable(standings: standings)'),
          const SizedBox(height: 20),
          SectionHeader(title: '💡 Usage Examples'),
          const SizedBox(height: 12),
          _buildUsageExample(
            'Simple Match Card',
            '''MatchCard(
  match: MatchUI(
    homeTeam: 'Manchester United',
    awayTeam: 'Liverpool',
    homeTeamLogo: 'url',
    awayTeamLogo: 'url',
    homeScore: 2,
    awayScore: 1,
    status: 'LIVE',
    matchTime: '67\'',
  ),
  onTap: () => print('Match tapped'),
)''',
          ),
          const SizedBox(height: 16),
          _buildUsageExample(
            'Simple Standings Table',
            '''StandingsTable(
  standings: standings,
  favoriteTeam: 'Manchester City',
  onTeamTap: () => print('Team tapped'),
)''',
          ),
          const SizedBox(height: 20),
          SectionHeader(title: '🎨 Customization'),
          const SizedBox(height: 12),
          CustomizationTip(
            title: 'Change LIVE Pulse Color',
            hint: 'Edit match_card_modern.dart, line ~120',
            color: Colors.red,
          ),
          const SizedBox(height: 8),
          CustomizationTip(
            title: 'Adjust Zone Colors',
            hint: 'Edit standings_table_modern.dart, line ~25',
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          CustomizationTip(
            title: 'Modify Blur Effect',
            hint: 'Edit match_card_modern.dart, line ~50',
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
          SectionHeader(title: '📚 More Info'),
          const SizedBox(height: 12),
          InfoCard(
            title: 'Full Documentation',
            description: 'See MODERN_UI_GUIDE.md for detailed API reference',
            icon: Icons.description,
          ),
          const SizedBox(height: 8),
          InfoCard(
            title: 'Integration Examples',
            description: 'Check modern_ui_integration.dart for real-world usage',
            icon: Icons.code,
          ),
          const SizedBox(height: 8),
          InfoCard(
            title: 'Live Demo',
            description: 'Run football_ui_demo.dart to see components in action',
            icon: Icons.play_circle,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✅ Ready to Use',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'All components are production-ready and can be integrated into your app immediately.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String title, String code) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              code,
              style: TextStyle(
                color: Colors.green[400],
                fontFamily: 'Courier',
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageExample(String title, String code) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              code,
              style: TextStyle(
                color: Colors.amber[300],
                fontFamily: 'Courier',
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const FeatureCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CodeBlock extends StatelessWidget {
  final String code;

  const CodeBlock({Key? key, required this.code}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        code,
        style: TextStyle(
          color: Colors.cyan[300],
          fontFamily: 'Courier',
          fontSize: 11,
        ),
      ),
    );
  }
}

class CustomizationTip extends StatelessWidget {
  final String title;
  final String hint;
  final Color color;

  const CustomizationTip({
    Key? key,
    required this.title,
    required this.hint,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hint,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const InfoCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
