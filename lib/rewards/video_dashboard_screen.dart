import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_provider.dart';
import '../utils/constants.dart';

class VideoDashboardScreen extends StatelessWidget {
  const VideoDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Video Dashboard', style: TextStyle(color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Watch videos and earn coins!',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            _buildVideoCard(
              context,
              'Quick Earn',
              '30 seconds',
              '50 coins',
              '5 min cooldown',
              AppColors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(
    BuildContext context,
    String title,
    String duration,
    String reward,
    String cooldown,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.play_circle_filled, color: color, size: 40),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      duration,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reward',
                    style: TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                  Text(
                    reward,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Cooldown',
                    style: TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                  Text(
                    cooldown,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _watchVideo(context, reward);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Watch Now',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _watchVideo(BuildContext context, String reward) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.purple),
            const SizedBox(height: 20),
            const Text(
              'Loading video...',
              style: TextStyle(color: AppColors.textDark),
            ),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;
    Navigator.pop(context);

    final coins = int.parse(reward.split(' ')[0]);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.addCoins(coins, 'Video Watch');
    await userProvider.incrementAdsWatched();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Earned $coins coins!'),
        backgroundColor: AppColors.green,
      ),
    );
  }
}
