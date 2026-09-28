import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Single source of truth for the Robux packages, shared by the Wallet
/// (Cash Out) tab and the RBX Unlock screen so they can never drift apart.
class RobuxTier {
  const RobuxTier({
    required this.name,
    required this.robux,
    required this.cost,
    required this.accent,
    required this.glow,
    required this.logoCount,
  });

  final String name;
  final int robux;
  final int cost;
  final Color accent;
  final List<Color> glow;
  final int logoCount;
}

const kRobuxTiers = <RobuxTier>[
  RobuxTier(
    name: 'RBX',
    robux: 12000,
    cost: 2000,
    accent: AppColors.gold,
    glow: AppColors.goldGlow,
    logoCount: 1,
  ),
  RobuxTier(
    name: 'Mega RBX',
    robux: 16000,
    cost: 5000,
    accent: AppColors.purple,
    glow: AppColors.purpleGlow,
    logoCount: 2,
  ),
  RobuxTier(
    name: 'Ultra RBX',
    robux: 30000,
    cost: 7000,
    accent: AppColors.cyan,
    glow: AppColors.greenGlow,
    logoCount: 3,
  ),
];

/// Robux the user has earned so far, priced off the entry package
/// (8,000 pts → 12,000 Robux).
int robuxEarned(int coins) {
  final base = kRobuxTiers.first;
  return (coins * base.robux / base.cost).floor();
}

String formatAmount(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
