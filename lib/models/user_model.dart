class UserModel {
  String username;
  int coins;
  int streak;
  int gamesPlayed;
  int adsWatched;
  String inviteCode;
  DateTime lastLoginDate;
  List<bool> achievements;
  int vaultLevel;
  int vaultBalance;
  DateTime? lastVaultCollection;
  DateTime? lastTreasureChest;
  DateTime? lastDailyReward;
  int dailyRewardDay;
  int spinsRemaining;
  int scratchCardsRemaining;
  int bonusRobux;
  bool rateUsClaimed;
  String robloxUsername;
  List<String> transactions;

  UserModel({
    required this.username,
    this.coins = 0,
    this.streak = 0,
    this.gamesPlayed = 0,
    this.adsWatched = 0,
    required this.inviteCode,
    required this.lastLoginDate,
    List<bool>? achievements,
    this.vaultLevel = 1,
    this.vaultBalance = 0,
    this.lastVaultCollection,
    this.lastTreasureChest,
    this.lastDailyReward,
    this.dailyRewardDay = 0,
    this.spinsRemaining = 5,
    this.scratchCardsRemaining = 5,
    this.bonusRobux = 0,
    this.rateUsClaimed = false,
    this.robloxUsername = '',
    List<String>? transactions,
  })  : achievements = achievements ?? List.filled(17, false),
        transactions = transactions ?? [];

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'coins': coins,
      'streak': streak,
      'gamesPlayed': gamesPlayed,
      'adsWatched': adsWatched,
      'inviteCode': inviteCode,
      'lastLoginDate': lastLoginDate.toIso8601String(),
      'achievements': achievements,
      'vaultLevel': vaultLevel,
      'vaultBalance': vaultBalance,
      'lastVaultCollection': lastVaultCollection?.toIso8601String(),
      'lastTreasureChest': lastTreasureChest?.toIso8601String(),
      'lastDailyReward': lastDailyReward?.toIso8601String(),
      'dailyRewardDay': dailyRewardDay,
      'spinsRemaining': spinsRemaining,
      'scratchCardsRemaining': scratchCardsRemaining,
      'bonusRobux': bonusRobux,
      'rateUsClaimed': rateUsClaimed,
      'robloxUsername': robloxUsername,
      'transactions': transactions,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      coins: json['coins'],
      streak: json['streak'],
      gamesPlayed: json['gamesPlayed'],
      adsWatched: json['adsWatched'],
      inviteCode: json['inviteCode'],
      lastLoginDate: DateTime.parse(json['lastLoginDate']),
      achievements: List<bool>.from(json['achievements']),
      vaultLevel: json['vaultLevel'] ?? 1,
      vaultBalance: json['vaultBalance'] ?? 0,
      lastVaultCollection: json['lastVaultCollection'] != null
          ? DateTime.parse(json['lastVaultCollection'])
          : null,
      lastTreasureChest: json['lastTreasureChest'] != null
          ? DateTime.parse(json['lastTreasureChest'])
          : null,
      lastDailyReward: json['lastDailyReward'] != null
          ? DateTime.parse(json['lastDailyReward'])
          : null,
      dailyRewardDay: json['dailyRewardDay'] ?? 0,
      spinsRemaining: json['spinsRemaining'] ?? 5,
      scratchCardsRemaining: json['scratchCardsRemaining'] ?? 5,
      bonusRobux: json['bonusRobux'] ?? 0,
      rateUsClaimed: json['rateUsClaimed'] ?? false,
      robloxUsername: json['robloxUsername'] ?? '',
      transactions: List<String>.from(json['transactions'] ?? []),
    );
  }

  String getRank() {
    if (coins >= 10000) return 'Diamond';
    if (coins >= 5000) return 'Gold';
    if (coins >= 2000) return 'Silver';
    if (coins >= 500) return 'Bronze';
    return 'Beginner';
  }

  String getRankIcon() {
    return '';
  }

  int getCoinsToNextRank() {
    if (coins >= 10000) return 0;
    if (coins >= 5000) return 10000 - coins;
    if (coins >= 2000) return 5000 - coins;
    if (coins >= 500) return 2000 - coins;
    return 500 - coins;
  }

  void addCoins(int amount, String source) {
    coins += amount;
    final timestamp = DateTime.now();
    transactions.insert(
      0,
      '+ $amount | $source | ${_formatTime(timestamp)}',
    );
    if (transactions.length > 50) {
      transactions = transactions.sublist(0, 50);
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
