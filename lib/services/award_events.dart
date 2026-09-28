import 'package:flutter/foundation.dart';

/// Broadcasts every coin award so the global balance bar can play its fly-in
/// animation, no matter which screen the reward was earned on.
class AwardEvents {
  static final AwardEvents _instance = AwardEvents._();
  factory AwardEvents() => _instance;
  AwardEvents._();

  /// Bumped on every award. Listeners read [lastCoins] when it changes.
  final ValueNotifier<int> tick = ValueNotifier<int>(0);

  int lastCoins = 0;

  void fire(int coins) {
    if (coins <= 0) return;
    lastCoins = coins;
    tick.value++;
  }
}
