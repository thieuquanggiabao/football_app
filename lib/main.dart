import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'core/constants.dart';
import 'core/theme_provider.dart';
import 'core/notification_service.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/premium_plan_screen.dart';
import 'screens/commented_news_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  await NotificationService.init();

  timeago.setLocaleMessages('vi', timeago.ViMessages());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn =
        Supabase.instance.client.auth.currentSession != null;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProviderModel()),
      ],
      child: Consumer<ThemeProviderModel>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Live Football Results',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.getLightTheme(),
            darkTheme: themeProvider.getDarkTheme(),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            // Cổng vào: kiểm tra phiên đăng nhập
            home: _CircularRevealWrapper(
              child: isLoggedIn ? const MainScreen() : const LoginScreen(),
            ),
            // Named routes — dùng bởi profile_screen và các màn hình khác
            // LƯU Ý: Không được đặt '/' ở đây vì đã có home: ở trên
            routes: {
              '/login': (context) => const LoginScreen(),
              '/main': (context) => const MainScreen(),
              '/premium': (context) => const PremiumPlanScreen(),
              '/commented-news': (context) => const CommentedNewsScreen(),
            },
          );
        },
      ),
    );
  }
}

/// Wrapper với Circular Reveal animation khi theme thay đổi
class _CircularRevealWrapper extends StatefulWidget {
  final Widget child;

  const _CircularRevealWrapper({required this.child});

  @override
  State<_CircularRevealWrapper> createState() => _CircularRevealWrapperState();
}

class _CircularRevealWrapperState extends State<_CircularRevealWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _revealController;
  late bool _previousDarkMode;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _previousDarkMode = context.read<ThemeProviderModel>().isDarkMode;
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final themeProvider = context.watch<ThemeProviderModel>();

    if (themeProvider.isDarkMode != _previousDarkMode) {
      _previousDarkMode = themeProvider.isDarkMode;
      setState(() => _isAnimating = true);
      
      _revealController.forward(from: 0.0).then((_) {
        if (mounted) {
          setState(() => _isAnimating = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Circular reveal animation
        if (_isAnimating)
          AnimatedBuilder(
            animation: _revealController,
            builder: (context, _) {
              return Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _CircularRevealPainter(
                      progress: _revealController.value,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Painter cho circular reveal animation
class _CircularRevealPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;

  _CircularRevealPainter({
    required this.progress,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = backgroundColor;
    
    // Draw full rect
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    // Clear circular area từ tâm
    final maxDistance = (size.width * size.width + size.height * size.height).toDouble();
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      maxDistance * progress,
      Paint()..blendMode = BlendMode.clear,
    );
  }

  @override
  bool shouldRepaint(_CircularRevealPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
