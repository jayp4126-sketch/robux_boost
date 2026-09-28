import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class MakeVideoScreen extends StatefulWidget {
  const MakeVideoScreen({super.key});

  @override
  State<MakeVideoScreen> createState() => _MakeVideoScreenState();
}

class _MakeVideoScreenState extends State<MakeVideoScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _tiktokController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  bool _tiktokVerified = false;
  bool _youtubeVerified = false;

  static const String verificationCode = 'RobuxFarm0932';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tiktokController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Make Video', style: TextStyle(color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.purple,
          labelColor: AppColors.purple,
          unselectedLabelColor: AppColors.grey,
          tabs: const [
            Tab(text: 'TikTok'),
            Tab(text: 'YouTube'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlatformTab(
            platform: 'TikTok',
            icon: Icons.music_note,
            coinsPerViews: 300,
            viewsNeeded: 100,
            controller: _tiktokController,
            isVerified: _tiktokVerified,
            onVerify: () => _verifyAccount('TikTok'),
            color: const Color(0xFFEE1D52),
          ),
          _buildPlatformTab(
            platform: 'YouTube',
            icon: Icons.play_circle,
            coinsPerViews: 400,
            viewsNeeded: 100,
            controller: _youtubeController,
            isVerified: _youtubeVerified,
            onVerify: () => _verifyAccount('YouTube'),
            color: const Color(0xFFFF0000),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformTab({
    required String platform,
    required IconData icon,
    required int coinsPerViews,
    required int viewsNeeded,
    required TextEditingController controller,
    required bool isVerified,
    required VoidCallback onVerify,
    required Color color,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.6)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(icon, color: AppColors.white, size: 60),
                const SizedBox(height: 15),
                Text(
                  'Earn with $platform',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$coinsPerViews coins per $viewsNeeded views',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'How it works',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 15),
          _buildStep('1', 'Create a video about ${AppStrings.appTitle}'),
          const SizedBox(height: 10),
          _buildStep('2', 'Upload to $platform'),
          const SizedBox(height: 10),
          _buildStep('3', 'Add verification code to your ${platform == 'TikTok' ? 'bio' : 'channel description'}'),
          const SizedBox(height: 10),
          _buildStep('4', 'Enter your ${platform == 'TikTok' ? 'username' : 'channel link'} below'),
          const SizedBox(height: 10),
          _buildStep('5', 'Wait for verification (24-48 hours)'),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.gold),
            ),
            child: Column(
              children: [
                const Text(
                  'Verification Code',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      verificationCode,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(const ClipboardData(text: verificationCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Code copied!'),
                            backgroundColor: AppColors.green,
                          ),
                        );
                      },
                      child: const Icon(Icons.copy, color: AppColors.gold, size: 24),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          if (!isVerified) ...[
            const Text(
              'Verify Your Account',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.purple, width: 2),
              ),
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: platform == 'TikTok'
                      ? '@username'
                      : 'YouTube channel link',
                  hintStyle: const TextStyle(color: AppColors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                  prefixIcon: Icon(
                    platform == 'TikTok' ? Icons.person : Icons.link,
                    color: AppColors.purple,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onVerify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Verify Account',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.green, width: 2),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.green, size: 50),
                  const SizedBox(height: 10),
                  const Text(
                    'Account Verified!',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your $platform account is being reviewed.\nViews are updated every 6 hours.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rules',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '- Video must be about ${AppStrings.appTitle} app\n'
                  '- Content must be quality and relevant\n'
                  '- Verification takes 24-48 hours\n'
                  '- Views are updated every 6 hours\n'
                  '- Rejected videos may result in a ban',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.purple,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _verifyAccount(String platform) {
    final controller = platform == 'TikTok' ? _tiktokController : _youtubeController;

    if (controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your $platform ${platform == 'TikTok' ? 'username' : 'channel link'}'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.purple),
            SizedBox(height: 20),
            Text(
              'Submitting verification...',
              style: TextStyle(color: AppColors.textDark),
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context);

      setState(() {
        if (platform == 'TikTok') {
          _tiktokVerified = true;
        } else {
          _youtubeVerified = true;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$platform verification submitted! Review takes 24-48 hours.'),
          backgroundColor: AppColors.green,
        ),
      );
    });
  }
}
