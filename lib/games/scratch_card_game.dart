import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_provider.dart';
import '../services/ad_service.dart';
import '../utils/constants.dart';
import '../widgets/game_reward_dialog.dart';
import '../widgets/native_banner_ad.dart';

class ScratchCardGame extends StatefulWidget {
  const ScratchCardGame({super.key});

  @override
  State<ScratchCardGame> createState() => _ScratchCardGameState();
}

class _ScratchCardGameState extends State<ScratchCardGame> {
  int _currentPrize = 0;
  bool _isScratched = false;
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _generatePrize();
  }

  void _generatePrize() {
    final random = Random();
    setState(() {
      _currentPrize = random.nextInt(26) + 10;
      _isScratched = false;
    });
  }

  void _onScratchComplete() async {
    if (_isScratched) return;
    
    setState(() {
      _isScratched = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    _showWinDialog();
  }

  void _showWinDialog() {
    final coins = _currentPrize;
    const gameName = 'Scratch Card';
    showGameRewardDialog(
      context,
      coins: coins,
      adService: _adService,
      onCollect: () async {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final user = userProvider.user;
        if (user != null) {
          await userProvider.addCoins(coins, gameName);
          await userProvider.updateScratchCardsRemaining(user.scratchCardsRemaining - 1);
          await userProvider.incrementGamesPlayed();
          _adService.incrementClaimCounter();
        }
        _generatePrize();
      },
      onDoubledCollect: () async {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final user = userProvider.user;
        if (user != null) {
          await userProvider.addCoins(coins * 2, gameName);
          await userProvider.updateScratchCardsRemaining(user.scratchCardsRemaining - 1);
          await userProvider.incrementGamesPlayed();
          _adService.incrementClaimCounter();
        }
        _generatePrize();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Scratch Card', style: TextStyle(color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          if (user == null) return const Center(child: CircularProgressIndicator());

          if (user.scratchCardsRemaining <= 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sentiment_dissatisfied, color: AppColors.grey, size: 80),
                  const SizedBox(height: 20),
                  const Text(
                    'No cards remaining!',
                    style: TextStyle(color: AppColors.textDark, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Come back tomorrow',
                    style: TextStyle(color: AppColors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      _adService.showRewardedAd(onRewarded: (amount) async {
                        await userProvider.updateScratchCardsRemaining(5);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Got 5 extra cards!'),
                              backgroundColor: AppColors.green,
                            ),
                          );
                        }
                      });
                    },
                    icon: const Icon(Icons.play_circle, color: AppColors.white),
                    label: const Text('Watch Ad for 5 Cards', style: TextStyle(color: AppColors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ],
              ),
            );
          }

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
                            const Text('Cards Left', style: TextStyle(color: AppColors.grey)),
                            const SizedBox(height: 5),
                            Text(
                              '${user.scratchCardsRemaining}',
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
                  const Text(
                    'Tap once to reveal your prize!',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (!_isScratched) _onScratchComplete();
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 300,
                          height: 350,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star, color: AppColors.gold, size: 80),
                                const SizedBox(height: 20),
                                Text(
                                  '$_currentPrize',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 60,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'COINS',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!_isScratched)
                          Container(
                            width: 300,
                            height: 350,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade600,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.gold, width: 2),
                            ),
                            child: const Center(
                              child: Text(
                                'Tap to reveal!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
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
}
