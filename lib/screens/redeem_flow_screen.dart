import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/user_provider.dart';
import '../utils/constants.dart';
import 'games_screen.dart';

class RedeemFlowScreen extends StatefulWidget {
  const RedeemFlowScreen({super.key});

  @override
  State<RedeemFlowScreen> createState() => _RedeemFlowScreenState();
}

class _RedeemFlowScreenState extends State<RedeemFlowScreen> {
  int _step = 1;
  final TextEditingController _usernameController = TextEditingController();
  bool _ratingOpened = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _step == 1,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: AppColors.cardBackground,
          title: Text(
            _step == 3 ? 'Success!' : 'Redeem – Step $_step of 3',
            style: const TextStyle(color: AppColors.textDark),
          ),
          automaticallyImplyLeading: _step == 1,
          iconTheme: const IconThemeData(color: AppColors.textDark),
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, anim) =>
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                  child: child,
                ),
            child: _step == 1
                ? _Step1(key: const ValueKey(1), controller: _usernameController, onNext: _goStep2)
                : _step == 2
                    ? _Step2(key: const ValueKey(2), ratingOpened: _ratingOpened, onRate: _openRating, onDone: _goStep3)
                    : _Step3(key: const ValueKey(3), onContinue: _finishFlow),
          ),
        ),
      ),
    );
  }

  void _goStep2() {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Roblox username'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    setState(() => _step = 2);
  }

  Future<void> _openRating() async {
    final uri = Uri.parse(AppConstants.rateUsUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (mounted) setState(() => _ratingOpened = true);
  }

  void _goStep3() {
    if (!_ratingOpened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please rate us first to continue'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    setState(() => _step = 3);
  }

  Future<void> _finishFlow() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.resetCoins();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const GamesScreen()),
      (route) => false,
    );
  }
}

// ─── Step 1: Enter Roblox username ──────────────────────────────────────────

class _Step1 extends StatelessWidget {
  const _Step1({super.key, required this.controller, required this.onNext});

  final TextEditingController controller;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          _stepBadge(1, 'Enter your Roblox username'),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.purple.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Roblox Username',
                  style: TextStyle(color: AppColors.grey, fontSize: 13),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: const TextStyle(color: AppColors.textDark, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Enter username…',
                    hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.6)),
                    prefixIcon: const Icon(Icons.sports_esports, color: AppColors.purple, size: 22),
                    prefixIconConstraints: const BoxConstraints(minWidth: 50),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.purple, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.darkBackground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'We need your username to send your ${AppStrings.currency} reward.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.grey, fontSize: 13),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'Continue →',
              style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Step 2: Rate Us 5 Stars ─────────────────────────────────────────────────

class _Step2 extends StatelessWidget {
  const _Step2({
    super.key,
    required this.ratingOpened,
    required this.onRate,
    required this.onDone,
  });

  final bool ratingOpened;
  final VoidCallback onRate;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          _stepBadge(2, 'Rate Us 5 Stars'),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ratingOpened ? AppColors.green : AppColors.gold.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const Text('★★★★★', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 16),
                Text(
                  'Required to receive your ${AppStrings.currency}!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.gold, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'You must rate us 5 stars ★★★★★ and leave a positive review to receive your ${AppStrings.currency} reward.\n\nWithout a 5-star rating and a good review, your reward will NOT be sent.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textDark, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRate,
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
                if (ratingOpened) ...[
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: AppColors.green, size: 20),
                      SizedBox(width: 6),
                      Text('Thanks! Tap Done to continue', style: TextStyle(color: AppColors.green)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: onDone,
            style: ElevatedButton.styleFrom(
              backgroundColor: ratingOpened ? AppColors.green : AppColors.grey.withOpacity(0.4),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'Done',
              style: TextStyle(
                color: ratingOpened ? AppColors.white : AppColors.grey,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Step 3: Success ─────────────────────────────────────────────────────────

class _Step3 extends StatefulWidget {
  const _Step3({super.key, required this.onContinue});
  final VoidCallback onContinue;

  @override
  State<_Step3> createState() => _Step3State();
}

class _Step3State extends State<_Step3> with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _anim, curve: Curves.elasticOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 30),
          ScaleTransition(
            scale: _scale,
            child: const Center(
              child: const Icon(Icons.celebration, color: AppColors.gold, size: 90),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${AppStrings.currency} On The Way!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your reward is being processed.\nExpect delivery within 5-15 business days.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.grey, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'One more task left!',
                  style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Reach 2,000 coins to get ${AppConstants.rewardMLAmount} ${AppStrings.currency}!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.white, fontSize: 16, height: 1.4),
                ),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: widget.onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'Start Earning Now!',
              style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

Widget _stepBadge(int step, String label) {
  return Row(
    children: [
      Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.purple,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$step',
            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Text(
        label,
        style: const TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ],
  );
}
