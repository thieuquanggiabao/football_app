import 'package:flutter/material.dart';

/// Enum định nghĩa các màu đội bóng nổi tiếng
enum TeamColor {
  red, // Manchester United, Liverpool
  blue, // Chelsea, Manchester City
  white, // Real Madrid, Juventus
  black, // Newcastle, Fulham
  green, // Manchester United (secondary)
  yellow, // Dortmund, Arsenal
  purple,
  orange,
  custom,
}

/// Model lưu thông tin tema động
class ThemeProviderModel extends ChangeNotifier {
  Color _accentColor = Colors.green;
  Color _primaryColor = Colors.black;
  bool _isDarkMode = true;

  Color get accentColor => _accentColor;
  Color get primaryColor => _primaryColor;
  bool get isDarkMode => _isDarkMode;

  /// Hàm thay đổi theme dựa vào màu đội bóng
  void setTeamTheme(String teamName, {Color? customColor}) {
    // Ánh xạ đội bóng với màu sắc
    final colorMap = {
      'manchester united': Colors.red.shade700,
      'manchester city': Colors.blue.shade600,
      'liverpool': Colors.red.shade800,
      'chelsea': Colors.blue.shade800,
      'arsenal': Colors.red.shade600,
      'tottenham': Colors.white,
      'real madrid': Colors.white,
      'barcelona': Colors.blue.shade900,
      'juventus': Colors.black,
      'ac milan': Colors.red.shade900,
      'inter milan': Colors.blue.shade800,
      'paris': Colors.blue.shade700,
      'dortmund': Colors.yellow.shade800,
    };

    final color = colorMap[teamName.toLowerCase()] ?? customColor ?? Colors.green;
    setAccentColor(color);
  }

  void setAccentColor(Color color) {
    _accentColor = color;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }

  /// Get light theme
  ThemeData getLightTheme() {
    return _getLightTheme();
  }

  /// Get dark theme
  ThemeData getDarkTheme() {
    return _getDarkTheme();
  }

  /// Tạo ThemeData dựa vào accent color hiện tại (deprecated - use getLightTheme/getDarkTheme)
  ThemeData getTheme() {
    return _isDarkMode ? _getDarkTheme() : _getLightTheme();
  }

  ThemeData _getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _accentColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey.shade900,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        displayMedium: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        displaySmall: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineMedium: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineSmall: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        titleLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        bodyLarge: const TextStyle(color: Colors.white),
        bodyMedium: const TextStyle(color: Colors.white70),
        bodySmall: const TextStyle(color: Colors.white54),
        labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      dividerColor: Colors.white12,
      primaryIconTheme: const IconThemeData(color: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: Colors.white),
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIconColor: Colors.white,
      ),
    );
  }

  ThemeData _getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _accentColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      textTheme: TextTheme(
        displayLarge: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        displayMedium: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        displaySmall: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        headlineMedium: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        headlineSmall: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        titleLarge: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        bodyLarge: const TextStyle(color: Colors.black87),
        bodyMedium: const TextStyle(color: Colors.black87),
        bodySmall: const TextStyle(color: Colors.black54),
        labelLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      ),
      dividerColor: Colors.black12,
      primaryIconTheme: const IconThemeData(color: Colors.black87),
      iconTheme: const IconThemeData(color: Colors.black87),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: Colors.black87),
        hintStyle: const TextStyle(color: Colors.black54),
        prefixIconColor: Colors.black87,
      ),
    );
  }
}
