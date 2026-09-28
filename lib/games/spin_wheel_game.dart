import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import '../services/user_provider.dart';
import '../services/ad_service.dart';
import '../utils/constants.dart';
import '../widgets/game_reward_dialog.dart';
import '../widgets/native_banner_ad.dart';

class SpinWheelGame extends StatefulWidget {
  const SpinWheelGame({super.key});

  @override
  State<SpinWheelGame> createState() => _SpinWheelGameState();
}

class _SpinWheelGameState extends State<SpinWheelGame> {
  final StreamController<int> _controller = StreamController<int>();
  /// Wheel segments — each prize is between 10 and 35 coins.
  final List<int> _prizes = [10, 14, 18, 22, 26, 30, 33, 35];
  bool _isSpinning = false;
  final AdService _adService = AdService();

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void _spin() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    
    if (user == null || user.spinsRemaining <= 0) {
      _showWatchAdForSpins();
      return;
    }

    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
    });

    final random = Random();
    final selectedIndex = random.nextInt(_prizes.length);
    
    _controller.add(selectedIndex);

    await Future.delayed(const Duration(seconds: 4));

    final prize = _prizes[selectedIndex];
    await userProvider.updateSpinsRemaining(user.spinsRemaining - 1);

    if (!mounted) return;

    setState(() {
      _isSpinning = false;
    });

    _showWinDialog(prize);
  }

  void _showWatchAdForSpins() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final widgetContext = context;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'No Spins Left!',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sentiment_dissatisfied, color: AppColors.grey, size: 60),
            SizedBox(height: 10),
            Text(
              'Watch a video to get 5 extra spins!',
              style: TextStyle(color: AppColors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No Thanks', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              _adService.showRewardedAd(onRewarded: (amount) async {
                final user = userProvider.user;
                if (user != null) {
                  await userProvider.updateSpinsRemaining(user.spinsRemaining + 5);
                  
                  if (mounted) {
                    setState(() {});
                    ScaffoldMessenger.of(widgetContext).showSnackBar(
                      const SnackBar(
                        content: Text('Got 5 extra spins!'),
                        backgroundColor: AppColors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              });
            },
            icon: const Icon(Icons.play_circle, color: AppColors.white),
            label: const Text('Watch Ad', style: TextStyle(color: AppColors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.purple),
          ),
        ],
      ),
    );
  }

  void _showWinDialog(int prize) {
    const gameName = 'Spin Wheel';
    showGameRewardDialog(
      context,
      coins: prize,
      adService: _adService,
      onCollect: () async {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.addCoins(prize, gameName);
        await userProvider.incrementGamesPlayed();
        _adService.incrementClaimCounter();
      },
      onDoubledCollect: () async {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.addCoins(prize * 2, gameName);
        await userProvider.incrementGamesPlayed();
        _adService.incrementClaimCounter();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Spin Wheel', style: TextStyle(color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          if (user == null) return const Center(child: CircularProgressIndicator());

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Spins Left', style: TextStyle(color: AppColors.grey)),
                            const SizedBox(height: 5),
                            Text(
                              '${user.spinsRemaining}',
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Your Coins', style: TextStyle(color: AppColors.grey)),
                            const SizedBox(height: 5),
                            Text(
                              '${user.coins}',
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: FortuneWheel(
                      selected: _controller.stream,
                      animateFirst: false,
                      items: _prizes.map((prize) {
                        return FortuneItem(
                          child: Text(
                            '$prize',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: FortuneItemStyle(
                            color: _getColorForPrize(prize),
                            borderColor: AppColors.white,
                            borderWidth: 2,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSpinning ? null : _spin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _isSpinning
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                ),
                              )
                            : const Text(
                                'SPIN NOW!',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const NativeBannerAd(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getColorForPrize(int prize) {
    final colors = [
      AppColors.red,
      AppColors.blue,
      AppColors.green,
      AppColors.purple,
      AppColors.gold,
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
    ];
    final index = _prizes.indexOf(prize);
    return colors[index % colors.length];
  }
}
