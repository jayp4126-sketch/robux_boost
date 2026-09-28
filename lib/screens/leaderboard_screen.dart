import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_provider.dart';
import '../utils/constants.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _fakePlayers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _generateFakePlayers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _generateFakePlayers() {
    final random = Random();
    final names = [
      'ProGamer99', 'CoinKing', 'LuckySpinner', 'MegaEarner', 'DiamondHunter',
      'GoldRusher', 'StarPlayer', 'CoinMaster', 'TopEarner', 'MLPro',
      'GameChamp', 'SpinWinner', 'TreasureHunter', 'CoinCollector', 'EliteGamer',
      'FastClicker', 'BrainTeaser', 'QuizMaster', 'TriviaPro', 'PlinkoKing',
      'MatchMaster', 'ScratchLuck', 'VaultBoss', 'DailyChamp', 'StreakKing',
    ];

    for (int i = 0; i < 25; i++) {
      _fakePlayers.add({
        'name': names[i],
        'coins': random.nextInt(50000) + 1000,
        'rank': i + 1,
      });
    }
    _fakePlayers.sort((a, b) => (b['coins'] as int).compareTo(a['coins'] as int));
    for (int i = 0; i < _fakePlayers.length; i++) {
      _fakePlayers[i]['rank'] = i + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Leaderboard', style: TextStyle(color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.purple,
          labelColor: AppColors.purple,
          unselectedLabelColor: AppColors.grey,
          tabs: const [
            Tab(text: 'Global'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          if (user == null) return const Center(child: CircularProgressIndicator());

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.person, color: Colors.white, size: 28),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.username,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${user.coins} coins',
                            style: const TextStyle(color: AppColors.gold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        '#--',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLeaderboardList(),
                    _buildLeaderboardList(),
                    _buildLeaderboardList(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _fakePlayers.length,
      itemBuilder: (context, index) {
        final player = _fakePlayers[index];
        final rank = player['rank'] as int;

        Color? medalColor;
        IconData? medalIcon;
        if (rank == 1) {
          medalColor = AppColors.gold;
          medalIcon  = Icons.workspace_premium;
        } else if (rank == 2) {
          medalColor = const Color(0xFFC0C0C0);
          medalIcon  = Icons.military_tech;
        } else if (rank == 3) {
          medalColor = const Color(0xFFCD7F32);
          medalIcon  = Icons.military_tech;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(15),
            border: medalColor != null
                ? Border.all(color: medalColor, width: 2)
                : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: medalIcon != null
                    ? Icon(medalIcon, color: medalColor, size: 26)
                    : Text(
                        '#$rank',
                        style: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.purple.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.person, color: AppColors.purple, size: 22),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  player['name'] as String,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.monetization_on, color: medalColor ?? AppColors.gold, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${player['coins']}',
                    style: TextStyle(
                      color: medalColor ?? AppColors.gold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
