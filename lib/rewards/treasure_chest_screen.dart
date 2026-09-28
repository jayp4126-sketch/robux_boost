import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_provider.dart';
import '../services/ad_service.dart';
import '../utils/constants.dart';
import '../widgets/small_native_ad.dart';

class TreasureChestScreen extends StatefulWidget {
  const TreasureChestScreen({super.key});

  @override
  State<TreasureChestScreen> createState() => _TreasureChestScreenState();
}

class _TreasureChestScreenState extends State<TreasureChestScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isOpening = false;
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openChest() {
    if (_isOpening) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    _adService.showRewardedAd(
      onRewarded: (_) {
        _runOpenChestAfterAd(userProvider);
      },
    );
  }

  Future<void> _runOpenChestAfterAd(UserProvider userProvider) async {
    if (!mounted) return;

    setState(() {
      _isOpening = true;
    });

    _controller.forward().then((_) => _controller.reverse());

    await Future.delayed(const Duration(seconds: 1));

    final random = Random();
    final roll = random.nextDouble();
    int prize;
    String rarity;

    if (roll < 0.05) {
      prize = random.nextInt(7) + 29;
      rarity = 'Epic';
    } else if (roll < 0.30) {
      prize = random.nextInt(8) + 21;
      rarity = 'Rare';
    } else {
      prize = random.nextInt(11) + 10;
      rarity = 'Common';
    }

    await userProvider.openTreasureChest(prize);

    if (!mounted) return;

    setState(() {
      _isOpening = false;
    });

    _adService.incrementClaimCounter();
    _showPrizeDialog(prize, rarity, userProvider);
  }

  void _showPrizeDialog(int prize, String rarity, UserProvider userProvider) {
    Color rarityColor;
    switch (rarity) {
      case 'Epic':
        rarityColor = AppColors.gold;
        break;
      case 'Rare':
        rarityColor = AppColors.purple;
        break;
      default:
        rarityColor = AppColors.blue;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '$rarity Reward!',
          style: TextStyle(color: rarityColor, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.savings, color: AppColors.gold, size: 60),
            const SizedBox(height: 10),
            Text(
              '$prize Coins!',
              style: const TextStyle(color: AppColors.gold, fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Collect', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _adService.showRewardedAd(onRewarded: (amount) async {
                await userProvider.addCoins(prize, 'Treasure Chest x2');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Doubled! Got extra $prize coins!'),
                      backgroundColor: AppColors.green,
                    ),
                  );
                }
              });
            },
            icon: const Icon(Icons.play_circle, color: AppColors.white),
            label: const Text('Watch Ad for 2x', style: TextStyle(color: AppColors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
          ),
        ],
      ),
    );
  }

  String _getTimeRemaining(UserProvider userProvider) {
    return 'Watch Ad to Open!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Treasure Chest', style: TextStyle(color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final canOpen = true;
          final timeRemaining = _getTimeRemaining(userProvider);

          return SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Watch an ad to open the chest!',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: canOpen
                                  ? [AppColors.gold, AppColors.gold.withOpacity(0.5)]
                                  : [AppColors.grey, AppColors.grey.withOpacity(0.5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: canOpen
                                ? [
                                    BoxShadow(
                                      color: AppColors.gold.withOpacity(0.5),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ]
                                : [],
                          ),
                          child: const Center(
                            child: Icon(Icons.inventory_2, color: AppColors.purple, size: 100),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: canOpen ? AppColors.gold : AppColors.grey,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      timeRemaining,
                      style: TextStyle(
                        color: canOpen ? AppColors.gold : AppColors.grey,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: canOpen && !_isOpening ? _openChest : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _isOpening
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                ),
                              )
                            : const Text(
                                'Open Chest',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SmallNativeAd(),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        Text(
                          'Possible Rewards:',
                          style: TextStyle(color: AppColors.grey, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Common: 10-20 coins (~70%)',
                          style: TextStyle(color: AppColors.blue, fontSize: 14),
                        ),
                        Text(
                          'Rare: 21-28 coins (~25%)',
                          style: TextStyle(color: AppColors.purple, fontSize: 14),
                        ),
                        Text(
                          'Epic: 29-35 coins (~5%)',
                          style: TextStyle(color: AppColors.gold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
