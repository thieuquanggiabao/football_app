import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/match_model.dart';

/// Singleton quản lý toàn bộ tính năng thông báo lên lịch (Local Notifications)
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Tên & ID kênh thông báo Android
  static const String _channelId = 'match_reminders';
  static const String _channelName = 'Nhắc trận đấu';
  static const String _channelDesc = 'Thông báo trước khi trận đấu bắt đầu 5 phút';

  /// Gọi một lần duy nhất trong main() trước runApp()
  static Future<void> init() async {
    // 1. Khởi tạo dữ liệu múi giờ
    tz.initializeTimeZones();
    // Đặt local timezone (Việt Nam)
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    // 2. Cấu hình Android: dùng icon mặc định của app
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // 3. Tạo Notification Channel trên Android (bắt buộc từ API 26+)
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Xin quyền gửi thông báo (Android 13+).
  /// Trả về true nếu được cấp quyền.
  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;
    final granted = await android.requestNotificationsPermission();
    return granted ?? false;
  }

  /// Lên lịch thông báo nhắc trước 5 phút khi trận bắt đầu.
  /// Trả về false nếu trận quá gần (không kịp nhắc).
  static Future<bool> scheduleMatchReminder(MatchModel match) async {
    final reminderTime =
        match.startedAt.subtract(const Duration(minutes: 5));

    // Nếu thời điểm nhắc đã qua → không thể đặt
    if (reminderTime.isBefore(DateTime.now())) {
      return false;
    }

    final tzReminderTime = tz.TZDateTime.from(reminderTime, tz.local);

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Sắp có trận đấu!',
      styleInformation: BigTextStyleInformation(
        '⚽ ${match.homeTeam} vs ${match.awayTeam} sẽ bắt đầu sau 5 phút!',
        summaryText: 'Football LiveScore',
      ),
      color: const Color(0xFF00E676), // Màu xanh lá
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.zonedSchedule(
      match.apiMatchId, // ID duy nhất = ID trận đấu
      '🔔 Sắp đến giờ thi đấu!',
      '${match.homeTeam} vs ${match.awayTeam} — còn 5 phút nữa!',
      tzReminderTime,
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexact,
    );

    return true;
  }

  /// Hủy thông báo đã lên lịch cho trận đấu.
  static Future<void> cancelReminder(int matchId) async {
    await _plugin.cancel(matchId);
  }

  /// Kiểm tra xem trận đấu đã được đặt báo thức chưa.
  static Future<bool> isReminderSet(int matchId) async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.any((n) => n.id == matchId);
  }
}
