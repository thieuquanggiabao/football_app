import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'commented_news_screen.dart';
import 'premium_plan_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;

  // Hàm xử lý Đăng xuất 2 lớp
  Future<void> _signOut() async {
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId:
            '485933277797-j5bgvt32ia25gt8d9ucv6f173b8tc3lb.apps.googleusercontent.com',
      );

      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect();
      }
      await _supabase.auth.signOut();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Lỗi đăng xuất: $e');
    }
  }

  // ==========================================
  // HÀM 1: CẬP NHẬT ĐỘI BÓNG YÊU THÍCH (LƯU ID KIỂU INT)
  // ==========================================
  Future<void> _updateFavoriteTeam(
    int teamId,
    String teamName,
    String teamLogo,
  ) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'favorite_team_id': teamId, // Lưu ID dưới dạng số nguyên (int4)
            'favorite_team': teamName, // Lưu tên để hiển thị nhanh
            'favorite_team_logo': teamLogo, // Lưu logo để vẽ UI ngay lập tức
          },
        ),
      );

      if (mounted) {
        setState(() {}); // Ép tải lại màn hình Profile để cập nhật giao diện
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Đã thiết lập $teamName làm đội bóng yêu thích!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Lỗi cập nhật: $e')));
      }
    }
  }

  // ==========================================
  // HÀM 2: HIỂN THỊ DANH SÁCH CHỌN ĐỘI BÓNG (TỪ BẢNG STANDINGS)
  // ==========================================
  void _showTeamSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Chọn đội bóng ruột của bạn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                // Truy vấn 3 trường cần thiết từ bảng standings
                future: _supabase
                    .from('standings')
                    .select('team_id, team_name, team_logo'),
                builder: (context, snapshot) {
                  // Xử lý trạng thái tải
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.greenAccent,
                      ),
                    );
                  }
                  // Xử lý lỗi kết nối
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Lỗi tải dữ liệu: ${snapshot.error}',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    );
                  }
                  // Xử lý dữ liệu rỗng
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Chưa có dữ liệu Bảng xếp hạng',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  // Lọc đội bóng trùng lặp: Nhóm theo Tên Đội
                  final Map<String, Map<String, dynamic>> uniqueTeams = {};

                  for (var row in snapshot.data!) {
                    final int? id = row['team_id'] as int?;
                    final String? name = row['team_name']?.toString();
                    final String logo = row['team_logo']?.toString() ?? '';

                    // Chỉ thêm vào danh sách nếu có ID và Tên hợp lệ
                    if (name != null && name.isNotEmpty && id != null) {
                      uniqueTeams[name] = {'id': id, 'logo': logo};
                    }
                  }

                  // Trích xuất danh sách tên đội và sắp xếp theo thứ tự A-Z
                  final List<String> teamNamesList = uniqueTeams.keys.toList()
                    ..sort();

                  // Vẽ danh sách lên màn hình
                  return ListView.builder(
                    itemCount: teamNamesList.length,
                    itemBuilder: (context, index) {
                      final teamName = teamNamesList[index];
                      // Ép kiểu chuẩn xác khi lấy dữ liệu từ Map ra
                      final int teamId = uniqueTeams[teamName]!['id'] as int;
                      final String teamLogo =
                          uniqueTeams[teamName]!['logo'] as String;

                      return ListTile(
                        leading: teamLogo.isNotEmpty
                            ? Image.network(
                                teamLogo,
                                width: 35,
                                height: 35,
                                errorBuilder: (c, e, s) => const Icon(
                                  Icons.sports_soccer,
                                  color: Colors.greenAccent,
                                ),
                              )
                            : const Icon(
                                Icons.sports_soccer,
                                color: Colors.greenAccent,
                              ),
                        title: Text(
                          teamName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () async {
                          Navigator.pop(context); // Đóng bảng chọn
                          // Kích hoạt hàm lưu với đầy đủ 3 tham số chuẩn xác
                          await _updateFavoriteTeam(teamId, teamName, teamLogo);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // HÀM 3: TẠO HUY HIỆU VIP DỰA TRÊN GÓI CƯỚC
  // ==========================================
  Widget _buildVipBadge(Map<String, dynamic>? subscription) {
    // Nếu chưa mua gói nào -> Hiển thị mác Tiêu chuẩn
    if (subscription == null ||
        subscription.isEmpty ||
        subscription['plan_code'] == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Thành viên Tiêu chuẩn',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      );
    }

    final planCode = subscription['plan_code'];
    String planName = '';
    Color planColor = Colors.amber;

    // Phân loại màu sắc và tên tùy theo gói
    switch (planCode) {
      case 'SUPER_PRO':
        planName = '👑 Super Pro Member';
        planColor = Colors.amber;
        break;
      case 'NHA_PRO':
        planName = '⭐ NHA Pro Member';
        planColor = Colors.purpleAccent;
        break;
      case 'LALIGA_PRO':
        planName = '⭐ Laliga Pro Member';
        planColor = Colors.redAccent;
        break;
      case 'BUNDESLIGA_PRO':
        planName = '⭐ Budesliga Pro Member';
        planColor = Colors.orangeAccent;
        break;
      case 'SERIA_PRO':
        planName = '⭐ SeriA Pro Member';
        planColor = Colors.blueAccent;
        break;
      default:
        return const SizedBox.shrink();
    }

    // Vẽ cái khung VIP phát sáng
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: planColor.withOpacity(0.15),
        border: Border.all(color: planColor, width: 1.5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: planColor.withOpacity(0.3), blurRadius: 10),
        ],
      ),
      child: Text(
        planName,
        style: TextStyle(
          color: planColor,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin người dùng hiện tại từ Supabase
    final user = _supabase.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'Fan Bóng Đá';
    final userEmail = user?.email ?? 'Chưa cập nhật email';
    final avatarUrl = user?.userMetadata?['avatar_url'] ?? '';

    // [MỚI THÊM] Lấy Tên và Logo đội bóng từ Metadata
    final favoriteTeam =
        user?.userMetadata?['favorite_team'] ?? 'Chưa chọn (Bấm để chọn)';
    final favoriteTeamLogo = user?.userMetadata?['favorite_team_logo'] ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Tài khoản',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.greenAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- KHU VỰC 1: THÔNG TIN CÁ NHÂN ---
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[800],
                backgroundImage: avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl.isEmpty
                    ? const Icon(Icons.person, size: 50, color: Colors.white54)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userEmail,
              style: const TextStyle(fontSize: 14, color: Colors.white54),
            ),
            const SizedBox(height: 12),
            _buildVipBadge(
              user?.userMetadata?['subscription'] as Map<String, dynamic>?,
            ),
            const SizedBox(height: 30),
            const Divider(color: Colors.white24),
            // ==========================================
            // KHU VỰC VIP: NÂNG CẤP PREMIUM
            // ==========================================
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFD700),
                      Color(0xFFF39C12),
                    ], // Màu Vàng Gold
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orangeAccent.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: const Icon(
                    Icons.workspace_premium,
                    color: Colors.black87,
                    size: 36,
                  ),
                  title: const Text(
                    'Nâng cấp Premium',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: const Text(
                    'Xem trực tiếp mọi giải đấu đỉnh cao',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black12,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                  onTap: () async {
                    // Chuyển sang màn hình Mua gói và đợi kết quả
                    final bool? isPurchased = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PremiumPlanScreen(),
                      ),
                    );

                    // Nếu người dùng mua thành công, tải lại trang Profile để cập nhật dữ liệu
                    if (isPurchased == true && mounted) {
                      setState(() {});
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            // --- KHU VỰC 2: CÁ NHÂN HÓA ---
            ListTile(
              // [MỚI THÊM] Giao diện tự động đổi Khuyên thành Logo đội bóng
              leading: favoriteTeamLogo.isNotEmpty
                  ? Image.network(
                      favoriteTeamLogo,
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.shield,
                        color: Colors.greenAccent,
                        size: 40,
                      ),
                    )
                  : const Icon(
                      Icons.shield,
                      color: Colors.greenAccent,
                      size: 40,
                    ),
              title: const Text(
                'Đội bóng yêu thích',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                favoriteTeam, // [MỚI THÊM] Hiện tên đội bóng
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(
                Icons
                    .edit, // [MỚI THÊM] Đổi icon mũi tên thành cây bút cho trực quan
                color: Colors.white54,
                size: 20,
              ),
              onTap: _showTeamSelection, // [MỚI THÊM] Gọi hàm mở bảng chọn
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const SizedBox(
                width:
                    40, // Ép khung 40 để thẳng hàng thẳng lối với cái Logo ở trên
                height: 40,
                child: Icon(
                  Icons.comment_outlined,
                  color: Colors.greenAccent,
                  size: 28,
                ),
              ),
              title: const Text(
                'Lịch sử bình luận',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Xem các bài báo đã tương tác',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 16,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CommentedNewsScreen(),
                  ),
                );
              },
            ),
            const Divider(color: Colors.white24),

            // --- KHU VỰC 3: HÀNH ĐỘNG ---
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _signOut,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
