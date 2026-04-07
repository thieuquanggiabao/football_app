import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PremiumPlanScreen extends StatefulWidget {
  const PremiumPlanScreen({super.key});

  @override
  State<PremiumPlanScreen> createState() => _PremiumPlanScreenState();
}

class _PremiumPlanScreenState extends State<PremiumPlanScreen> {
  final _supabase = Supabase.instance.client;
  bool _isProcessing = false; // Trạng thái đang xử lý thanh toán

  // Danh sách các gói cước chuẩn hóa dữ liệu
  final List<Map<String, dynamic>> _plans = [
    {
      'code': 'NHA_PRO',
      'name': 'NHA Pro',
      'price': '299.000đ',
      'desc': 'Trực tiếp toàn bộ Ngoại hạng Anh.',
      'leagues': ['PL'],
      'color': Colors.purpleAccent,
      'isSuper': false,
    },
    {
      'code': 'LALIGA_PRO',
      'name': 'Laliga Pro',
      'price': '199.000đ',
      'desc': 'Trực tiếp toàn bộ Laliga.',
      'leagues': ['PD'],
      'color': Colors.redAccent,
      'isSuper': false,
    },
    {
      'code': 'BUNDESLIGA_PRO',
      'name': 'Budesliga Pro',
      'price': '149.000đ',
      'desc': 'Trực tiếp toàn bộ Budesliga.',
      'leagues': ['BL1'],
      'color': Colors.orangeAccent,
      'isSuper': false,
    },
    {
      'code': 'SERIA_PRO',
      'name': 'SeriA Pro',
      'price': '99.000đ',
      'desc': 'Trực tiếp toàn bộ SeriA.',
      'leagues': ['SA'],
      'color': Colors.blueAccent,
      'isSuper': false,
    },
    {
      'code': 'SUPER_PRO',
      'name': 'Super Pro',
      'price': '699.000đ',
      'desc': 'Trải nghiệm đỉnh cao. Trực tiếp TẤT CẢ các giải đấu.',
      'leagues': ['PL', 'PD', 'BL1', 'SA'],
      'color': Colors.amber, // Màu vàng đặc biệt
      'isSuper': true, // Đánh dấu gói VIP nhất
    },
  ];

  // Hàm xử lý thanh toán giả lập và cập nhật Supabase
  Future<void> _processMockPayment(Map<String, dynamic> plan) async {
    setState(() => _isProcessing = true);

    // 1. Giả lập thời gian chờ gọi API ngân hàng (2 giây)
    await Future.delayed(const Duration(seconds: 2));

    try {
      // 2. Tính toán ngày hết hạn (30 ngày kể từ lúc mua)
      final expireDate = DateTime.now()
          .add(const Duration(days: 30))
          .toIso8601String();

      // 3. Cập nhật User Metadata trên Supabase
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'subscription': {
              'plan_code': plan['code'],
              'unlocked_leagues': plan['leagues'],
              'expire_date': expireDate,
            },
          },
        ),
      );

      // 4. Thông báo thành công và đóng màn hình
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Thanh toán thành công gói ${plan['name']}!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Trả về true báo hiệu đã mua xong
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi hệ thống: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
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
          'Bạn đang mua gói ${plan['name']} với giá ${plan['price']}/tháng.\n\nĐồng ý thanh toán?',
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
              _processMockPayment(plan); // Bắt đầu thanh toán
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
        foregroundColor: Colors.amber, // Tông màu vàng hoàng gia
        centerTitle: true,
      ),
      // Bọc toàn bộ bằng Stack để hiện vòng xoay Loading khi đang thanh toán
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _plans.length,
            itemBuilder: (context, index) {
              final plan = _plans[index];
              final isSuper = plan['isSuper'] == true;

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  // Nếu là gói Super Pro -> Nền Gradient Vàng. Còn lại -> Nền Xám đậm
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
                            color: Colors.orange.withOpacity(0.4),
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
                        plan['price'] + ' / tháng',
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

          // Màn chắn Loading khi đang xử lý thanh toán
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.amber),
                    SizedBox(height: 16),
                    Text(
                      'Đang kết nối cổng thanh toán...',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
