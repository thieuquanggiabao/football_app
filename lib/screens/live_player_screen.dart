import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/match_model.dart';
import 'premium_plan_screen.dart'; // Import màn hình Bảng giá

class LivePlayerScreen extends StatefulWidget {
  final MatchModel match;

  const LivePlayerScreen({super.key, required this.match});

  @override
  State<LivePlayerScreen> createState() => _LivePlayerScreenState();
}

class _LivePlayerScreenState extends State<LivePlayerScreen> {
  bool _hasAccess = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  // HÀM KIỂM TRA QUYỀN TRUY CẬP TỪ SUPABASE
  // HÀM KIỂM TRA QUYỀN TRUY CẬP TỪ SUPABASE (BẢN CHUẨN)
  void _checkAccess() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _hasAccess = false;
        _isLoading = false;
      });
      return;
    }

    final metadata = user.userMetadata ?? {};
    final subscription = metadata['subscription'] ?? {};

    // 1. Kiểm tra ngày hết hạn
    final expireDateStr = subscription['expire_date'];
    if (expireDateStr != null) {
      final expireDate = DateTime.parse(expireDateStr);
      if (DateTime.now().isAfter(expireDate)) {
        setState(() {
          _hasAccess = false;
          _isLoading = false;
        });
        return;
      }
    }

    // 2. Nếu là Super Pro → mở khóa TẤT CẢ giải đấu
    final planCode = subscription['plan_code'];
    if (planCode == 'SUPER_PRO') {
      setState(() {
        _hasAccess = true;
        _isLoading = false;
      });
      return;
    }

    // 3. Các gói lẻ: kiểm tra giải đấu cụ thể
    final List<String> unlockedLeagues = List<String>.from(
      subscription['unlocked_leagues'] ?? [],
    );
    final bool access = unlockedLeagues.contains(widget.match.leagueCode);

    setState(() {
      _hasAccess = access;
      _isLoading = false;
    });
  }

  // GIAO DIỆN KHI BỊ KHÓA (CHƯA MUA GÓI)
  Widget _buildLockedScreen() {
    return Container(
      height: 230,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: const NetworkImage(
            'https://images.unsplash.com/photo-1518605368461-1e1e38ce156d',
          ), // Ảnh sân cỏ
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.8),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, color: Colors.amber, size: 50),
          const SizedBox(height: 12),
          const Text(
            'Nội dung có bản quyền',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Gói Premium hiện tại của bạn không hỗ trợ giải đấu này.\nVui lòng nâng cấp đúng gói bản quyền để xem trực tiếp.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.workspace_premium),
            label: const Text(
              'Nâng cấp ngay',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              // Mở bảng giá, đợi mua xong thì load lại quyền truy cập
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PremiumPlanScreen(),
                ),
              ).then((value) {
                if (value == true) {
                  _checkAccess(); // Kích hoạt mở khóa nếu mua thành công!
                }
              });
            },
          ),
        ],
      ),
    );
  }

  // GIAO DIỆN KHI ĐÃ CÓ VÉ (GIẢ LẬP VIDEO PLAYER)
  Widget _buildVideoPlayer() {
    return Container(
      height: 230,
      width: double.infinity,
      color: Colors.black,
      child: const Stack(
        alignment: Alignment.center,
        children: [
          // Giả lập đang chiếu video
          Icon(Icons.play_circle_fill, color: Colors.white54, size: 60),
          Positioned(
            bottom: 10,
            left: 10,
            child: Row(
              children: [
                Icon(Icons.circle, color: Colors.redAccent, size: 12),
                SizedBox(width: 4),
                Text(
                  'TRỰC TIẾP',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
        backgroundColor: Colors.black,
        foregroundColor: Colors.greenAccent,
        // Tên trận đấu trên thanh tiêu đề
        title: Text(
          '${widget.match.homeTeam} vs ${widget.match.awayTeam}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            )
          : Column(
              children: [
                // ĐÂY LÀ CHỖ QUYẾT ĐỊNH CHO XEM HAY KHÓA!
                _hasAccess ? _buildVideoPlayer() : _buildLockedScreen(),

                // Phần bên dưới hiển thị thêm thông tin trận đấu (Tỉ số, logo...)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          'Cập nhật diễn biến',
                          style: TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 20),
                        // Hiện tỉ số to ở giữa màn hình
                        Text(
                          '${widget.match.homeScore} - ${widget.match.awayScore}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
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
