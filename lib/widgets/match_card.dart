import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match_model.dart';
import '../screens/live_player_screen.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;

  const MatchCard({super.key, required this.match});
  String _getLeagueName(String code) {
    switch (code) {
      case 'PL':
        return 'Ngoại hạng Anh (Premier League)';
      case 'PD':
        return 'Tây Ban Nha (La Liga)';
      case 'SA':
        return 'Italia (Serie A)';
      case 'BL1':
        return 'Đức (Bundesliga)';
      case 'FL1':
        return 'Pháp (Ligue 1)';
      case 'BSA':
        return 'VĐQG Brazil (Série A)';
      case 'CL':
        return 'UEFA Champions League';
      case 'EL':
        return 'UEFA Europa League';
      case 'WC':
        return 'FIFA World Cup';
      default:
        return code.isNotEmpty ? code : 'Giao hữu';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Chuyển đổi giờ UTC sang giờ Việt Nam
    final localTime = match.startedAt.toLocal();
    final timeString = DateFormat('HH:mm - dd/MM').format(localTime);

    // Kiểm tra xem trận đấu đang đá hay đã xong để tô màu
    final isLive = match.status == 'IN_PLAY' || match.status == 'PAUSED';
    final statusColor = isLive ? Colors.greenAccent : Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: const Color(0xFF1E1E1E), // Màu xám đen sang trọng
      // BƯỚC 1: Bọc nội dung bằng InkWell để bắt sự kiện click và tạo hiệu ứng gợn sóng
      child: InkWell(
        borderRadius: BorderRadius.circular(
          20,
        ), // Bo góc hiệu ứng gợn sóng khớp với thẻ
        onTap: () {
          // BƯỚC 2: Chuyển hướng sang màn hình LivePlayerScreen và truyền dữ liệu trận đấu
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LivePlayerScreen(match: match),
            ),
          );
        },
        // BƯỚC 3: Đẩy khối Padding cũ của bạn vào làm child của InkWell
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Dòng trên cùng: Trạng thái và Thời gian
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      isLive ? 'LIVE' : match.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '${_getLeagueName(match.leagueCode)} • $timeString',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dòng giữa: Tên hai đội, Logo và Tỉ số
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ĐỘI NHÀ (Logo nằm trên tên)
                  Expanded(
                    child: Column(
                      children: [
                        Image.network(
                          match.homeLogo,
                          height: 50,
                          width: 50,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.shield,
                                color: Colors.white54,
                                size: 50,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          match.homeTeam,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // TỈ SỐ Ở GIỮA
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      '${match.homeScore} - ${match.awayScore}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isLive ? Colors.greenAccent : Colors.white,
                      ),
                    ),
                  ),

                  // ĐỘI KHÁCH (Logo nằm trên tên)
                  Expanded(
                    child: Column(
                      children: [
                        Image.network(
                          match.awayLogo,
                          height: 50,
                          width: 50,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.shield,
                                color: Colors.white54,
                                size: 50,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          match.awayTeam,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
