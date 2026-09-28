import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/push_service.dart';
import '../services/storage_service.dart';
import 'help_faq_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _notificationsEnabled = true;
  bool _dailyRewardNotif = true;
  bool _treasureChestNotif = true;
  bool _vaultFullNotif = true;
  bool _achievementNotif = true;

  final PushService _pushService = PushService();

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = _pushService.isOptedIn;
  }

  Future<void> _setPushEnabled(bool enabled) async {
    setState(() => _notificationsEnabled = enabled);
    await _pushService.setEnabled(enabled);
  }

  /// The per-reminder switches become OneSignal tags, which is what campaigns
  /// segment on — a user who turned off chest reminders is excluded from that
  /// audience rather than filtered client-side.
  Future<void> _setNotifTag(String key, bool value) async {
    await _pushService.setTag(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Settings', style: TextStyle(color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'General',
              style: TextStyle(
                color: AppColors.purple,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildSwitchTile(Icons.volume_up, 'Sound Effects', _soundEnabled, (val) {
              setState(() => _soundEnabled = val);
            }),
            _buildSwitchTile(Icons.music_note, 'Music', _musicEnabled, (val) {
              setState(() => _musicEnabled = val);
            }),
            const SizedBox(height: 30),
            const Text(
              'Notifications',
              style: TextStyle(
                color: AppColors.purple,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildSwitchTile(Icons.notifications_outlined, 'Push Notifications', _notificationsEnabled, (val) {
              _setPushEnabled(val);
            }),
            if (_notificationsEnabled) ...[
              _buildSwitchTile(Icons.today, 'Daily Reward Ready', _dailyRewardNotif, (val) {
                setState(() => _dailyRewardNotif = val);
                _setNotifTag('notif_daily_reward', val);
              }),
              _buildSwitchTile(Icons.inventory_2_outlined, 'Treasure Chest Ready', _treasureChestNotif, (val) {
                setState(() => _treasureChestNotif = val);
                _setNotifTag('notif_treasure_chest', val);
              }),
              _buildSwitchTile(Icons.account_balance_outlined, 'Vault Full', _vaultFullNotif, (val) {
                setState(() => _vaultFullNotif = val);
                _setNotifTag('notif_vault_full', val);
              }),
              _buildSwitchTile(Icons.emoji_events_outlined, 'Achievement Unlocked', _achievementNotif, (val) {
                setState(() => _achievementNotif = val);
                _setNotifTag('notif_achievement', val);
              }),
            ],
            const SizedBox(height: 30),
            const Text(
              'About',
              style: TextStyle(
                color: AppColors.purple,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildNavTile(Icons.help_outline, 'Help & FAQ', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpFaqScreen()),
              );
            }),
            _buildNavTile(Icons.privacy_tip_outlined, 'Privacy Policy', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            }),
            _buildNavTile(Icons.description_outlined, 'Terms of Service', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            }),
            _buildNavTile(Icons.email_outlined, 'Contact Us', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email: support@mlapp.com')),
              );
            }),
            const SizedBox(height: 30),
            const Text(
              'Danger Zone',
              style: TextStyle(
                color: AppColors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () => _showDeleteAccountDialog(context),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.red),
                ),
                child: const Row(
                  children: [
                    const Icon(Icons.delete_outline, color: AppColors.red, size: 24),
                    SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        'Delete Account',
                        style: TextStyle(color: AppColors.red, fontSize: 16),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: AppColors.red, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                '${AppStrings.currency} v1.0.0',
                style: TextStyle(color: AppColors.grey.withOpacity(0.5), fontSize: 14),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.purple, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: AppColors.textDark, fontSize: 16),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(IconData icon, String title, VoidCallback onTap) {
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
            Icon(icon, color: AppColors.grey, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: AppColors.textDark, fontSize: 16),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Account',
          style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone. All your coins, achievements, and progress will be lost.',
          style: TextStyle(color: AppColors.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final storage = StorageService();
              await storage.clearData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deleted. Please restart the app.'),
                    backgroundColor: AppColors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Delete', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }
}
