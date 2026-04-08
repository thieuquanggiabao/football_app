# Modern Football App UI Components

This package contains modern, production-ready Flutter UI components for a football app with glassmorphism effects, animations, and responsive design.

## 📦 Components

### 1. **MatchCard** - Modern Match Display
**File:** `lib/widgets/match_card_modern.dart`

#### Features:
- ✨ **Glassmorphism Effect**: Blur background with semi-transparent container
- 🎨 **Dark Theme**: Premium dark aesthetic
- 🏆 **Large Team Logos**: Prominent circular avatars
- 📊 **Clear Score Display**: Center-positioned, easy-to-read scores
- 🔴 **LIVE Indicator**: Pulsing red dot animation for live matches
- ⏱️ **Match Time**: Displays current match time or scheduled time
- 📱 **Responsive**: Adapts to different screen sizes
- 🎯 **Gestures**: Supports tap interactions

#### Usage:
```dart
MatchCard(
  match: MatchUI(
    homeTeam: 'Manchester United',
    awayTeam: 'Liverpool',
    homeTeamLogo: 'https://example.com/logo1.png',
    awayTeamLogo: 'https://example.com/logo2.png',
    homeScore: 2,
    awayScore: 1,
    status: 'LIVE', // 'LIVE', 'FINISHED', 'SCHEDULED'
    matchTime: '67\'',
  ),
  onTap: () {
    print('Match tapped');
  },
)
```

#### MatchUI Properties:
- `homeTeam` (String) - Home team name
- `awayTeam` (String) - Away team name
- `homeTeamLogo` (String) - URL to home team logo
- `awayTeamLogo` (String) - URL to away team logo
- `homeScore` (int) - Home team score
- `awayScore` (int) - Away team score
- `status` (String) - Match status ('LIVE', 'FINISHED', 'SCHEDULED')
- `matchTime` (String?) - Current time in match or scheduled time

---

### 2. **StandingsTable** - League Table with Zones
**File:** `lib/widgets/standings_table_modern.dart`

#### Features:
- 📋 **Sticky Header**: Column titles remain visible when scrolling
- 🎨 **Color-Coded Zones**:
  - Green: Champions League qualification
  - Blue: Europa League qualification
  - Orange: Playoff qualification
  - Red: Relegation zone
- ⭐ **Zone Badges**: Displays CL, EL, PO, or REL badges
- ⭐ **Favorite Team Highlighting**: Bold text and glow effect
- 📊 **Detailed Stats**: Shows W-D-L record for each team
- 📱 **Responsive**: Scrollable with adaptive layout
- 🎯 **Tap Interaction**: Click to interact with rows

#### Usage:
```dart
StandingsTable(
  standings: List<StandingUI>[
    StandingUI(
      rank: 1,
      teamName: 'Manchester City',
      teamLogo: 'https://example.com/logo.png',
      played: 12,
      won: 10,
      drawn: 1,
      lost: 1,
      goals: 35,
      goalsAgainst: 8,
      points: 31,
      isFavorite: true,
      zone: 'champions', // 'champions', 'europa', 'playoff', 'relegation'
    ),
    // ... more teams
  ],
  favoriteTeam: 'Manchester City',
  onTeamTap: () {
    print('Team tapped');
  },
)
```

#### StandingUI Properties:
- `rank` (int) - Team rank in standings
- `teamName` (String) - Team name
- `teamLogo` (String) - URL to team logo
- `played` (int) - Matches played
- `won` (int) - Matches won
- `drawn` (int) - Matches drawn
- `lost` (int) - Matches lost
- `goals` (int) - Goals scored
- `goalsAgainst` (int) - Goals against
- `points` (int) - Total points
- `isFavorite` (bool) - Whether this is the user's favorite team
- `zone` (String) - League zone ('champions', 'europa', 'playoff', 'relegation')

---

## 🎨 Customization Guide

### Change Color Scheme

**For MatchCard:**
Edit colors in `_buildStatusBar()` and `_buildTeamSection()`:
```dart
const Color(0xFFFF3838) // LIVE indicator color
Colors.white.withOpacity(0.15) // Container background
```

**For StandingsTable:**
Edit `_getZoneColor()` method:
```dart
case 'champions':
  return const Color(0xFF10B981).withOpacity(0.15); // Change green
case 'europa':
  return const Color(0xFF3B82F6).withOpacity(0.15); // Change blue
```

### Adjust Animations

**LIVE Pulsing Speed:**
```dart
_pulseController = AnimationController(
  duration: const Duration(milliseconds: 1200), // Increase for slower pulse
  vsync: this,
)..repeat();
```

### Modify Spacing & Padding

All components use `EdgeInsets.symmetric()` or `EdgeInsets.only()`:
```dart
margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Adjust here
padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20), // Adjust here
```

---

## 📱 Demo Screen

View all components together in `lib/widgets/football_ui_demo.dart`

Run the demo:
```dart
// In your main.dart
import 'package:football_app/widgets/football_ui_demo.dart';

void main() {
  runApp(MaterialApp(
    home: const FootballUIDemo(),
  ));
}
```

The demo includes:
- Sample match data with LIVE, FINISHED, and SCHEDULED statuses
- Sample standings with all zone types
- Tab navigation between Matches and Standings
- Interactive tap handlers with SnackBar feedback

---

## 🎯 Integration Examples

### Example 1: Display Live Matches
```dart
class MatchesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        return MatchCard(
          match: matches[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MatchDetailsScreen(match: matches[index]),
            ),
          ),
        );
      },
    );
  }
}
```

### Example 2: Display League Table
```dart
class StandingsScreen extends StatefulWidget {
  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  String? _favoriteTeam;

  @override
  Widget build(BuildContext context) {
    return StandingsTable(
      standings: leagueStandings,
      favoriteTeam: _favoriteTeam,
      onTeamTap: () => _handleTeamTap(),
    );
  }

  void _handleTeamTap() {
    // Handle team selection
  }
}
```

### Example 3: Combine Both in TabView
```dart
DefaultTabController(
  length: 2,
  child: Column(
    children: [
      TabBar(
        tabs: [
          Tab(text: 'Matches'),
          Tab(text: 'Standings'),
        ],
      ),
      Expanded(
        child: TabBarView(
          children: [
            // Matches tab content
            ListView(
              children: matches
                  .map((m) => MatchCard(match: m))
                  .toList(),
            ),
            // Standings tab content
            StandingsTable(standings: standings),
          ],
        ),
      ),
    ],
  ),
)
```

---

## 🎬 Animation Details

### MatchCard LIVE Indicator
- **Type**: Scale animation with pulse effect
- **Duration**: 1.2 seconds per cycle
- **Effect**: Scales from 0.8x to 1.2x size
- **Color**: Bright red (#FF3838) with glow shadow

### StandingsTable Favorite Team
- **Type**: Glow shadow effect
- **Effect**: Box shadow around the team row
- **Color**: Matches the zone color with 0.4 opacity

---

## 📂 File Structure

```
lib/
├── models/
│   └── ui_models.dart           # Data models (MatchUI, StandingUI)
├── widgets/
│   ├── match_card_modern.dart   # Match display component
│   ├── standings_table_modern.dart # League table component
│   └── football_ui_demo.dart    # Demo screen with sample data
```

---

## 🚀 Performance Tips

1. **Image Loading**: Use proper image caching
   ```dart
   Image.network(
     logo,
     fit: BoxFit.cover,
     cacheHeight: 100,
     cacheWidth: 100,
   )
   ```

2. **List Performance**: Use `ListView.builder()` instead of `ListView()`

3. **Animation Performance**: Use `SingleTickerProviderStateMixin` for efficiency

4. **Blur Performance**: Adjust blur sigma values if needed on lower-end devices
   ```dart
   filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Lower values for better performance
   ```

---

## 🎨 Dark Theme Support

Both components are designed for dark themes. They work best with:
- Background: `Colors.grey.shade950` or `Colors.black87`
- Scaffold: `AppBar` with `Colors.grey.shade900`

To adapt to light theme, modify opacity values in components:
```dart
// From:
Colors.white.withOpacity(0.15)
// To:
Colors.black.withOpacity(0.1)
```

---

## ✨ Features Summary

| Feature | MatchCard | StandingsTable |
|---------|-----------|----------------|
| Glassmorphism | ✅ | - |
| Animations | ✅ (LIVE pulse) | - |
| Theme Support | Dark | Dark |
| Responsive | ✅ | ✅ |
| Tap Interaction | ✅ | ✅ |
| Scroll Support | - | ✅ (sticky header) |
| Color Zones | - | ✅ |
| Favorite Highlight | - | ✅ |
| Logo Display | ✅ | ✅ |
| Stats Display | ✅ | ✅ |

---

## 🔗 Dependencies

None! These components use only Flutter built-in widgets:
- `Container`, `Row`, `Column`
- `Image.network`
- `BorderRadius`, `BoxDecoration`
- `AnimationController`, `Tween`
- `ListView`, `TabBar`

---

## 📝 License

These components are part of the Football App project.

---

## 🤝 Support

For issues or feature requests, refer to the component files for customization options.
