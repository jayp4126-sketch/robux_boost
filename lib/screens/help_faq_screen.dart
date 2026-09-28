import 'package:flutter/material.dart';
import '../utils/constants.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Help & FAQ', style: TextStyle(color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildCategory('Games'),
            _buildFaqItem(
              'How do I play games?',
              'Go to the Games tab and select any game. Each game has different rules and rewards. Some games have daily limits while others are unlimited.',
            ),
            _buildFaqItem(
              'How many spins do I get daily?',
              'You get 5 free spins per day on the Spin Wheel. You can watch a rewarded video to get 5 extra spins when you run out.',
            ),
            _buildFaqItem(
              'How does Tile Match scoring work?',
              'Each matched tile gives you 5 points. You have 20 moves per game. Your final coins earned = total points / 10.',
            ),
            const SizedBox(height: 20),
            _buildCategory('Coins'),
            _buildFaqItem(
              'How do I earn coins?',
              'You can earn coins by playing games, watching videos, claiming daily rewards, opening treasure chests, collecting from the vault, completing trivia, and inviting friends.',
            ),
            _buildFaqItem(
              'What are the rank levels?',
              'Beginner (0-499), Bronze (500-1,999), Silver (2,000-4,999), Gold (5,000-9,999), Diamond (10,000+).',
            ),
            _buildFaqItem(
              'How does the Coin Vault work?',
              'The vault generates coins passively every hour. You can upgrade it to earn more coins per hour and increase the maximum capacity.',
            ),
            const SizedBox(height: 20),
            _buildCategory('Ads & Videos'),
            _buildFaqItem(
              'Why do I need to watch ads?',
              'Watching ads helps support the app and keeps it free. In return, you earn coins for watching rewarded videos.',
            ),
            _buildFaqItem(
              'What are the video reward tiers?',
              'Quick Earn (30s): 50 coins, Bonus Reward (60s): 100 coins, Mega Bonus (90s): 200 coins. Each has a cooldown period.',
            ),
            const SizedBox(height: 20),
            _buildCategory('Redeem'),
            _buildFaqItem(
              'How do I redeem my coins?',
              'Go to the Wallet tab and tap Redeem. Select a reward, confirm, and your reward will be delivered within 5-15 business days.',
            ),
            _buildFaqItem(
              'What rewards are available?',
              'Gift cards, digital codes, and other prizes. The available rewards and their costs may change periodically.',
            ),
            const SizedBox(height: 20),
            _buildCategory('Account'),
            _buildFaqItem(
              'How do I invite friends?',
              'Go to Earn > Invite Friends. Share your unique invite code. When a friend uses it, you get 200 coins and they get 100 coins.',
            ),
            _buildFaqItem(
              'What happens if I miss a day?',
              'Your daily streak resets to 0 and your daily rewards start over from Day 1. Try to log in every day!',
            ),
            _buildFaqItem(
              'Can I delete my account?',
              'Yes, go to Profile > Settings > Delete Account. Warning: this permanently deletes all your data.',
            ),
            const SizedBox(height: 20),
            _buildCategory('Technical'),
            _buildFaqItem(
              'My data is not saving. What should I do?',
              'Make sure you have enough storage on your device. The app saves data locally using SharedPreferences.',
            ),
            _buildFaqItem(
              'Ads are not loading. What can I do?',
              'Check your internet connection. If ads still don\'t load, try restarting the app.',
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.purple),
              ),
              child: const Column(
                children: [
                  Icon(Icons.email_outlined, color: AppColors.purple, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'Still need help?',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Contact us at support@mlapp.com',
                    style: TextStyle(color: AppColors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.purple,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
        iconColor: AppColors.purple,
        collapsedIconColor: AppColors.grey,
        title: Text(
          question,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Text(
            answer,
            style: const TextStyle(color: AppColors.grey, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}
