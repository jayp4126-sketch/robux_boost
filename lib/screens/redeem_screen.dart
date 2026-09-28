import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/robux_tier.dart';
import '../services/user_provider.dart';
import '../utils/constants.dart';
import 'redeem_flow_screen.dart';
import '../widgets/robux_icon.dart';

class RedeemScreen extends StatelessWidget {
  const RedeemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Cash Out', style: TextStyle(color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          if (user == null) return const Center(child: CircularProgressIndicator());

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                _BalanceCard(coins: user.coins, bonusRobux: user.bonusRobux),
                const SizedBox(height: 26),
                Text(
                  '${AppStrings.currency} Packages',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                for (final tier in kRobuxTiers) ...[
                  _PackageCard(tier: tier, coins: user.coins),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 6),
                const Text(
                  'Rewards are delivered within 5-15 business days.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Balance ──────────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.coins, required this.bonusRobux});

  final int coins;
  final int bonusRobux;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.headerGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${AppStrings.currency} Earned',
            style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RobuxIcon(size: 34, color: Colors.white),
              const SizedBox(width: 11),
              Text(
                formatAmount(robuxEarned(coins)),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Colors.white, size: 16),
                const SizedBox(width: 7),
                Text(
                  '${formatAmount(coins)} pts',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (bonusRobux > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RobuxIcon(size: 16, color: Colors.white),
                  const SizedBox(width: 7),
                  Text(
                    '${formatAmount(bonusRobux)} bonus ${AppStrings.currency} locked in',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Package card ─────────────────────────────────────────────────────────────

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.tier, required this.coins});

  final RobuxTier tier;
  final int coins;

  @override
  Widget build(BuildContext context) {
    final unlocked = coins >= tier.cost;
    final remaining = tier.cost - coins;
    final progress = (coins / tier.cost).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: unlocked ? tier.accent : const Color(0xFFE8EAFF),
          width: unlocked ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: unlocked
                ? tier.accent.withOpacity(0.22)
                : Colors.black.withOpacity(0.05),
            blurRadius: unlocked ? 18 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _RobuxTile(tier: tier, locked: !unlocked),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier.name,
                      style: TextStyle(
                        color: unlocked ? AppColors.textDark : AppColors.grey,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        RobuxIcon(size: 22, color: unlocked ? tier.accent : AppColors.grey),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            formatAmount(tier.robux),
                            style: TextStyle(
                              color: unlocked ? tier.accent : AppColors.grey,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.only(left: 29),
                      child: Text(
                        '${AppStrings.currency}',
                        style: TextStyle(
                          color: (unlocked ? tier.accent : AppColors.grey).withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              unlocked
                  ? GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RedeemFlowScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: tier.glow),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: tier.accent.withOpacity(0.45),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'REDEEM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.pillBackground,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.lock, color: AppColors.grey, size: 18),
                    ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.pillBackground,
              valueColor: AlwaysStoppedAnimation(
                unlocked ? tier.accent : tier.accent.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${formatAmount(coins.clamp(0, tier.cost))} / ${formatAmount(tier.cost)} pts',
                style: const TextStyle(
                  color: AppColors.textMid,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                unlocked ? 'Ready to redeem' : '${formatAmount(remaining)} pts to go',
                style: TextStyle(
                  color: unlocked ? tier.accent : AppColors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Robux image tile ─────────────────────────────────────────────────────────

class _RobuxTile extends StatelessWidget {
  const _RobuxTile({required this.tier, required this.locked});

  final RobuxTier tier;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    const size = 70.0;
    final tint = locked ? AppColors.grey : tier.accent;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint.withOpacity(locked ? 0.10 : 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.66,
          height: size * 0.66,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < tier.logoCount; i++)
                Transform.translate(
                  offset: Offset(
                    (i - (tier.logoCount - 1) / 2) * 9,
                    (i - (tier.logoCount - 1) / 2) * -6,
                  ),
                  child: RobuxIcon(size: size * 0.42, color: tint.withOpacity(locked ? 0.55 : 1),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
