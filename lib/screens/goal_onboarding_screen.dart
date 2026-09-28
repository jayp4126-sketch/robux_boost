import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/user_provider.dart';
import '../utils/constants.dart';
import '../widgets/robux_award_overlay.dart';
import 'main_screen.dart';
import '../widgets/robux_icon.dart';

class GoalOnboardingScreen extends StatefulWidget {
  const GoalOnboardingScreen({super.key});

  @override
  State<GoalOnboardingScreen> createState() => _GoalOnboardingScreenState();
}

class _GoalOnboardingScreenState extends State<GoalOnboardingScreen> {
  int _step = 1;

  void _goToMain({bool withAward = false}) {
    // Captured before the route swap so it outlives this screen.
    final overlay = Overlay.of(context, rootOverlay: true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
    if (!withAward) return;
    // Let the main screen settle so the coin lands on a visible balance.
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      insertRobuxAward(overlay, amount: AppConstants.rewardRobuxAmount);
    });
  }

  void _showRateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _RateUsDialog(
        onNoThanks: () {
          Navigator.of(ctx).pop();
          _goToMain();
        },
        onRatedNow: () async {
          Navigator.of(ctx).pop();

          // Actually grant the 500 Robux.
          if (!mounted) return;
          await context
              .read<UserProvider>()
              .claimRateUsBonus(AppConstants.rewardRobuxAmount);

          final uri = Uri.parse(AppConstants.rateUsUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }

          if (!mounted) return;
          _showBonusConfirmation();
        },
      ),
    );
  }

  void _showBonusConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _BonusConfirmDialog(
        onGotIt: () {
          Navigator.of(ctx).pop();
          _goToMain(withAward: true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _step == 1
              ? _GoalSelectionPage(key: const ValueKey(1), onSelected: () => setState(() => _step = 2))
              : _ReadyPage(key: const ValueKey(2), onYes: _showRateDialog, onLater: _goToMain),
        ),
      ),
    );
  }
}

// ─── Step 1: Goal selection ───────────────────────────────────────────────────

class _GoalSelectionPage extends StatelessWidget {
  const _GoalSelectionPage({super.key, required this.onSelected});
  final VoidCallback onSelected;

  // A getter, not a const list: the currency wording can change at runtime.
  static List<_GoalItem> get _goals {
    final c = AppStrings.currency;
    return [
      _GoalItem('Get Free\n$c Daily',     const [Color(0xFFFF9F0A), Color(0xFFFF6B00)]),
      _GoalItem('Earn\n10,000 $c',        const [Color(0xFF7C3AED), Color(0xFF4F46E5)]),
      _GoalItem('Become the\nRichest',    const [Color(0xFF10B981), Color(0xFF059669)]),
      _GoalItem('Unlock All\nRewards',    const [Color(0xFFEC4899), Color(0xFFBE185D)]),
      _GoalItem('Top the\nLeaderboard',   const [Color(0xFF06B6D4), Color(0xFF0284C7)]),
      _GoalItem('Reach $c\nKing Rank',    const [Color(0xFFEF4444), Color(0xFFB91C1C)]),
      _GoalItem('Max Out\nMy Wallet',     const [Color(0xFFF59E0B), Color(0xFFD97706)]),
      _GoalItem('Earn $c\nEvery Hour',    const [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 36),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'What\'s Your Goal?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Choose your ${AppStrings.currency} goal to get started',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMid,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.0,
            ),
            itemCount: _goals.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: onSelected,
              child: _GoalCard(item: _goals[index]),
            ),
          ),
        ),
      ],
    );
  }
}

class _GoalItem {
  const _GoalItem(this.label, this.gradient);
  final String label;
  final List<Color> gradient;
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.item});
  final _GoalItem item;

  @override
  Widget build(BuildContext context) {
    final accent = item.gradient.first;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EAFF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: item.gradient,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: RobuxIcon(size: 36, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              item.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 2: Ready screen ─────────────────────────────────────────────────────

class _ReadyPage extends StatelessWidget {
  const _ReadyPage({super.key, required this.onYes, required this.onLater});
  final VoidCallback onYes;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 110,
              height: 110,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.headerGradient,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple.withOpacity(0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: RobuxIcon(size: 58, color: Colors.white),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'ARE YOU READY TO\nEARN 500 ${AppStrings.currency.toUpperCase()}\nRIGHT NOW?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Rate us and collect your first ${AppStrings.currency} bonus instantly.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMid, fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 44),
          ElevatedButton(
            onPressed: onYes,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              shadowColor: AppColors.gold.withOpacity(0.4),
            ),
            child: Text(
              'YES — EARN 500 ${AppStrings.currency.toUpperCase()} NOW',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: onLater,
            child: const Text(
              'Maybe Later',
              style: TextStyle(color: AppColors.grey, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Rate Us steps ────────────────────────────────────────────────────────────

class _RateStepsHeading extends StatelessWidget {
  const _RateStepsHeading();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _robuxIcon(),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            'To get your 500 ${AppStrings.currency}, please:',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
        ),
        const SizedBox(width: 10),
        _robuxIcon(),
      ],
    );
  }

  Widget _robuxIcon() => RobuxIcon(size: 26, color: AppColors.gold);
}

class _RateStep extends StatelessWidget {
  const _RateStep(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textDark,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.35,
      ),
    );
  }
}

// ─── Rate Us dialog ───────────────────────────────────────────────────────────

class _RateUsDialog extends StatelessWidget {
  const _RateUsDialog({required this.onNoThanks, required this.onRatedNow});
  final VoidCallback onNoThanks;
  final VoidCallback onRatedNow;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(21),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Get 500 ${AppStrings.currency}!',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pillBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _RateStepsHeading(),
                    const SizedBox(height: 16),
                    const _RateStep('1. Rate our app 5 stars ★★★★★'),
                    const SizedBox(height: 10),
                    _RateStep('2. Leave a good comment for ${AppStrings.currency}!'),
                    const SizedBox(height: 16),
                    Text(
                      'Your 500 ${AppStrings.currency} is credited instantly and paid out together with your reward when you reach 10,000 points!',
                      style: TextStyle(color: AppColors.textMid, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onNoThanks,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'No, Thanks',
                        style: TextStyle(color: AppColors.grey, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRatedNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Rate Us Now!',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bonus confirmation dialog ────────────────────────────────────────────────

class _BonusConfirmDialog extends StatelessWidget {
  const _BonusConfirmDialog({required this.onGotIt});
  final VoidCallback onGotIt;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RobuxIcon(size: 54, color: AppColors.gold),
              const SizedBox(height: 16),
              const Text(
                'Thanks for rating!',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '+500 ${AppStrings.currency} Added',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your 500 ${AppStrings.currency} is now in your balance. You will receive it together with your 10,000 ${AppStrings.currency} reward as soon as you reach 10,000 points.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMid, fontSize: 13, height: 1.45),
              ),
              const SizedBox(height: 8),
              Text(
                'That is 10,500 ${AppStrings.currency} in total. Keep playing!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onGotIt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'GOT IT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
