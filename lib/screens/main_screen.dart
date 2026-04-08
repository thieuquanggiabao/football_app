import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'standings_screen.dart';
import 'news_screen.dart'; // Bổ sung Tab Tin tức
import 'team_search_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Danh sách các màn hình tương ứng với từng Tab
  final List<Widget> _screens = [
    const HomeScreen(), // Tab 0: Trực tiếp
    const StandingsScreen(), // Tab 1: Bảng xếp hạng
    const NewsScreen(), // Tab 2: Tin tức (MỚI THÊM NÈ)
    const TeamSearchScreen(), // Tab 3: Tìm kiếm đội bóng
    const ProfileScreen(), // Tab 4: Tài khoản
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Hiển thị màn hình theo tab đang chọn
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // Chuyển tab khi người dùng bấm
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Trực tiếp',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_numbered),
            label: 'BXH',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article), // Icon tờ báo cho nó chuẩn bài
            label: 'Tin tức',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }
}
