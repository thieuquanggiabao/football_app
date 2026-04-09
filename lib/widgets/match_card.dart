import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../core/notification_service.dart';
import '../models/match_model.dart';
import '../screens/live_player_screen.dart';

class MatchCard extends StatefulWidget {
  final MatchModel match;

  const MatchCard({super.key, required this.match});

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  bool _reminderSet = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Kiểm tra xem trận này đã có báo thức chưa
    _checkReminderStatus();
  }

  Future<void> _checkReminderStatus() async {
    final isSet =
        await NotificationService.isReminderSet(widget.match.apiMatchId);
    if (mounted) setState(() => _reminderSet = isSet);
  }

  Future<void> _toggleReminder() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      if (_reminderSet) {
        // --- HỦY báo thức ---
        await NotificationService.cancelReminder(widget.match.apiMatchId);
        if (mounted) {
          setState(() => _reminderSet = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔕 Đã hủy báo thức trận đấu'),
              backgroundColor: Colors.grey,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // --- ĐẶT báo thức ---
        // Xin quyền trước (Android 13+)
        final hasPermission = await NotificationService.requestPermission();
        if (!hasPermission) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Cần cấp quyền thông báo trong Cài đặt!'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          return;
        }

        final success = await NotificationService.scheduleMatchReminder(
          widget.match,
        );

        if (mounted) {
          if (success) {
            setState(() => _reminderSet = true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '🔔 Sẽ nhắc bạn 5 phút trước trận '
                  '${widget.match.homeTeam} vs ${widget.match.awayTeam}!',
                ),
                backgroundColor: Colors.green.shade700,
                duration: const Duration(seconds: 3),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚠️ Trận sắp bắt đầu rồi, không kịp nhắc!'),
                backgroundColor: Colors.orangeAccent,
              ),
            );
          }
        }
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localTime = widget.match.startedAt.toLocal();
    final timeString = DateFormat('HH:mm - dd/MM').format(localTime);

    final isLive = widget.match.status == 'IN_PLAY' ||
        widget.match.status == 'PAUSED';
    final isTimed = widget.match.status == 'TIMED';
    final statusColor =
        isLive ? Theme.of(context).colorScheme.primary : Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : Colors.grey.shade100,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LivePlayerScreen(match: widget.match),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Dòng trên: Trạng thái và Tên giải + Thời gian
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      isLive ? 'LIVE' : widget.match.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  // Tên giải đấu + thời gian
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          AppConstants.getLeagueName(widget.match.leagueCode),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        timeString,
                        style: TextStyle(
                          color:
                              Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dòng giữa: Đội nhà — Tỉ số — Đội khách
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Đội nhà
                  Expanded(
                    child: Column(
                      children: [
                        Image.network(
                          widget.match.homeLogo,
                          height: 50,
                          width: 50,
                          errorBuilder: (ctx, err, stack) => const Icon(
                            Icons.shield,
                            color: Colors.white54,
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.match.homeTeam,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ) ??
                                  const TextStyle(),
                        ),
                      ],
                    ),
                  ),

                  // Tỉ số
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      '${widget.match.homeScore} - ${widget.match.awayScore}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isLive
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),

                  // Đội khách
                  Expanded(
                    child: Column(
                      children: [
                        Image.network(
                          widget.match.awayLogo,
                          height: 50,
                          width: 50,
                          errorBuilder: (ctx, err, stack) => Icon(
                            Icons.shield,
                            color: Theme.of(context)
                                .iconTheme
                                .color
                                ?.withValues(alpha: 0.6),
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.match.awayTeam,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ) ??
                                  const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Nút "Nhắc tôi" — chỉ hiện với trận TIMED
              if (isTimed) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isProcessing
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : _reminderSet
                            ? // Trạng thái ĐÃ ĐẶT báo thức
                            TextButton.icon(
                                key: const ValueKey('set'),
                                onPressed: _toggleReminder,
                                icon: const Icon(
                                  Icons.notifications_active,
                                  size: 18,
                                  color: Colors.green,
                                ),
                                label: const Text(
                                  'Đã nhắc',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Colors.green.withValues(alpha: 0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: const BorderSide(
                                      color: Colors.green,
                                      width: 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                ),
                              )
                            : // Trạng thái CHƯA đặt báo thức
                            OutlinedButton.icon(
                                key: const ValueKey('unset'),
                                onPressed: _toggleReminder,
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  size: 18,
                                ),
                                label: const Text('Nhắc tôi'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.amber,
                                  side: const BorderSide(
                                    color: Colors.amber,
                                    width: 1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                ),
                              ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
