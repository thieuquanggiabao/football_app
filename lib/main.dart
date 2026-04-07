import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  // Bắt buộc phải có dòng này trước khi khởi tạo các dịch vụ bên ngoài
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo kết nối Supabase
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
    return MaterialApp(
      title: 'Live Football Results',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // File HomeScreen hiện tại đang trống nên sẽ báo lỗi gạch chân đỏ nhẹ,
      // chúng ta sẽ viết code cho nó ngay sau đây.
      // TẠO CỔNG KIỂM TRA ĐĂNG NHẬP Ở ĐÂY:
      home: Supabase.instance.client.auth.currentSession == null
          ? const LoginScreen() // Chưa đăng nhập -> Hiện Login
          : const MainScreen(), // Đã có phiên đăng nhập -> Vào thẳng app
    );
  }
}
