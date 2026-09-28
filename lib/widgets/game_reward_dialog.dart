import 'package:flutter/material.dart';
import '../services/ad_service.dart';
import '../utils/constants.dart';

/// Green luck-style reward sheet: coin amount, [2x REWARD] (rewarded ad), [COLLECT].
Future<void> showGameRewardDialog(
  BuildContext context, {
  required int coins,
  required AdService adService,
  required Future<void> Function() onCollect,
  required Future<void> Function() onDoubledCollect,
  List<String> infoLines = const [],
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: const Color(0x990F0F1E),
    builder: (dialogContext) => _GameRewardDialog(
      coins: coins,
      adService: adService,
      onCollect: onCollect,
      onDoubledCollect: onDoubledCollect,
      infoLines: infoLines,
    ),
  );
}

class _GameRewardDialog extends StatefulWidget {
  const _GameRewardDialog({
    required this.coins,
    required this.adService,
    required this.onCollect,
    required this.onDoubledCollect,
    required this.infoLines,
  });

  final int coins;
  final AdService adService;
  final Future<void> Function() onCollect;
  final Future<void> Function() onDoubledCollect;
  final List<String> infoLines;

  @override
  State<_GameRewardDialog> createState() => _GameRewardDialogState();
}

class _GameRewardDialogState extends State<_GameRewardDialog> {
  static const Color _panelGreen = Color(0xFF5FD35E);
  static const Color _buttonOverlay = Color(0x40FFFFFF);

  Future<void> _handleCollect() async {
    widget.adService.incrementClaimCounter();
    Navigator.of(context).pop();
    await widget.onCollect();
  }

  void _handleDoubleReward() {
    widget.adService.showRewardedAd(
      onRewarded: (_) async {
        if (!mounted) return;
        Navigator.of(context).pop();
        await widget.onDoubledCollect();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        decoration: BoxDecoration(
          color: _panelGreen,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.casino, color: AppColors.green, size: 44),
            if (widget.infoLines.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...widget.infoLines.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    line,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text(
              '+${widget.coins}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 46,
                fontWeight: FontWeight.bold,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'COINS',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.98),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: Material(
                color: _buttonOverlay,
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _handleDoubleReward,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_filled, color: Colors.white, size: 28),
                        SizedBox(width: 10),
                        Text(
                          'WATCH AD FOR 2x',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: _handleCollect,
              child: const Text(
                'COLLECT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
