import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'award_events.dart';
import 'storage_service.dart';
import 'singular_keys.dart';
import 'singular_service.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final StorageService _storageService = StorageService();

  UserModel? get user => _user;

  Future<void> loadUser() async {
    _user = await _storageService.loadUser();
    notifyListeners();
  }

  Future<void> createUser(String username) async {
    final inviteCode = 'BB-${username.toUpperCase()}';
    _user = UserModel(
      username: username,
      inviteCode: inviteCode,
      lastLoginDate: DateTime.now(),
    );
    await _storageService.saveUser(_user!);
    await _storageService.setNotFirstTime();
    notifyListeners();
  }

  Future<void> addCoins(int amount, String source) async {
    if (_user == null) return;
    _user!.addCoins(amount, source);
    await _storageService.saveUser(_user!);
    SingularService().logEventWithArgs(SingularEvents.rewardClaimed, {
      'amount': amount,
      'source': source,
    });
    AwardEvents().fire(amount);
    notifyListeners();
  }

  /// Grants the one-time Rate Us bonus. Returns false if already claimed.
  Future<bool> claimRateUsBonus(int robux) async {
    if (_user == null || _user!.rateUsClaimed) return false;
    _user!.rateUsClaimed = true;
    _user!.bonusRobux += robux;
    _user!.transactions
        .insert(0, '+ $robux ${AppStrings.currency} | Rate Us Bonus | now');
    await _storageService.saveUser(_user!);
    SingularService().logEventWithArgs(SingularEvents.rewardClaimed, {
      'amount': robux,
      'source': 'rate_us_bonus',
    });
    notifyListeners();
    return true;
  }

  Future<void> setRobloxUsername(String username) async {
    if (_user == null) return;
    final trimmed = username.trim();
    _user!.robloxUsername = trimmed;
    if (trimmed.isNotEmpty) _user!.username = trimmed;
    await _storageService.saveUser(_user!);
    notifyListeners();
  }

  Future<void> incrementGamesPlayed() async {
    if (_user == null) return;
    _user!.gamesPlayed++;
    await _storageService.saveUser(_user!);
    if (_user!.gamesPlayed == 1) {
      SingularService().logEvent(SingularEvents.firstGamePlayed);
    }
    SingularService().logEventWithArgs(SingularEvents.gamePlayed, {
      'total_games_played': _user!.gamesPlayed,
    });
    notifyListeners();
  }

  Future<void> incrementAdsWatched() async {
    if (_user == null) return;
    _user!.adsWatched++;
    await _storageService.saveUser(_user!);
    notifyListeners();
  }

  Future<void> updateStreak() async {
    if (_user == null) return;
    
    final now = DateTime.now();
    final lastLogin = _user!.lastLoginDate;
    final difference = now.difference(lastLogin).inDays;
    
    if (difference == 1) {
      _user!.streak++;
    } else if (difference > 1) {
      _user!.streak = 1;
    }
    
    _user!.lastLoginDate = now;
    await _storageService.saveUser(_user!);
    notifyListeners();
  }

  Future<void> unlockAchievement(int index) async {
    if (_user == null || index >= _user!.achievements.length) return;
    if (_user!.achievements[index]) return;
    
    _user!.achievements[index] = true;
    await _storageService.saveUser(_user!);
    notifyListeners();
  }

  Future<void> updateSpinsRemaining(int spins) async {
    if (_user == null) return;
    _user!.spinsRemaining = spins;
    await _storageService.saveUser(_user!);
    notifyListeners();
  }

  Future<void> updateScratchCardsRemaining(int cards) async {
    if (_user == null) return;
    _user!.scratchCardsRemaining = cards;
    await _storageService.saveUser(_user!);
    notifyListeners();
  }

  Future<void> resetDailyLimits() async {
    if (_user == null) return;
    
    final now = DateTime.now();
    final lastLogin = _user!.lastLoginDate;
    
    if (now.day != lastLogin.day || now.month != lastLogin.month || now.year != lastLogin.year) {
      _user!.spinsRemaining = 5;
      _user!.scratchCardsRemaining = 5;
      await _storageService.saveUser(_user!);
      notifyListeners();
    }
  }

  Future<void> resetCoins() async {
    if (_user == null) return;
    _user!.coins = 0;
    await _storageService.saveUser(_user!);
    notifyListeners();
  }

  Future<void> collectVault() async {
    if (_user == null) return;
    
    final coinsPerHour = _user!.vaultLevel * 5;
    final maxCoins = _user!.vaultLevel * 100;
    
    if (_user!.lastVaultCollection != null) {
      final hoursPassed = DateTime.now().difference(_user!.lastVaultCollection!).inHours;
      final coinsEarned = (hoursPassed * coinsPerHour).clamp(0, maxCoins);
      _user!.vaultBalance = coinsEarned;
    }
    
    if (_user!.vaultBalance > 0) {
      await addCoins(_user!.vaultBalance, 'Coin Vault');
      _user!.vaultBalance = 0;
    }
    
    _user!.lastVaultCollection = DateTime.now();
    await _storageService.saveUser(_user!);
    notifyListeners();
  }

  Future<void> upgradeVault() async {
    if (_user == null || _user!.vaultLevel >= 5) return;
    
    final upgradeCosts = [0, 500, 1000, 2000, 5000];
    final cost = upgradeCosts[_user!.vaultLevel];
    
    if (_user!.coins >= cost) {
      _user!.coins -= cost;
      _user!.vaultLevel++;
      await _storageService.saveUser(_user!);
      notifyListeners();
    }
  }

  Future<void> claimDailyReward(int day, int coins) async {
    if (_user == null) return;
    
    _user!.dailyRewardDay = day;
    _user!.lastDailyReward = DateTime.now();
    await addCoins(coins, 'Daily Reward');
  }

  Future<void> openTreasureChest(int coins) async {
    if (_user == null) return;
    
    _user!.lastTreasureChest = DateTime.now();
    await addCoins(coins, 'Treasure Chest');
  }

  bool canOpenTreasureChest() {
    if (_user == null) return false;
    if (_user!.lastTreasureChest == null) return true;
    
    final hoursPassed = DateTime.now().difference(_user!.lastTreasureChest!).inHours;
    return hoursPassed >= 3;
  }

  bool canClaimDailyReward() {
    if (_user == null) return true;
    if (_user!.lastDailyReward == null) return true;
    
    final now = DateTime.now();
    final last = _user!.lastDailyReward!;
    
    return now.day != last.day || now.month != last.month || now.year != last.year;
  }

  int getVaultCoinsEarned() {
    if (_user == null || _user!.lastVaultCollection == null) return 0;
    
    final coinsPerHour = _user!.vaultLevel * 5;
    final maxCoins = _user!.vaultLevel * 100;
    final hoursPassed = DateTime.now().difference(_user!.lastVaultCollection!).inHours;
    
    return (hoursPassed * coinsPerHour).clamp(0, maxCoins);
  }
}
