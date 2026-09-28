import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../models/robux_tier.dart';
import '../services/user_provider.dart';
import '../utils/constants.dart';
import '../services/ad_service.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'redeem_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AdService _adService = AdService();
  int _currentIndex = 1;

  final List<Widget> _screens = const [
    RedeemScreen(),
    HomeScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adService.showAppOpenAd();
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) setState(() {});
      });
      Future.delayed(const Duration(seconds: 15), () {
        if (mounted) setState(() {});
      });
    });
  }

  /// The Wallet tab reaches RedeemScreen directly, so the points gate that
  /// guards the Redeem card on Home has to be repeated here.
  void _onNavTap(int i) {
    if (i == 0 && !AppStrings.showRedeemFull) {
      final coins = context.read<UserProvider>().user?.coins ?? 0;
      final target = kRobuxTiers.first.cost;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Not enough points',
            style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'You need ${formatAmount(target)} points to open this screen.\n\n'
            'You have ${formatAmount(coins)} — '
            '${formatAmount((target - coins).clamp(0, target))} to go.',
            style: const TextStyle(color: AppColors.textMid, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Got it',
                style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
      return;
    }
    setState(() => _currentIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_adService.bannerAd != null)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: AdWidget(ad: _adService.bannerAd!),
            ),
          _BottomNav(
            currentIndex: _currentIndex,
            onTap: _onNavTap,
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(index: 0, current: currentIndex, icon: Icons.account_balance_wallet_outlined, selectedIcon: Icons.account_balance_wallet, label: 'Wallet', onTap: onTap),
              _HomeButton(current: currentIndex, onTap: onTap),
              _NavItem(index: 2, current: currentIndex, icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile', onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.current,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });
  final int index, current;
  final IconData icon, selectedIcon;
  final String label;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? selectedIcon : icon,
              color: selected ? AppColors.purple : AppColors.grey,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.purple : AppColors.grey,
                fontSize: 10,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  const _HomeButton({required this.current, required this.onTap});
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = current == 1;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(1),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.purple,
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withOpacity(selected ? 0.45 : 0.2),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              selected ? Icons.home : Icons.home_outlined,
              color: AppColors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
