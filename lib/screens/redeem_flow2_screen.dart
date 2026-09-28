import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/user_provider.dart';
import '../utils/constants.dart';

class RedeemFlow2Screen extends StatefulWidget {
  const RedeemFlow2Screen({super.key});

  @override
  State<RedeemFlow2Screen> createState() => _RedeemFlow2ScreenState();
}

class _RedeemFlow2ScreenState extends State<RedeemFlow2Screen> {
  bool _ratingOpened = false;
  bool _done = false;

  Future<void> _openRating() async {
    final uri = Uri.parse(AppConstants.rateUsUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (mounted) setState(() => _ratingOpened = true);
  }

  void _confirm() {
    if (!_ratingOpened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please rate us first to continue'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          _done ? '${AppStrings.currency} Confirmed!' : 'Claim 12,000 ${AppStrings.currency}',
          style: const TextStyle(color: AppColors.textDark),
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
        automaticallyImplyLeading: !_done,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _done ? _buildSuccess(context) : _buildRatingStep(),
        ),
      ),
    );
  }

  Widget _buildRatingStep() {
    return Padding(
      key: const ValueKey('rating'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2d1f00), Color(0xFF3d2b00)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.3),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.emoji_events, color: AppColors.gold, size: 50),
                const SizedBox(height: 10),
                Text(
                  'Almost there! Get your 12,000 ${AppStrings.currency}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Rating card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _ratingOpened ? AppColors.green : AppColors.gold.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const Text('★★★★★', style: TextStyle(fontSize: 38)),
                const SizedBox(height: 14),
                Text(
                  'Required to receive your ${AppStrings.currency}!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'You must rate us 5 stars ★★★★★ and leave a positive review.\n\nWithout a 5-star rating and a good review, your ${AppStrings.currency} will NOT be sent.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textDark, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _openRating,
                  icon: const Icon(Icons.star, color: AppColors.gold, size: 20),
                  label: const Text(
                    'Rate 5 Stars Now',
                    style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                if (_ratingOpened) ...[
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: AppColors.green, size: 20),
                      SizedBox(width: 6),
                      Text('Thanks! Tap Done below', style: TextStyle(color: AppColors.green)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _confirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: _ratingOpened ? AppColors.green : AppColors.grey.withOpacity(0.4),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'Done – Claim My ${AppStrings.currency}!',
              style: TextStyle(
                color: _ratingOpened ? AppColors.white : AppColors.grey,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Padding(
      key: const ValueKey('success'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 30),
          const Center(child: Icon(Icons.celebration, color: AppColors.gold, size: 90)),
          const SizedBox(height: 20),
          Text(
            '12,000 ${AppStrings.currency} On The Way!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.green, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.green.withOpacity(0.25),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.access_time, color: AppColors.gold, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'Delivery Time',
                  style: TextStyle(color: AppColors.textDark, fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '5 – 15 business days',
                  style: TextStyle(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1A0A0A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.red.withOpacity(0.6), width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'If you did not leave a 5-star rating and a positive review, your ${AppStrings.currency} will NOT be delivered.',
                    style: TextStyle(color: Colors.redAccent, fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () async {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              await userProvider.resetCoins();
              if (context.mounted) Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'Keep Earning!',
              style: TextStyle(color: AppColors.white, fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
