import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../widgets/game_list_card.dart';
import '../services/ad_service.dart';
import '../services/user_provider.dart';
import '../widgets/native_banner_ad.dart';
import '../games/spin_wheel_game.dart';
import '../games/scratch_card_game.dart';
import '../games/ml_clicker_game.dart';
import 'redeem_flow2_screen.dart';

final AdService _gamesAdService = AdService();

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final user = userProvider.user;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Text(
                    'All Games',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (user != null) _GoldProgressBanner(coins: user.coins),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      const SizedBox(height: 12),
                      GameListCard(
                        icon: Icons.casino,
                        iconColor: AppColors.gold,
                        imagePath: 'assets/icons/1411d29e-e5da-42e8-ae44-43c33f0e5cd5.png',
                        title: 'Spin Wheel',
                        description: 'Win coins with lucky spins!',
                        info: '5 spins daily',
                        onTap: () {
                          _gamesAdService.incrementNavCounter();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SpinWheelGame()),
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                      GameListCard(
                        icon: Icons.style,
                        iconColor: AppColors.purple,
                        imagePath: 'assets/icons/7e5c7323-3457-48f2-8834-648304a759b9.png',
                        title: 'Scratch Cards',
                        description: 'Scratch to reveal prizes!',
                        info: '5 cards daily',
                        onTap: () {
                          _gamesAdService.incrementNavCounter();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ScratchCardGame()),
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                      GameListCard(
                        icon: Icons.touch_app,
                        iconColor: AppColors.cyan,
                        imagePath: 'assets/icons/5cb75839-75bf-439b-9859-9dd22e2e379d.png',
                        title: '${AppStrings.currency} Clicker',
                        description: 'Click to earn coins',
                        info: 'Unlimited plays',
                        onTap: () {
                          _gamesAdService.incrementNavCounter();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MLClickerGame()),
                          );
                        },
                      ),
                      const SizedBox(height: 15),
                      const NativeBannerAd(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Gold glowing progress banner ────────────────────────────────────────────

class _GoldProgressBanner extends StatelessWidget {
  const _GoldProgressBanner({required this.coins});
  final int coins;

  @override
  Widget build(BuildContext context) {
    final target = AppConstants.targetCoins2;
    final reached = coins >= target;
    final progress = (coins / target).clamp(0.0, 1.0);
    final remaining = (target - coins).clamp(0, target);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: reached ? const Color(0xFFEAFBF3) : const Color(0xFFFFF7E6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: reached ? AppColors.green : AppColors.gold,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (reached ? AppColors.green : AppColors.gold).withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: AppColors.gold, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reached
                        ? 'Goal reached! Claim your 12,000 ${AppStrings.currency}!'
                        : 'Reach $target coins → Get 12,000 ${AppStrings.currency}!',
                    style: TextStyle(
                      color: reached ? AppColors.green : AppColors.gold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearPercentIndicator(
              padding: EdgeInsets.zero,
              lineHeight: 22,
              percent: progress,
              backgroundColor: const Color(0xFFE8EAFF),
              progressColor: reached ? AppColors.green : AppColors.gold,
              barRadius: const Radius.circular(11),
              center: Text(
                '$coins / $target',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (!reached) ...[
              const SizedBox(height: 8),
              Text(
                '$remaining more coins to go!',
                style: TextStyle(
                  color: AppColors.gold.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
            if (reached) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RedeemFlow2Screen()),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.green.withOpacity(0.45),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Redeem Now',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
