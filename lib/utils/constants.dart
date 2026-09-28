import 'package:flutter/material.dart';

import '../services/remote_config_service.dart';

class AppColors {
  static const Color darkBackground = Color(0xFFF4F6FF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color pillBackground = Color(0xFFECEEFF);
  static const Color purple        = Color(0xFF7C3AED);
  static const Color gold          = Color(0xFFF59E0B);
  static const Color green         = Color(0xFF10B981);
  static const Color blue          = Color(0xFF3B82F6);
  static const Color red           = Color(0xFFEF4444);
  static const Color white         = Color(0xFFFFFFFF);
  static const Color grey          = Color(0xFF9098B8);
  static const Color cyan          = Color(0xFF06B6D4);
  static const Color pink          = Color(0xFFEC4899);

  // Text on light background
  static const Color textDark      = Color(0xFF1A1A3E);
  static const Color textMid       = Color(0xFF4A4A7A);

  // Activity icon backgrounds
  static const Color activityPink   = Color(0xFFEC4899);
  static const Color activityOrange = Color(0xFFF59E0B);

  // Gradients
  static const List<Color> headerGradient = [Color(0xFF6C47FF), Color(0xFF4F46E5)];
  static const List<Color> purpleGlow     = [Color(0xFF7C3AED), Color(0xFF4F46E5)];
  static const List<Color> goldGlow       = [Color(0xFFF59E0B), Color(0xFFFF8C00)];
  static const List<Color> greenGlow      = [Color(0xFF10B981), Color(0xFF06B6D4)];
}

class AppConstants {
  /// Kept for anything that needs a compile-time name. User-facing text should
  /// use [AppStrings.appTitle], which follows the remote currency wording.
  static const String appName = 'RBX Farm';
  /// Store listing opened by the "Rate Us Now!" button.
  static const String rateUsUrl =
      'https://apps.apple.com/us/app/farm-points/id6762126657';

  static const int maxDailySpins = 5;
  static const int maxDailyScratchCards = 5;
  static const int treasureChestCooldownHours = 3;
  static const int vaultCollectionHours = 1;
  static const int targetCoins = 2000;
  static const int targetCoins2 = 2000;
  /// Shown on home progress card as the ML payout goal.
  static const int rewardRbuxAmount = 500;
  static const int rewardMLAmount = 12000; // keep for compatibility
  static const int rewardRobuxAmount = 500;
  
  static const List<String> rankNames = [
    'Beginner',
    'Bronze',
    'Silver',
    'Gold',
    'Diamond'
  ];
  
  static const List<int> rankThresholds = [
    0,
    500,
    2000,
    5000,
    10000
  ];
  
  static const List<String> gameEmojis = [
    '🎮', '⭐', '🎁', '💎', '🔥', '🚀', 'pts', '🏆',
    '🎯', '🎪', '🎲', '🎸', '🌟', '💰', '🎭', '🧩'
  ];
}

class AppStrings {
  /// Currency wording, server-driven so it can be switched (e.g. to 'RBX')
  /// without a release. See `RemoteConfigService.currencyLabel`.
  static String get currency => RemoteConfigService().currencyLabel.value;

  /// Whether the Robux-branded experience is on (master switch).
  static bool get fullExperience => RemoteConfigService().fullExperience.value;

  // Individual feature flags — each only active when fullExperience is true.
  static bool get showOnboarding     => RemoteConfigService().showOnboarding.value;
  static bool get showRobuxIcons     => RemoteConfigService().showRobuxIcons.value;
  static bool get showCardArtwork    => RemoteConfigService().showCardArtwork.value;
  static bool get showEarnFastButton => RemoteConfigService().showEarnFastButton.value;
  static bool get showRedeemFull     => RemoteConfigService().showRedeemFull.value;

  /// App name as shown inside the UI, following the currency wording — with
  /// `currency_label` set to RBX this reads "RBX Farm".
  static String get appTitle => '$currency Farm';

  static const String welcomeMessage = 'Hello';
  static const String progressToRbux = 'Progress to Rbux';
  static String get progressToML => 'Progress to FREE ${currency.toUpperCase()}';
  static const String quickEarn = 'Quick Earn';
  static const String dailyRewards = 'Daily Rewards';
  static const String watchVideos = 'Watch Videos & Earn';
  static const String spinWheel = 'Spin Wheel';
  static const String scratchCard = 'Scratch Card';
  static const String tileMatch = 'Tile Match';
  static const String plinko = 'Plinko';
  static const String rbuxClicker = 'Rbux Clicker';
  static const String treasureChest = 'Treasure Chest';
  static const String coinVault = 'Coin Vault';
  static const String inviteFriends = 'Invite Friends';
  static const String trivia = 'Trivia';
}
