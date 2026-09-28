import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Privacy Policy', style: TextStyle(color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Last updated: March 2026',
              style: TextStyle(color: AppColors.grey.withOpacity(0.7), fontSize: 14),
            ),
            const SizedBox(height: 30),
            _buildSection(
              'Information We Collect',
              'We collect the following information:\n\n'
              '- Username (chosen by you)\n'
              '- Game progress and statistics\n'
              '- Coin balance and transaction history\n'
              '- Achievement progress\n'
              '- Device information for ad personalization\n'
              '- App usage data and analytics',
            ),
            _buildSection(
              'How We Use Your Data',
              'Your data is used for:\n\n'
              '- Saving your game progress locally on your device\n'
              '- Providing personalized ads through Google AdMob\n'
              '- Improving app performance and user experience\n'
              '- Maintaining leaderboard rankings\n'
              '- Processing reward redemptions',
            ),
            _buildSection(
              'Data Storage',
              'Your game data is stored locally on your device using SharedPreferences. '
              'We do not store your personal data on external servers. '
              'If you delete the app or clear app data, your progress will be lost.',
            ),
            _buildSection(
              'Third-Party Services',
              'We use the following third-party services:\n\n'
              '- Google AdMob: For displaying advertisements\n'
              '- Google Analytics: For app usage analytics\n\n'
              'These services may collect information about your device and usage patterns. '
              'Please refer to their respective privacy policies for more information.',
            ),
            _buildSection(
              'Advertising',
              'Our app displays advertisements through Google AdMob. '
              'Ad partners may use cookies and similar technologies to personalize ads. '
              'You can opt out of personalized advertising in your device settings.',
            ),
            _buildSection(
              'Children\'s Privacy',
              'This app is not intended for children under the age of 13. '
              'We do not knowingly collect personal information from children under 13.',
            ),
            _buildSection(
              'Your Rights',
              'You have the right to:\n\n'
              '- Access your data (available in the Profile section)\n'
              '- Delete your data (Settings > Delete Account)\n'
              '- Opt out of personalized ads (device settings)\n'
              '- Contact us with privacy concerns',
            ),
            _buildSection(
              'Data Security',
              'We take reasonable measures to protect your data. '
              'All data is stored locally on your device. '
              'We do not transmit personal data over the internet.',
            ),
            _buildSection(
              'Changes to This Policy',
              'We may update this privacy policy from time to time. '
              'We will notify you of any changes by posting the new privacy policy in the app.',
            ),
            _buildSection(
              'Contact Us',
              'If you have any questions about this privacy policy, please contact us at:\n\n'
              'Email: support@robuxboost.app',
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.purple,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(color: AppColors.grey, fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }
}
