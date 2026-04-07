import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart' as g_auth;
import 'main_screen.dart'; // Nơi chứa thanh Bottom Navigation Bar của bạn

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  // HÀM XỬ LÝ ĐĂNG NHẬP GOOGLE
  // HÀM XỬ LÝ ĐĂNG NHẬP GOOGLE (Đã sửa lỗi treo máy)
  Future<void> _googleSignIn() async {
    setState(() => _isLoading = true);
    final g_auth.GoogleSignIn api = g_auth.GoogleSignIn(
      serverClientId:
          '485933277797-j5bgvt32ia25gt8d9ucv6f173b8tc3lb.apps.googleusercontent.com',
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
          const SnackBar(content: Text('🎉 Đăng nhập thành công!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Lỗi: $error')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo App
              const Icon(
                Icons.sports_soccer,
                size: 100,
                color: Colors.greenAccent,
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

              // Nút Bấm Đăng nhập
              _isLoading
                  ? const CircularProgressIndicator(color: Colors.greenAccent)
                  : ElevatedButton(
                      onPressed: _googleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CustomPaint(painter: _GoogleLogoPainter()),
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
            ],
          ),
        ),
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
