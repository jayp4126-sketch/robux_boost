import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/widgets.dart';

import 'ad_ids.dart';
import 'remote_config_service.dart';
import 'session_tracker.dart';
import 'singular_keys.dart';
import 'singular_service.dart';

class AdService with WidgetsBindingObserver {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;
  bool _isShowingAd = false;
  int _buttonCounter = 0;
  int _userCoins = 9999;

  /// Call this whenever the user's coin balance changes (e.g. from a Consumer).
  void reportCoins(int coins) => _userCoins = coins;

  AdConfig get _cfg => RemoteConfigService().adConfig.value;
  DateTime? _lastInterstitialTime;

  /// When the last full-screen ad was dismissed. Dismissing one brings the app
  /// back to the foreground, which fires `resumed` — without this we would
  /// stack an app open ad on top of every rewarded/interstitial.
  DateTime? _lastFullScreenAdTime;

  /// When an app open ad was wanted but none was loaded yet (typically on a
  /// cold start, where the load is still in flight). A load that lands shortly
  /// after shows the ad; a late one is dropped.
  DateTime? _appOpenRequestedAt;
  bool _isForeground = true;

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;

  bool get isBannerAdLoaded => _bannerAd != null;
  BannerAd? get bannerAd => _bannerAd;

  // Production Ad Unit IDs
  static String get _bannerAdUnitId => AdIds.banner;
  static String get _interstitialAdUnitId => AdIds.interstitial;
  static String get _rewardedAdUnitId => AdIds.rewarded;
  static String get _appOpenAdUnitId => AdIds.appOpen;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
    WidgetsBinding.instance.addObserver(this);
    if (_cfg.showBanner)       _loadBannerAd();
    if (_cfg.showInterstitial) _loadInterstitialAd();
    if (_cfg.showRewarded)     _loadRewardedAd();
    if (_cfg.showAppOpen)      _loadAppOpenAd();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _isForeground = true;
        showAppOpenAd();
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _isForeground = false;
      case AppLifecycleState.inactive:
        break;
    }
  }

  /// AdMob reports what an impression earned; Singular turns that into ROAS
  /// against the campaigns we buy. Only full-screen formats expose this
  /// callback in google_mobile_ads 5.x.
  void _reportAdRevenue(
    Ad ad,
    double valueMicros,
    PrecisionType precision,
    String currencyCode,
  ) {
    SingularService().logAdRevenue(
      revenue: valueMicros / 1000000,
      currencyCode: currencyCode,
    );
  }

  // ==================== BANNER AD ====================
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner ad loaded');
        },
        onAdImpression: (ad) => SessionTracker().recordAdImpression(
          SingularAdFormats.banner,
          reportEvent: false,
        ),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: $error');
          ad.dispose();
          _bannerAd = null;
          Future.delayed(const Duration(seconds: 30), _loadBannerAd);
        },
      ),
    )..load();
  }

  // ==================== INTERSTITIAL AD ====================
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          ad.onPaidEvent = _reportAdRevenue;
          debugPrint('Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: $error');
          _interstitialAd = null;
          Future.delayed(const Duration(seconds: 30), _loadInterstitialAd);
        },
      ),
    );
  }

  void incrementButtonCounter() {
    _buttonCounter++;
    final threshold = _userCoins < 500 ? 5 : _cfg.interstitialClicks;
    if (_buttonCounter >= threshold) {
      _buttonCounter = 0;
      showInterstitialAd();
    }
  }

  // Backward compatibility aliases
  void incrementClaimCounter() => incrementButtonCounter();
  void incrementNavCounter() => incrementButtonCounter();

  bool _canShowInterstitial() {
    if (_isShowingAd) return false;
    if (_lastInterstitialTime == null) return true;
    return DateTime.now().difference(_lastInterstitialTime!).inSeconds >=
        _cfg.interstitialIntervalSec;
  }

  void showInterstitialAd() {
    if (!_cfg.showInterstitial || !_canShowInterstitial() || _interstitialAd == null) return;

    _isShowingAd = true;
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdImpression: (ad) => SessionTracker().recordAdImpression(
        SingularAdFormats.interstitial,
        reportEvent: true,
      ),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isShowingAd = false;
        _lastInterstitialTime = DateTime.now();
        _lastFullScreenAdTime = DateTime.now();
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isShowingAd = false;
        _lastFullScreenAdTime = DateTime.now();
        _loadInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  // ==================== REWARDED AD ====================
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          ad.onPaidEvent = _reportAdRevenue;
          debugPrint('Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
          _rewardedAd = null;
          Future.delayed(const Duration(seconds: 30), _loadRewardedAd);
        },
      ),
    );
  }

  void showRewardedAd({required Function(int) onRewarded}) {
    if (!_cfg.showRewarded) { onRewarded(1); return; }
    if (_isShowingAd) {
      debugPrint('⚠️ Rewarded ad skipped: another ad is showing');
      onRewarded(1);
      return;
    }
    
    if (_rewardedAd == null) {
      debugPrint('⚠️ Rewarded ad not loaded yet, using fallback');
      onRewarded(1);
      // Try to load ad for next time
      _loadRewardedAd();
      return;
    }

    _isShowingAd = true;
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdImpression: (ad) => SessionTracker().recordAdImpression(
        SingularAdFormats.rewarded,
        reportEvent: true,
      ),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isShowingAd = false;
        _lastFullScreenAdTime = DateTime.now();
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isShowingAd = false;
        _lastFullScreenAdTime = DateTime.now();
        _loadRewardedAd();
        onRewarded(1);
      },
    );
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        SingularService().logEvent(SingularEvents.rewardedAdCompleted);
        onRewarded(reward.amount.toInt());
      },
    );
    _rewardedAd = null;
  }

  // ==================== APP OPEN AD ====================
  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: _appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          ad.onPaidEvent = _reportAdRevenue;
          debugPrint('App open ad loaded');
          // A cold start asks for the ad before the load finishes; show it now
          // that it is here — but only if the request is still fresh. Past that
          // the user is already using the app and an ad would come out of
          // nowhere.
          final requestedAt = _appOpenRequestedAt;
          _appOpenRequestedAt = null;
          if (requestedAt != null &&
              DateTime.now().difference(requestedAt).inSeconds < 15) {
            showAppOpenAd();
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint('App open ad failed to load: $error');
          _appOpenAd = null;
          _appOpenRequestedAt = null;
          Future.delayed(const Duration(seconds: 30), _loadAppOpenAd);
        },
      ),
    );
  }

  /// Shows an app open ad on every entry into the app: the cold start and each
  /// return from the background.
  void showAppOpenAd() {
    if (!_cfg.showAppOpen || _isShowingAd || !_isForeground) return;

    if (_lastFullScreenAdTime != null &&
        DateTime.now().difference(_lastFullScreenAdTime!).inSeconds <
            _cfg.appOpenCooldownSec) {
      return;
    }

    if (_appOpenAd == null) {
      // On a cold start this can run before initialize() finishes; the load it
      // kicks off will pick the request up through _appOpenRequestedAt.
      _appOpenRequestedAt = DateTime.now();
      if (_isInitialized) _loadAppOpenAd();
      return;
    }

    _isShowingAd = true;
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdImpression: (ad) => SessionTracker().recordAdImpression(
        SingularAdFormats.appOpen,
        reportEvent: true,
      ),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isShowingAd = false;
        _lastFullScreenAdTime = DateTime.now();
        _loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isShowingAd = false;
        _loadAppOpenAd();
      },
    );
    _appOpenAd!.show();
    _appOpenAd = null;
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
  }
}
