import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';
import '../models/team_model.dart';
import '../repositories/team_repository.dart';

/// Bottom sheet để chọn đội bóng yêu thích, nhận callback khi chọn xong
class TeamSelectionSheet extends StatefulWidget {
  final void Function(TeamModel team) onTeamSelected;

  const TeamSelectionSheet({super.key, required this.onTeamSelected});

  @override
  State<TeamSelectionSheet> createState() => _TeamSelectionSheetState();
}

class _TeamSelectionSheetState extends State<TeamSelectionSheet> {
  final _teamRepo = TeamRepository();

  @override
  Widget build(BuildContext context) {
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
          child: FutureBuilder<List<TeamModel>>(
            future: _teamRepo.getUniqueTeams(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.greenAccent),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Lỗi tải dữ liệu: ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'Chưa có dữ liệu Bảng xếp hạng',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              // Đã sort A-Z từ repository
              final teams = snapshot.data!;

              return ListView.builder(
                itemCount: teams.length,
                itemBuilder: (context, index) {
                  final team = teams[index];
                  return ListTile(
                    leading: team.teamLogo.isNotEmpty
                        ? Image.network(
                            team.teamLogo,
                            width: 35,
                            height: 35,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.sports_soccer,
                              color: Colors.greenAccent,
                            ),
                          )
                        : const Icon(
                            Icons.sports_soccer,
                            color: Colors.greenAccent,
                          ),
                    title: Text(
                      team.teamName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onTeamSelected(team);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Profile screen — chỉ chứa UI và điều phối logic qua Supabase auth
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;

  Future<void> _signOut() async {
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: AppConstants.googleServerClientId,
      );
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect();
      }
      await _supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      debugPrint('Lỗi đăng xuất: $e');
    }
  }

  Future<void> _updateFavoriteTeam(TeamModel team) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'favorite_team_id': team.teamId,
            'favorite_team': team.teamName,
            'favorite_team_logo': team.teamLogo,
          },
        ),
      );
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Đã thiết lập ${team.teamName} làm đội bóng yêu thích!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi cập nhật: $e')),
        );
      }
    }
  }

  void _showTeamSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TeamSelectionSheet(
        onTeamSelected: _updateFavoriteTeam,
      ),
    );
  }

  Widget _buildVipBadge(Map<String, dynamic>? subscription) {
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
    String planName;
    Color planColor;

    switch (planCode) {
      case 'SUPER_PRO':
        planName = '👑 Super Pro Member';
        planColor = Colors.amber;
      case 'NHA_PRO':
        planName = '⭐ NHA Pro Member';
        planColor = Colors.purpleAccent;
      case 'LALIGA_PRO':
        planName = '⭐ Laliga Pro Member';
        planColor = Colors.redAccent;
      case 'BUNDESLIGA_PRO':
        planName = '⭐ Bundesliga Pro Member';
        planColor = Colors.orangeAccent;
      case 'SERIA_PRO':
        planName = '⭐ Serie A Pro Member';
        planColor = Colors.blueAccent;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: planColor.withValues(alpha: 0.15),
        border: Border.all(color: planColor, width: 1.5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: planColor.withValues(alpha: 0.3), blurRadius: 10),
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
    final user = _supabase.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'Fan Bóng Đá';
    final userEmail = user?.email ?? 'Chưa cập nhật email';
    final avatarUrl = user?.userMetadata?['avatar_url'] ?? '';
    final favoriteTeam =
        user?.userMetadata?['favorite_team'] ?? 'Chưa chọn (Bấm để chọn)';
    final favoriteTeamLogo =
        user?.userMetadata?['favorite_team_logo'] ?? '';

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
            // Avatar
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[800],
                backgroundImage:
                    avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
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

            // Nâng cấp Premium
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFF39C12)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orangeAccent.withValues(alpha: 0.3),
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
                    final bool? isPurchased = await Navigator.pushNamed(
                      context,
                      '/premium',
                    ) as bool?;
                    if (isPurchased == true && mounted) setState(() {});
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),

            // Đội bóng yêu thích
            ListTile(
              leading: favoriteTeamLogo.isNotEmpty
                  ? Image.network(
                      favoriteTeamLogo,
                      width: 40,
                      height: 40,
                      errorBuilder: (_, _, _) => const Icon(
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
                favoriteTeam,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(Icons.edit, color: Colors.white54, size: 20),
              onTap: _showTeamSelection,
            ),
            const Divider(color: Colors.white24),

            // Lịch sử bình luận
            ListTile(
              leading: const SizedBox(
                width: 40,
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
              onTap: () => Navigator.pushNamed(context, '/commented-news'),
            ),
            const Divider(color: Colors.white24),

            // Đăng xuất
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
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
