import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart' as g_auth;
import 'dart:math' as math;
import '../core/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  // HÀM XỬ LÝ ĐĂNG NHẬP GOOGLE
  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);
    final g_auth.GoogleSignIn api = g_auth.GoogleSignIn(
      serverClientId: AppConstants.googleServerClientId,
    );
    try {
      // 2. Mở bảng chọn tài khoản Google trên điện thoại
      final googleUser = await api.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // Người dùng bấm Hủy
      }

      // 3. Lấy "giấy thông hành" từ Google
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null || accessToken == null) {
        throw 'Không lấy được giấy thông hành từ Google.';
      }

      // 4. Giao nộp giấy thông hành cho Supabase để tạo tài khoản
      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // 5. Nếu thành công, chuyển thẳng vào Màn hình chính
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('🎉 Đăng nhập thành công!'),
              backgroundColor: Colors.greenAccent),
        );
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (error) {
      // Hiệu ứng rung khi có lỗi
      _triggerShakeAnimation();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: $error'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _triggerShakeAnimation() {
    _shakeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background ảnh có blur
          Image.network(
            'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=500',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: Colors.black);
            },
          ),

          // Overlay mờ đen
          Container(
            color: Colors.black.withOpacity(0.6),
          ),

          // Nội dung chính
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo App với animation
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _shakeController,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: const Icon(
                        Icons.sports_soccer,
                        size: 100,
                        color: Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'FOOTBALL LIVESCORE',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Cập nhật tin tức & Tỉ số nhanh nhất',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                    const SizedBox(height: 60),

                    // Nút Bấm Đăng nhập với shake animation
                    AnimatedBuilder(
                      animation: _shakeController,
                      builder: (context, child) {
                        final double value = _shakeController.value;
                        final double offset = math.sin(value * math.pi * 4) * 10; // Shake distance
                        return Transform.translate(
                          offset: Offset(offset, 0),
                          child: child,
                        );
                      },
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.greenAccent)
                          : ElevatedButton(
                              onPressed: _googleSignIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 8,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child:
                                        CustomPaint(painter: _GoogleLogoPainter()),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Đăng nhập bằng Google',
                                    style: TextStyle(
                                      color: Colors.black,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Vẽ logo chữ G của Google bằng màu chuẩn, không cần kết nối internet
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    final colors = [
      const Color(0xFF4285F4), // xanh dương
      const Color(0xFF34A853), // xanh lá
      const Color(0xFFFBBC05), // vàng
      const Color(0xFFEA4335), // đỏ
    ];

    for (int i = 0; i < 4; i++) {
      final paint = Paint()..color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        (-0.5 + i) * 3.14159,
        3.14159 / 2,
        true,
        paint,
      );
    }

    // Xóa giữa (vòng tròn trắng tạo khoảng rỗng)
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.6,
      Paint()..color = Colors.white,
    );

    // Thanh ngang bên phải (đặc trưng của chữ G)
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - r * 0.15, r, r * 0.3),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
