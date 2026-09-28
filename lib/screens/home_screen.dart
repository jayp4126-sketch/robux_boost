import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/user_provider.dart';
import '../services/ad_service.dart';
import '../utils/constants.dart';
import '../games/spin_wheel_game.dart';
import '../games/scratch_card_game.dart';
import '../games/ml_clicker_game.dart';
import '../rewards/trivia_screen.dart';
import '../rewards/daily_rewards_screen.dart';
import '../models/robux_tier.dart';
import '../rewards/video_dashboard_screen.dart';
import '../widgets/robux_award_overlay.dart';
import 'robux_unlock_screen.dart';
import '../widgets/robux_icon.dart';

final AdService _adService = AdService();

// 30 Roblox-style name pools — rotated every 4 hours so the ranking feels live.
const _kRankingNamePool = [
  'XxNoob_SlayerxX', 'RbxLegend99',  'ObbyMaster2024', 'BloxFruit_King',
  'NoodlzYT',        'xXDarkVoidXx',  'Stickmast3r',   'TypicalGam3r',
  'Linkmon99',       'Adopt_Me_Pro',  'GuestNo1337',    'RoGang_Boss',
  'PhoenixFire_RBX', 'NoobFarm_Elite','SkyWars_Champ',  'PeekaBoo_GG',
  'RbxMillionaire',  'HoodieKid_XX',  'PiggyFan2025',   'BuilderBro99',
  'XxVoidWalkerxX',  'CoinRain_RBX',  'BladeMast3r',    'RoxStar_99',
  'FrostyNinja_XD',  'GhostHuntr_RBX','SpeedRun_King',  'ZephyrBlox_Pro',
  'MegaBot_450',     'SkyRocket_RBX',
];

List<String> _getRankingPlayers() {
  // Slot index changes every 4 hours — 6 slots per day.
  final slot = DateTime.now().hour ~/ 4;
  // Deterministic but different per slot: offset into the pool by slot * 7.
  final offset = (slot * 7) % _kRankingNamePool.length;
  return [
    _kRankingNamePool[offset % _kRankingNamePool.length],
    _kRankingNamePool[(offset + 1) % _kRankingNamePool.length],
    _kRankingNamePool[(offset + 2) % _kRankingNamePool.length],
  ];
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            final user = userProvider.user;
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }
            _adService.reportCoins(user.coins);
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeaderCard(context, user),
                  const SizedBox(height: 22),
                  _buildDailyRanking(),
                  const SizedBox(height: 22),
                  _buildActivities(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Header card ─────────────────────────────────────────────────────────────

  Widget _buildHeaderCard(BuildContext context, user) {
    final int robuxValue =
        robuxEarned(user.coins as int) + (user.bonusRobux as int);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.headerGradient,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _avatar(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Earn ${AppStrings.currency}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user.username,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _streakBadge(user),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Coins balance pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${user.coins}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('pts', style: TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Robux equivalent pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RobuxIcon(size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          '${formatAmount(robuxValue)} ${AppStrings.currency}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (AppStrings.showEarnFastButton) ...[
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => _showRateUsDialog(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const RobuxIcon(size: 18, color: AppColors.purple),
                      const SizedBox(width: 8),
                      Text(
                        'EARN ${AppStrings.currency.toUpperCase()} FAST',
                        style: const TextStyle(
                          color: AppColors.purple,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openRedeem(BuildContext context) {
    _adService.incrementNavCounter();

    if (AppStrings.showRedeemFull) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RobuxUnlockScreen()),
      );
      return;
    }

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
  }

  void _showRateUsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(3),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RobuxIcon(size: 26, color: AppColors.gold),
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
                          RobuxIcon(size: 26, color: AppColors.gold),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '1. Rate our app 5 stars ★★★★★',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '2. Leave a good comment for ${AppStrings.currency}!',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
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
                        onPressed: () => Navigator.pop(ctx),
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
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final granted = await context
                              .read<UserProvider>()
                              .claimRateUsBonus(AppConstants.rewardRobuxAmount);
                          if (granted && context.mounted) {
                            showRobuxAward(context,
                                amount: AppConstants.rewardRobuxAmount);
                          }
                          final uri = Uri.parse(AppConstants.rateUsUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
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
      ),
    );
  }

  Widget _avatar() {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.22),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
      ),
      child: const Center(
        child: Icon(Icons.person, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _streakBadge(user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: AppColors.gold, size: 14),
          const SizedBox(width: 4),
          Text(
            '${user.streak}d',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Daily Ranking ────────────────────────────────────────────────────────────

  Widget _buildDailyRanking() {
    final players = _getRankingPlayers();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.emoji_events, 'Daily Ranking'),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _rankingAvatar(name: players[0], rank: 2, isFirst: false),
            const SizedBox(width: 14),
            _rankingAvatar(name: players[1], rank: 1, isFirst: true),
            const SizedBox(width: 14),
            _rankingAvatar(name: players[2], rank: 3, isFirst: false),
          ],
        ),
      ],
    );
  }

  Widget _rankingAvatar({required String name, required int rank, required bool isFirst}) {
    final size     = isFirst ? 84.0 : 64.0;
    final iconSize = isFirst ? 36.0 : 28.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardBackground,
                border: Border.all(
                  color: isFirst ? AppColors.gold : const Color(0xFFDDE0F0),
                  width: isFirst ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isFirst
                        ? AppColors.gold.withOpacity(0.3)
                        : Colors.black.withOpacity(0.06),
                    blurRadius: isFirst ? 16 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  color: isFirst ? AppColors.purple : AppColors.grey,
                  size: iconSize,
                ),
              ),
            ),
            if (isFirst)
              Positioned(
                top: -8,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold,
                    boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.4), blurRadius: 8)],
                  ),
                  child: const Icon(Icons.workspace_premium, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            color: isFirst ? AppColors.purple : AppColors.textMid,
            fontSize: isFirst ? 13 : 11,
            fontWeight: isFirst ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ─── Activities ───────────────────────────────────────────────────────────────

  Widget _buildActivities(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.bolt, 'Activities'),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(child: _Card(icon: Icons.calendar_today,  color: AppColors.pink,    imagePath: 'assets/icons/031a67ac-2420-4c52-acd1-dbd7981f5efe.png',       label: 'Daily Check', onTap: () { _adService.incrementNavCounter(); Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyRewardsScreen())); })),
            const SizedBox(width: 12),
            Expanded(child: _Card(icon: Icons.style,           color: AppColors.purple,  imagePath: 'assets/icons/7e5c7323-3457-48f2-8834-648304a759b9.png',       label: 'Scratch',     onTap: () { _adService.incrementNavCounter(); Navigator.push(context, MaterialPageRoute(builder: (_) => const ScratchCardGame())); })),
          ]),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(child: _Card(icon: Icons.play_circle,     color: AppColors.blue,    imagePath: 'assets/icons/54d5caba-8650-40f4-a083-7aca7ee39d7a.png',       label: 'Watch Video', onTap: () { _adService.incrementNavCounter(); Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoDashboardScreen())); })),
            const SizedBox(width: 12),
            Expanded(child: _Card(icon: Icons.casino,          color: AppColors.gold,    imagePath: 'assets/icons/1411d29e-e5da-42e8-ae44-43c33f0e5cd5.png',       label: 'Spin Wheel',  onTap: () { _adService.incrementNavCounter(); Navigator.push(context, MaterialPageRoute(builder: (_) => const SpinWheelGame())); })),
          ]),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(child: _Card(icon: Icons.psychology,       color: AppColors.cyan,   imagePath: 'assets/icons/bae772a4-8096-4136-afbd-2d11432855c4.png',  label: 'Quiz',       small: true, onTap: () { _adService.incrementNavCounter(); Navigator.push(context, MaterialPageRoute(builder: (_) => const TriviaScreen())); })),
            const SizedBox(width: 10),
            Expanded(child: _Card(icon: Icons.sports_esports,   color: AppColors.green,  imagePath: 'assets/icons/5cb75839-75bf-439b-9859-9dd22e2e379d.png',  label: 'Mini Games', small: true, onTap: () { _adService.incrementNavCounter(); Navigator.push(context, MaterialPageRoute(builder: (_) => const MLClickerGame())); })),
            const SizedBox(width: 10),
            Expanded(child: _Card(icon: Icons.card_giftcard,    color: AppColors.activityOrange, imagePath: 'assets/icons/994e4b5c-4165-4107-bc6b-6dba27d974da.png', label: 'Redeem',    small: true, onTap: () => _openRedeem(context))),
          ]),
        ),
      ],
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  Widget _sectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.purple, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Activity card ────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.small = false,
    this.imagePath,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final bool small;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final containerSize = small ? 46.0 : 58.0;
    final iconSize      = small ? 22.0 : 28.0;

    final decoration = BoxDecoration(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE8EAFF), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ],
    );

    if (imagePath != null && AppStrings.showCardArtwork) {
      return GestureDetector(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: decoration,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: Image.asset(imagePath!, fit: BoxFit.cover),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: small ? 14 : 20, horizontal: small ? 6 : 14),
        decoration: decoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: containerSize,
              height: containerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.12),
              ),
              child: Center(child: Icon(icon, color: color, size: iconSize)),
            ),
            SizedBox(height: small ? 8 : 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: small ? 11 : 13,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
