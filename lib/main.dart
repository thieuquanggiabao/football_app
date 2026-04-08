import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'core/constants.dart';
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

  timeago.setLocaleMessages('vi', timeago.ViMessages());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn =
        Supabase.instance.client.auth.currentSession != null;

    return MaterialApp(
      title: 'Live Football Results',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // Cổng vào: kiểm tra phiên đăng nhập
      // 123
      home: isLoggedIn ? const MainScreen() : const LoginScreen(),
      // Named routes — dùng bởi profile_screen và các màn hình khác
      // LƯU Ý: Không được đặt '/' ở đây vì đã có home: ở trên
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
        '/premium': (context) => const PremiumPlanScreen(),
        '/commented-news': (context) => const CommentedNewsScreen(),
      },
    );
  }
}
