import 'package:flutter/foundation.dart';

/// Ad Unit IDs, resolved per platform and per build mode.
///
/// Debug builds use Google's demo units. They are not tied to our AdMob
/// account, so tapping ads while developing cannot generate invalid traffic —
/// which is what gets accounts suspended.
///
/// Production units belong to publisher 8150226043311642, the account that owns
/// the iOS app (ca-app-pub-8150226043311642~1371169481, see
/// ios/Runner/Info.plist), and are the confirmed iOS units.
///
/// The Android app is registered under a different publisher
/// (ca-app-pub-7257176588145778~1624827062, see AndroidManifest.xml). Ad units
/// are per-app in AdMob, so Android needs its own units for every slot.
/// TODO: fill in the Android units and give each getter a real second branch.
class AdIds {
  const AdIds._();

  static bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  // ==================== TEST UNITS (debug builds) ====================
  static const String _testBannerIOS = 'ca-app-pub-3940256099942544/2435281174';
  static const String _testBannerAndroid =
      'ca-app-pub-3940256099942544/9214589741';
  static const String _testInterstitialIOS =
      'ca-app-pub-3940256099942544/4411468910';
  static const String _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedIOS =
      'ca-app-pub-3940256099942544/1712485313';
  static const String _testRewardedAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedInterstitialIOS =
      'ca-app-pub-3940256099942544/6978759866';
  static const String _testRewardedInterstitialAndroid =
      'ca-app-pub-3940256099942544/5354046379';
  static const String _testAppOpenIOS =
      'ca-app-pub-3940256099942544/5575463023';
  static const String _testAppOpenAndroid =
      'ca-app-pub-3940256099942544/9257395921';
  static const String _testNativeIOS = 'ca-app-pub-3940256099942544/3986624511';
  static const String _testNativeAndroid =
      'ca-app-pub-3940256099942544/2247696110';

  // ==================== PRODUCTION UNITS ====================
  static const String _banner = 'ca-app-pub-8150226043311642/2572570513';
  static const String _interstitial = 'ca-app-pub-8150226043311642/8672343929';
  static const String _rewarded = 'ca-app-pub-8150226043311642/3102324609';
  static const String _rewardedInterstitial =
      'ca-app-pub-8150226043311642/4415406272';
  static const String _appOpen = 'ca-app-pub-8150226043311642/3466849780';
  static const String _nativeAdvanced =
      'ca-app-pub-8150226043311642/1235438117';

  static String get banner =>
      kDebugMode ? (_isIOS ? _testBannerIOS : _testBannerAndroid) : _banner;

  static String get interstitial => kDebugMode
      ? (_isIOS ? _testInterstitialIOS : _testInterstitialAndroid)
      : _interstitial;

  static String get rewarded => kDebugMode
      ? (_isIOS ? _testRewardedIOS : _testRewardedAndroid)
      : _rewarded;

  static String get rewardedInterstitial => kDebugMode
      ? (_isIOS
            ? _testRewardedInterstitialIOS
            : _testRewardedInterstitialAndroid)
      : _rewardedInterstitial;

  static String get appOpen =>
      kDebugMode ? (_isIOS ? _testAppOpenIOS : _testAppOpenAndroid) : _appOpen;

  static String get nativeAdvanced => kDebugMode
      ? (_isIOS ? _testNativeIOS : _testNativeAndroid)
      : _nativeAdvanced;

  /// The native unit used by [NativeBannerAd]. iOS has a single native unit, so
  /// it reuses [nativeAdvanced]; Android has its own under publisher
  /// 7257176588145778.
  static String get nativeBanner => kDebugMode
      ? (_isIOS ? _testNativeIOS : _testNativeAndroid)
      : (_isIOS ? _nativeAdvanced : 'ca-app-pub-7257176588145778/6685582058');
}
