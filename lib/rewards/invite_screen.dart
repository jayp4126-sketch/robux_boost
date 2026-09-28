import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/user_provider.dart';
import '../utils/constants.dart';

class InviteScreen extends StatelessWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Invite Friends', style: TextStyle(color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          if (user == null) return const Center(child: CircularProgressIndicator());

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Invite Friends & Earn!',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Get 20% of all the ${AppStrings.currency} your friends earn — forever!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 40),
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
                            'Your Invite Code',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              user.inviteCode,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: user.inviteCode));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Code copied to clipboard!'),
                                        backgroundColor: AppColors.green,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.copy, color: AppColors.white),
                                  label: const Text(
                                    'Copy Code',
                                    style: TextStyle(color: AppColors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.gold,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Share.share(
                                      'Join ${AppStrings.currency} and use my code ${user.inviteCode} to get 100 bonus coins! Download now!',
                                    );
                                  },
                                  icon: const Icon(Icons.share, color: AppColors.white),
                                  label: const Text(
                                    'Share',
                                    style: TextStyle(color: AppColors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.green,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'How it works',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildStepCard(
                      '1',
                      'Share Your Code',
                      'Send your invite code to friends',
                      Icons.share,
                    ),
                    const SizedBox(height: 15),
                    _buildStepCard(
                      '2',
                      'Friend Joins',
                      'They enter your code when signing up',
                      Icons.person_add,
                    ),
                    const SizedBox(height: 15),
                    _buildStepCard(
                      '3',
                      'Get Rewards',
                      'You get 200 coins + 20% of every ${AppStrings.currency} they earn!',
                      Icons.card_giftcard,
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Bonus Milestones',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildMilestoneCard('5 Friends', '500 Bonus Coins', AppColors.blue),
                    const SizedBox(height: 15),
                    _buildMilestoneCard('10 Friends', '1,000 Bonus Coins', AppColors.purple),
                    const SizedBox(height: 15),
                    _buildMilestoneCard('25 Friends', '3,000 Bonus Coins', AppColors.gold),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepCard(String number, String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.purple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: AppColors.purple, size: 30),
            ),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
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
    );
  }

  Widget _buildMilestoneCard(String milestone, String reward, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.emoji_events, color: color, size: 30),
              ),
              const SizedBox(width: 15),
              Text(
                milestone,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            reward,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
