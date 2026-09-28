import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Ad display configuration, driven entirely by Remote Config.
class AdConfig {
  const AdConfig({
    this.adsEnabled = true,
    this.bannerEnabled = true,
    this.interstitialEnabled = true,
    this.rewardedEnabled = true,
    this.appOpenEnabled = true,
    this.interstitialClicks = 3,
    this.interstitialIntervalSec = 15,
    this.appOpenCooldownSec = 10,
  });

  /// Master kill-switch — false disables every ad format instantly.
  final bool adsEnabled;
  final bool bannerEnabled;
  final bool interstitialEnabled;
  final bool rewardedEnabled;
  final bool appOpenEnabled;

  /// How many button taps trigger one interstitial.
  final int interstitialClicks;

  /// Minimum seconds that must pass between two interstitials.
  final int interstitialIntervalSec;

  /// Seconds to suppress the app-open ad after any full-screen ad closes.
  final int appOpenCooldownSec;

  bool get showBanner      => adsEnabled && bannerEnabled;
  bool get showInterstitial => adsEnabled && interstitialEnabled;
  bool get showRewarded    => adsEnabled && rewardedEnabled;
  bool get showAppOpen     => adsEnabled && appOpenEnabled;
}

/// Server-driven feature flags.
///
/// Flags are exposed as [ValueNotifier]s so widgets can rebuild the moment a
/// new config is fetched, without needing to be rebuilt from above.
class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  static const String _keyShowGet500Banner = 'show_get500_banner';
  static const String _keyCurrencyLabel = 'currency_label';
  static const String _keyFullExperience = 'show_full_experience';

  // Individual experience feature keys
  static const String _keyShowOnboarding      = 'show_onboarding';
  static const String _keyShowRobuxIcons      = 'show_robux_icons';
  static const String _keyShowCardArtwork     = 'show_card_artwork';
  static const String _keyShowEarnFastButton  = 'show_earn_fast_button';
  static const String _keyShowRedeemFull      = 'show_redeem_full';

  // Ad config keys
  static const String _keyAdsEnabled             = 'ads_enabled';
  static const String _keyAdsBanner              = 'ads_banner_enabled';
  static const String _keyAdsInterstitial        = 'ads_interstitial_enabled';
  static const String _keyAdsRewarded            = 'ads_rewarded_enabled';
  static const String _keyAdsAppOpen             = 'ads_app_open_enabled';
  static const String _keyInterstitialClicks     = 'ads_interstitial_clicks';
  static const String _keyInterstitialInterval   = 'ads_interstitial_interval_sec';
  static const String _keyAppOpenCooldown        = 'ads_app_open_cooldown_sec';

  static const String _defaultCurrencyLabel = 'Robux';
  static const String _restrictedCurrencyLabel = 'RBX';

  /// Controls whether the "Get 500" banner is visible on the home screen.
  final ValueNotifier<bool> showGet500Banner = ValueNotifier<bool>(false);

  /// Master switch for the Robux-branded experience.
  final ValueNotifier<bool> fullExperience = ValueNotifier<bool>(false);

  // Individual feature flags (only active when fullExperience is true).
  final ValueNotifier<bool> showOnboarding     = ValueNotifier<bool>(false);
  final ValueNotifier<bool> showRobuxIcons     = ValueNotifier<bool>(false);
  final ValueNotifier<bool> showCardArtwork    = ValueNotifier<bool>(false);
  final ValueNotifier<bool> showEarnFastButton = ValueNotifier<bool>(false);
  final ValueNotifier<bool> showRedeemFull     = ValueNotifier<bool>(false);

  /// The wording used for the currency everywhere in the UI.
  final ValueNotifier<String> currencyLabel =
      ValueNotifier<String>(_defaultCurrencyLabel);

  /// Live ad-display settings. AdService reads this on every show/load call.
  final ValueNotifier<AdConfig> adConfig =
      ValueNotifier<AdConfig>(const AdConfig());

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );

      await remoteConfig.setDefaults(const {
        _keyShowGet500Banner: false,
        _keyCurrencyLabel: _defaultCurrencyLabel,
        _keyFullExperience: false,
        _keyShowOnboarding: true,
        _keyShowRobuxIcons: true,
        _keyShowCardArtwork: true,
        _keyShowEarnFastButton: true,
        _keyShowRedeemFull: true,
        _keyAdsEnabled: true,
        _keyAdsBanner: true,
        _keyAdsInterstitial: true,
        _keyAdsRewarded: true,
        _keyAdsAppOpen: true,
        _keyInterstitialClicks: 3,
        _keyInterstitialInterval: 15,
        _keyAppOpenCooldown: 10,
      });

      _apply(remoteConfig);

      remoteConfig.onConfigUpdated.listen((event) async {
        await remoteConfig.activate();
        _apply(remoteConfig);
      });

      await remoteConfig.fetchAndActivate();
      _apply(remoteConfig);

      _isInitialized = true;
    } catch (e) {
      debugPrint('Remote config unavailable, using defaults: $e');
    }
  }

  void _apply(FirebaseRemoteConfig remoteConfig) {
    showGet500Banner.value = remoteConfig.getBool(_keyShowGet500Banner);

    final full = remoteConfig.getBool(_keyFullExperience);
    fullExperience.value = full;

    // Individual flags: master=false forces all off; master=true defers to each flag.
    showOnboarding.value     = full && remoteConfig.getBool(_keyShowOnboarding);
    showRobuxIcons.value     = full && remoteConfig.getBool(_keyShowRobuxIcons);
    showCardArtwork.value    = remoteConfig.getBool(_keyShowCardArtwork);
    showEarnFastButton.value = full && remoteConfig.getBool(_keyShowEarnFastButton);
    showRedeemFull.value     = full && remoteConfig.getBool(_keyShowRedeemFull);

    final label = remoteConfig.getString(_keyCurrencyLabel).trim();
    currencyLabel.value = full
        ? (label.isEmpty ? _defaultCurrencyLabel : label)
        : _restrictedCurrencyLabel;

    adConfig.value = AdConfig(
      adsEnabled:           remoteConfig.getBool(_keyAdsEnabled),
      bannerEnabled:        remoteConfig.getBool(_keyAdsBanner),
      interstitialEnabled:  remoteConfig.getBool(_keyAdsInterstitial),
      rewardedEnabled:      remoteConfig.getBool(_keyAdsRewarded),
      appOpenEnabled:       remoteConfig.getBool(_keyAdsAppOpen),
      interstitialClicks:   remoteConfig.getInt(_keyInterstitialClicks).clamp(1, 20),
      interstitialIntervalSec: remoteConfig.getInt(_keyInterstitialInterval).clamp(0, 300),
      appOpenCooldownSec:   remoteConfig.getInt(_keyAppOpenCooldown).clamp(0, 120),
    );
  }
}
