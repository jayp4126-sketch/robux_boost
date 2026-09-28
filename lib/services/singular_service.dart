import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:singular_flutter_sdk/singular.dart';
import 'package:singular_flutter_sdk/singular_ad_data.dart';
import 'package:singular_flutter_sdk/singular_config.dart';

import 'singular_keys.dart';

/// Attribution and user-acquisition measurement.
///
/// Singular tells us which campaign an install came from and feeds post-install
/// events back to the ad networks we buy on (Unity Ads), which is what their
/// optimisation models train against. Nothing here affects the app's own AdMob
/// monetisation.
class SingularService {
  static final SingularService _instance = SingularService._internal();
  factory SingularService() => _instance;
  SingularService._internal();

  bool _isStarted = false;

  /// Starts the SDK. Safe to call more than once.
  ///
  /// Called as early as possible so the install session is captured on a cold
  /// start. On iOS the SDK is configured to hold that first session for up to
  /// 5 minutes waiting for the App Tracking Transparency answer, so the install
  /// is reported with the IDFA when the user allows it — without that consent
  /// Unity Ads installs can only be attributed through SKAdNetwork, which is
  /// aggregated and delayed.
  ///
  /// The prompt itself is deliberately *not* raised here; see
  /// [requestTrackingAuthorization].
  Future<void> initialize() async {
    if (_isStarted) return;

    if (!SingularKeys.isConfigured) {
      debugPrint(
        'Singular: no API key/secret set in singular_config.dart — skipping. '
        'Attribution and UA measurement are disabled.',
      );
      return;
    }

    final config = SingularConfig(SingularKeys.apiKey, SingularKeys.apiSecret)
      ..skAdNetworkEnabled = true
      ..enableLogging = kDebugMode;

    if (Platform.isIOS) {
      // Hold the first session until the ATT prompt is answered, so the install
      // carries the IDFA when the user allows it.
      config.waitForTrackingAuthorizationWithTimeoutInterval = 300;
    }

    Singular.start(config);
    _isStarted = true;
  }

  /// Raises the App Tracking Transparency prompt, on iOS only.
  ///
  /// Must be called with the app already on screen and active. Apple requires
  /// `UIApplicationStateActive` for this request: fired from `main()` during
  /// launch it is answered with the current status and the dialog never
  /// appears, which leaves the status at `notDetermined`, costs us the IDFA,
  /// and makes Singular sit out its full `waitForTrackingAuthorization` timeout
  /// before reporting the install.
  ///
  /// Awaited by the caller so the next system dialog (push) can follow: iOS
  /// shows one at a time and silently drops the second.
  Future<void> requestTrackingAuthorization() async {
    if (!Platform.isIOS) return;

    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status != TrackingStatus.notDetermined) return;

      // The first frame has been submitted by the time this runs, but the scene
      // still needs a moment to reach the active state.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await AppTrackingTransparency.requestTrackingAuthorization();
    } catch (e) {
      debugPrint('Singular: ATT request failed: $e');
    }
  }

  void logEvent(String name) {
    if (!_isStarted) return;
    Singular.event(name);
  }

  void logEventWithArgs(String name, Map<String, dynamic> args) {
    if (!_isStarted) return;
    Singular.eventWithArgs(name, args);
  }

  /// Reports the revenue of a single ad impression.
  ///
  /// This is what makes ROAS measurable: without per-impression revenue,
  /// Singular can report installs but not whether a campaign paid for itself.
  void logAdRevenue({
    required double revenue,
    required String currencyCode,
  }) {
    if (!_isStarted || revenue <= 0) return;
    Singular.adRevenue(
      SingularAdData(SingularEvents.adRevenuePlatform, currencyCode, revenue),
    );
  }
}
