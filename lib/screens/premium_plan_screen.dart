import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/payment_service.dart'; // Đảm bảo import đúng đường dẫn service của bạn

class PremiumPlanScreen extends StatefulWidget {
  const PremiumPlanScreen({super.key});

  @override
  State<PremiumPlanScreen> createState() => _PremiumPlanScreenState();
}

class _PremiumPlanScreenState extends State<PremiumPlanScreen> {
  final _supabase = Supabase.instance.client;

  // Danh sách các gói cước (Đã thêm trường priceValue là số nguyên để gửi cho PayOS)
  final List<Map<String, dynamic>> _plans = [
    {
      'code': 'NHA_PRO',
      'name': 'NHA Pro',
      'price': '7.000đ',
      'priceValue': 7000, // Thêm số nguyên
      'desc': 'Trực tiếp toàn bộ Ngoại hạng Anh.',
      'leagues': ['PL'],
      'color': Colors.purpleAccent,
      'isSuper': false,
    },
    {
      'code': 'LALIGA_PRO',
      'name': 'Laliga Pro',
      'price': '6.000đ',
      'priceValue': 6000,
      'desc': 'Trực tiếp toàn bộ Laliga.',
      'leagues': ['PD'],
      'color': Colors.redAccent,
      'isSuper': false,
    },
    {
      'code': 'BUNDESLIGA_PRO',
      'name': 'Budesliga Pro',
      'price': '5.000đ',
      'priceValue': 5000,
      'desc': 'Trực tiếp toàn bộ Budesliga.',
      'leagues': ['BL1'],
      'color': Colors.orangeAccent,
      'isSuper': false,
    },
    {
      'code': 'SERIA_PRO',
      'name': 'SeriA Pro',
      'price': '2.000đ',
      'priceValue': 2000,
      'desc': 'Trực tiếp toàn bộ SeriA.',
      'leagues': ['SA'],
      'color': Colors.blueAccent,
      'isSuper': false,
    },
    {
      'code': 'SUPER_PRO',
      'name': 'Super Pro',
      'price': '10.000đ',
      'priceValue': 10000,
      'desc': 'Trải nghiệm đỉnh cao. Trực tiếp TẤT CẢ các giải đấu.',
      'leagues': ['PL', 'PD', 'BL1', 'SA'],
      'color': Colors.amber,
      'isSuper': true,
    },
  ];

  // Hàm xử lý thanh toán THẬT
  void _processRealPayment(Map<String, dynamic> plan) {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để thanh toán!')),
      );
      return;
    }

    // Gọi PaymentService để tạo giao dịch và mở PayOS
    PaymentService.checkoutPremium(
      context: context,
      userId: currentUser.id,
      planCode: plan['code'],
      planName: plan['name'],
      amount: plan['priceValue'],
    );
  }

  // Hiển thị Dialog xác nhận trước khi thanh toán
  void _showConfirmDialog(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Xác nhận thanh toán',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Bạn đang mua gói ${plan['name']} với giá ${plan['price']}/năm.\n\nĐồng ý chuyển sang cổng thanh toán?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: plan['color']),
            onPressed: () {
              Navigator.pop(context); // Đóng Dialog
              _processRealPayment(plan); // Bắt đầu thanh toán thật
            },
            child: const Text(
              'Thanh toán',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Nâng cấp Premium',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        centerTitle: true,
      ),
      // Đã bỏ Stack loading vì Loading sẽ do PaymentService quản lý
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _plans.length,
        itemBuilder: (context, index) {
          final plan = _plans[index];
          final isSuper = plan['isSuper'] == true;

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: isSuper
                  ? const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFF39C12)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSuper ? null : Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              border: isSuper
                  ? null
                  : Border.all(color: plan['color'], width: 1.5),
              boxShadow: isSuper
                  ? [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan['name'],
                    style: TextStyle(
                      color: isSuper ? Colors.black : Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isSuper)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Tiết kiệm nhất',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    plan['price'] + ' / năm',
                    style: TextStyle(
                      color: isSuper ? Colors.black87 : plan['color'],
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plan['desc'],
                    style: TextStyle(
                      color: isSuper ? Colors.black87 : Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuper ? Colors.black : plan['color'],
                  foregroundColor: isSuper ? Colors.amber : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => _showConfirmDialog(plan),
                child: const Text('Mua ngay'),
              ),
            ),
          );
        },
      ),
    );
  }
}
