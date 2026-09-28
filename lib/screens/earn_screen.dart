import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../widgets/earn_task_card.dart';
import '../services/ad_service.dart';
import '../services/user_provider.dart';
import '../rewards/video_dashboard_screen.dart';
import '../rewards/daily_rewards_screen.dart';
import '../rewards/trivia_screen.dart';
import '../rewards/treasure_chest_screen.dart';
import '../rewards/vault_screen.dart';
import '../rewards/invite_screen.dart';
import '../widgets/native_banner_ad.dart';

class EarnScreen extends StatelessWidget {
  const EarnScreen({super.key});
  
  static final AdService _adService = AdService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Earn More Coins',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  EarnTaskCard(
                    icon: Icons.play_circle,
                    iconColor: AppColors.blue,
                    imagePath: 'assets/icons/54d5caba-8650-40f4-a083-7aca7ee39d7a.png',
                    title: 'Watch Video',
                    description: 'Earn 25-50 coins',
                    buttonText: 'Watch Now →',
                    onTap: () {
                      _adService.showRewardedAd(onRewarded: (_) async {
                        final random = Random();
                        final coins = random.nextInt(26) + 25; // 25-50 coins
                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                        await userProvider.addCoins(coins, 'Watch Video');
                        _adService.incrementClaimCounter();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('You earned $coins coins!'),
                              backgroundColor: AppColors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  EarnTaskCard(
                    icon: Icons.today,
                    iconColor: AppColors.pink,
                    imagePath: 'assets/icons/031a67ac-2420-4c52-acd1-dbd7981f5efe.png',
                    title: 'Daily Rewards',
                    description: 'Claim your daily bonus',
                    buttonText: 'Claim →',
                    onTap: () {
                      _adService.incrementNavCounter();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DailyRewardsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  EarnTaskCard(
                    icon: Icons.gps_fixed,
                    iconColor: AppColors.cyan,
                    imagePath: 'assets/icons/bae772a4-8096-4136-afbd-2d11432855c4.png',
                    title: 'Complete Trivia',
                    description: 'Answer questions for coins',
                    buttonText: 'Play →',
                    onTap: () {
                      _adService.incrementNavCounter();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TriviaScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  const NativeBannerAd(),
                  const SizedBox(height: 10),
                  EarnTaskCard(
                    icon: Icons.inventory_2,
                    iconColor: AppColors.purple,
                    title: 'Treasure Chest',
                    description: 'Open every 3 hours',
                    buttonText: 'Open →',
                    onTap: () {
                      _adService.incrementNavCounter();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TreasureChestScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  EarnTaskCard(
                    icon: Icons.account_balance,
                    iconColor: AppColors.gold,
                    title: 'Coin Vault',
                    description: 'Passive income generator',
                    buttonText: 'Collect →',
                    onTap: () {
                      _adService.incrementNavCounter();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const VaultScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  EarnTaskCard(
                    icon: Icons.group,
                    iconColor: AppColors.green,
                    title: 'Invite Friends',
                    description: 'Get bonus for referrals',
                    buttonText: 'Invite →',
                    onTap: () {
                      _adService.incrementNavCounter();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const InviteScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
