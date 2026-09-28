import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_provider.dart';
import '../services/ad_service.dart';
import '../utils/constants.dart';

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  static final AdService _adService = AdService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Coin Vault', style: TextStyle(color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          if (user == null) return const Center(child: CircularProgressIndicator());

          final coinsEarned = userProvider.getVaultCoinsEarned();
          final coinsPerHour = user.vaultLevel * 5;
          final maxCoins = user.vaultLevel * 100;

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Passive Income Generator',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.purple.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Coins Available',
                            style: TextStyle(color: AppColors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 15),
                          const Icon(Icons.savings, color: AppColors.gold, size: 60),
                          const SizedBox(height: 15),
                          Text(
                            '$coinsEarned',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: coinsEarned > 0
                                  ? () async {
                                      await userProvider.collectVault();
                                      _adService.incrementClaimCounter();
                                      if (context.mounted) {
                                        _showDoubleCollectDialog(context, userProvider, coinsEarned);
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                'Collect Coins',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Current Level',
                                style: TextStyle(color: AppColors.grey, fontSize: 16),
                              ),
                              Text(
                                'Level ${user.vaultLevel}',
                                style: const TextStyle(
                                  color: AppColors.purple,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: AppColors.grey, height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Coins per Hour',
                                style: TextStyle(color: AppColors.grey, fontSize: 16),
                              ),
                              Text(
                                '$coinsPerHour',
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: AppColors.grey, height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Max Capacity',
                                style: TextStyle(color: AppColors.grey, fontSize: 16),
                              ),
                              Text(
                                '$maxCoins',
                                style: const TextStyle(
                                  color: AppColors.green,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Upgrade Vault',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ...List.generate(5, (index) {
                      final level = index + 1;
                      final isCurrentLevel = user.vaultLevel == level;
                      final isUnlocked = user.vaultLevel >= level;
                      final upgradeCosts = [0, 500, 1000, 2000, 5000];
                      final cost = upgradeCosts[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? AppColors.green.withOpacity(0.2)
                              : AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isCurrentLevel
                                ? AppColors.purple
                                : (isUnlocked ? AppColors.green : AppColors.grey.withOpacity(0.3)),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isUnlocked ? AppColors.green : AppColors.grey.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  isUnlocked ? '✓' : '$level',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Level $level',
                                    style: const TextStyle(
                                      color: AppColors.textDark,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${level * 5} coins/hour • Max ${level * 100}',
                                    style: const TextStyle(color: AppColors.grey, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            if (!isUnlocked && level == user.vaultLevel + 1)
                              ElevatedButton(
                                onPressed: user.coins >= cost
                                    ? () async {
                                        await userProvider.upgradeVault();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Vault upgraded!'),
                                              backgroundColor: AppColors.green,
                                            ),
                                          );
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.purple,
                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                ),
                                child: Text(
                                  '$cost pts',
                                  style: const TextStyle(color: AppColors.white, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDoubleCollectDialog(BuildContext context, UserProvider userProvider, int coinsEarned) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Coins Collected!',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '+$coinsEarned coins!',
              style: const TextStyle(color: AppColors.gold, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const Text(
              'Watch a video to double your collection!',
              style: TextStyle(color: AppColors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _adService.showRewardedAd(onRewarded: (amount) async {
                await userProvider.addCoins(coinsEarned, 'Vault x2');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Doubled! Got extra $coinsEarned coins!'),
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
