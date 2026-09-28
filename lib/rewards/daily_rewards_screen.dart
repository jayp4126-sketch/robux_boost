import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_provider.dart';
import '../services/ad_service.dart';
import '../utils/constants.dart';

class DailyRewardsScreen extends StatelessWidget {
  const DailyRewardsScreen({super.key});

  final List<int> _rewards = const [50, 75, 100, 150, 200, 300, 500];
  static final AdService _adService = AdService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Daily Rewards', style: TextStyle(color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          if (user == null) return const Center(child: CircularProgressIndicator());

          final canClaim = userProvider.canClaimDailyReward();
          final currentDay = user.dailyRewardDay;

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Claim your daily reward!',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Current Streak: ${user.streak} days',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final reward = _rewards[index];
                      final isClaimed = currentDay >= day;
                      final isToday = canClaim && currentDay == day - 1;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isClaimed
                              ? AppColors.green.withOpacity(0.2)
                              : (isToday ? AppColors.gold.withOpacity(0.2) : AppColors.cardBackground),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isClaimed
                                ? AppColors.green
                                : (isToday ? AppColors.gold : AppColors.grey.withOpacity(0.3)),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isClaimed
                                    ? AppColors.green
                                    : (isToday ? AppColors.gold : AppColors.grey.withOpacity(0.3)),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  isClaimed ? '✓' : '$day',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Day $day',
                                    style: const TextStyle(
                                      color: AppColors.textDark,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    isClaimed ? 'Claimed' : '$reward coins',
                                    style: TextStyle(
                                      color: isClaimed ? AppColors.green : AppColors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (day == 7)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.gold,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'BONUS',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (canClaim)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      // The label names the ad because tapping this opens one:
                      // AdMob requires a rewarded ad to be opted into knowingly,
                      // and "Claim Reward" alone gave no hint a video was coming.
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final nextDay = currentDay + 1;
                          if (nextDay <= 7) {
                            final reward = _rewards[nextDay - 1];
                            _adService.showRewardedAd(onRewarded: (_) async {
                              await userProvider.claimDailyReward(nextDay, reward);
                              _adService.incrementClaimCounter();
                              if (context.mounted) {
                                _showDoubleRewardDialog(context, userProvider, reward);
                              }
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        icon: const Icon(Icons.play_circle, color: AppColors.white),
                        label: const Text(
                          'Watch Ad to Claim',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppColors.grey),
                      ),
                      child: const Text(
                        'Come back tomorrow!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDoubleRewardDialog(BuildContext context, UserProvider userProvider, int reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Reward Claimed!',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '+$reward coins!',
              style: const TextStyle(color: AppColors.gold, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const Text(
              'Watch a video to double your reward!',
              style: TextStyle(color: AppColors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No Thanks', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _adService.showRewardedAd(onRewarded: (amount) async {
                await userProvider.addCoins(reward, 'Daily Reward x2');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Doubled! Got extra $reward coins!'),
                      backgroundColor: AppColors.green,
                    ),
                  );
                }
              });
            },
            icon: const Icon(Icons.play_circle, color: AppColors.white),
            label: const Text('Watch Ad for 2x', style: TextStyle(color: AppColors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
          ),
        ],
      ),
    );
  }
}
