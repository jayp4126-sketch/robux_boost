import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_provider.dart';
import '../services/ad_service.dart';
import '../utils/constants.dart';
import '../widgets/game_reward_dialog.dart';
import '../widgets/native_banner_ad.dart';

class RbuxClickerGame extends StatefulWidget {
  const RbuxClickerGame({super.key});

  @override
  State<RbuxClickerGame> createState() => _RbuxClickerGameState();
}

class _RbuxClickerGameState extends State<RbuxClickerGame> {
  int _clicks = 0;
  int _timeLeft = 10;
  bool _isPlaying = false;
  Timer? _timer;
  final AdService _adService = AdService();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _clicks = 0;
      _timeLeft = 10;
      _isPlaying = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _endGame();
      }
    });
  }

  void _onTap() {
    if (!_isPlaying) return;
    setState(() {
      _clicks++;
    });
  }

  void _endGame() async {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
    });

    final coins = _clicks ~/ 2;

    if (!mounted) return;

    _showRewardPanel(coins, 'Rbux Clicker');
  }

  void _showRewardPanel(int coins, String gameName) {
    showGameRewardDialog(
      context,
      coins: coins,
      adService: _adService,
      infoLines: ['Total clicks: $_clicks'],
      onCollect: () async {
        if (!mounted) return;
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.addCoins(coins, gameName);
        await userProvider.incrementGamesPlayed();
        _adService.incrementClaimCounter();
        if (mounted) {
          _startGame();
        }
      },
      onDoubledCollect: () async {
        if (!mounted) return;
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.addCoins(coins * 2, gameName);
        await userProvider.incrementGamesPlayed();
        _adService.incrementClaimCounter();
        if (mounted) {
          _startGame();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Rbux Clicker', style: TextStyle(color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            if (!_isPlaying)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Click as fast as you can for 10 seconds!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (_isPlaying)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Time', '$_timeLeft s', AppColors.red),
                    _buildStatCard('Clicks', '$_clicks', AppColors.purple),
                  ],
                ),
              ),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: _isPlaying ? _onTap : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: _isPlaying ? 200 : 180,
                    height: _isPlaying ? 200 : 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.purple, AppColors.blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isPlaying
                          ? const Text(
                              'TAP!',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Icon(Icons.mouse, color: AppColors.white, size: 40),
                    ),
                  ),
                ),
              ),
            ),
            const NativeBannerAd(),
            if (!_isPlaying)
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Start Game',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            if (_isPlaying) const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 14)),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
