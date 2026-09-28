import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/user_provider.dart';
import '../utils/constants.dart';
import '../rewards/invite_screen.dart';
import 'settings_screen.dart';
import 'leaderboard_screen.dart';
import 'help_faq_screen.dart';
import 'privacy_policy_screen.dart';
import '../widgets/robux_icon.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final user = userProvider.user;
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileHeader(context, user),
                  const SizedBox(height: 30),
                  _RobloxUsernameCard(user: user),
                  const SizedBox(height: 20),
                  const _InviteFriendsCard(),
                  const SizedBox(height: 30),
                  _buildStatistics(user),
                  const SizedBox(height: 30),
                  _buildAchievements(user),
                  const SizedBox(height: 30),
                  _buildSettings(context),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: AppColors.purpleGlow,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: AppColors.purple.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 6)),
              ],
            ),
            child: const Center(
              child: Icon(Icons.person, color: Colors.white, size: 50),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            user.username,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold, width: 2),
            ),
            child: Text(
              '${user.getRank()} Rank',
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: user.inviteCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invite code copied!')),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.purple),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Invite Code: ${user.inviteCode}',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.copy, color: AppColors.purple, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _editRobloxUsername(BuildContext context, UserModel user) async {
    final controller = TextEditingController(text: user.robloxUsername);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Your Roblox Username',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We need this to deliver your ${AppStrings.currency}. Make sure it matches your Roblox account exactly.',
              style: TextStyle(color: AppColors.textMid, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'e.g. BuilderMan',
                hintStyle: const TextStyle(color: AppColors.grey),
                filled: true,
                fillColor: AppColors.pillBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (v) => Navigator.pop(ctx, v),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text(
              'Save',
              style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (name == null || !context.mounted) return;
    await context.read<UserProvider>().setRobloxUsername(name);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Roblox username saved!')),
    );
  }

  Widget _buildStatistics(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistics',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildStatRow(Icons.monetization_on,        AppColors.gold,   'Total Coins', '${user.coins}'),
                const Divider(color: AppColors.grey, height: 30),
                _buildStatRow(Icons.local_fire_department, AppColors.activityOrange, 'Streak', '${user.streak} days'),
                const Divider(color: AppColors.grey, height: 30),
                _buildStatRow(Icons.sports_esports,        AppColors.purple, 'Games Played', '${user.gamesPlayed}'),
                const Divider(color: AppColors.grey, height: 30),
                _buildStatRow(Icons.play_circle,           AppColors.blue,   'Ads Watched', '${user.adsWatched}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, Color iconColor, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.grey,
              fontSize: 16,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements(UserModel user) {
    final unlockedCount = user.achievements.where((bool a) => a).length;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements ($unlockedCount/17)',
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(17, (index) {
                final isUnlocked = user.achievements[index];
                return Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppColors.gold.withOpacity(0.2)
                        : AppColors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isUnlocked ? AppColors.gold : AppColors.grey,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isUnlocked ? Icons.emoji_events : Icons.lock_outline,
                      color: isUnlocked ? AppColors.gold : AppColors.grey,
                      size: 24,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          _buildSettingItem(context, Icons.settings, AppColors.grey, 'App Settings', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          }),
          _buildSettingItem(context, Icons.notifications_outlined, AppColors.purple, 'Notifications', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          }),
          _buildSettingItem(context, Icons.emoji_events, AppColors.gold, 'Leaderboard', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
            );
          }),
          _buildSettingItem(context, Icons.help_outline, AppColors.cyan, 'Help & FAQ', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpFaqScreen()),
            );
          }),
          _buildSettingItem(context, Icons.privacy_tip_outlined, AppColors.grey, 'Privacy Policy', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, Color iconColor, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Roblox username ──────────────────────────────────────────────────────────

class _RobloxUsernameCard extends StatelessWidget {
  const _RobloxUsernameCard({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final isSet = user.robloxUsername.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => ProfileScreen._editRobloxUsername(context, user),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSet ? const Color(0xFFE8EAFF) : AppColors.gold,
              width: isSet ? 1 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.purple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: RobuxIcon(size: 26, color: AppColors.purple),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Roblox Username',
                      style: TextStyle(
                        color: AppColors.textMid,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isSet ? user.robloxUsername : 'Tap to add — needed to get your ${AppStrings.currency}',
                      style: TextStyle(
                        color: isSet ? AppColors.textDark : AppColors.gold,
                        fontSize: isSet ? 18 : 13,
                        fontWeight: isSet ? FontWeight.w900 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSet ? Icons.edit : Icons.add_circle,
                color: isSet ? AppColors.grey : AppColors.gold,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Invite friends ───────────────────────────────────────────────────────────

class _InviteFriendsCard extends StatelessWidget {
  const _InviteFriendsCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InviteScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.headerGradient,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.group_add, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invite Friends',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Earn from every friend you bring',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    RobuxIcon(size: 24, color: AppColors.gold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You get 20% of all the ${AppStrings.currency} your friends earn — forever!',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
