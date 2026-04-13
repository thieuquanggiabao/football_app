import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static const String _baseUrl = 'https://football-backend-7cqp.onrender.com';

  // 👇 THAY THẾ TOÀN BỘ HÀM NÀY 👇
  static Future<void> checkoutPremium({
    required BuildContext context,
    required String userId,
    required String planCode,
    required String planName,
    required int amount,
  }) async {
    try {
      // 1. Hiển thị vòng xoay loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.greenAccent),
        ),
      );

      // 2. Bắn API lên Node.js
      final response = await http.post(
        Uri.parse('$_baseUrl/api/create-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'packageType': planCode, // Truyền đúng mã gói
          'planName': planName, // Truyền tên gói
          'amount': amount, // Truyền giá tiền
        }),
      );

      // Tắt vòng xoay loading
      if (context.mounted) Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final String paymentUrl = data['paymentUrl'];

          // 3. Mở link PayOS
          final Uri url = Uri.parse(paymentUrl);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            throw 'Không thể mở trình duyệt';
          }
        } else {
          throw Exception(data['message'] ?? 'Lỗi tạo link thanh toán');
        }
      } else {
        throw Exception('Server Node.js đang lỗi: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      debugPrint('❌ Lỗi thanh toán: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tạo giao dịch lúc này. Thử lại sau!'),
          ),
        );
      }
    }
  }
}
