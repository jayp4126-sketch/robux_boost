import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:singular_flutter_sdk/singular.dart';

/// Push notifications, via OneSignal.
///
/// Push is the main lever on retention, which is what decides whether bought
/// traffic pays for itself — so the device token is also handed to Singular,
/// which uses it to detect uninstalls. An install that is deleted on day one is
/// spend with nothing behind it, and without the token that stays invisible.
class PushService {
  static final PushService _instance = PushService._internal();
  factory PushService() => _instance;
  PushService._internal();

  /// From App Settings > Keys & IDs in the OneSignal dashboard.
  static const String appId = '104ec658-e6a1-4085-b017-e152cab5876d';

  static bool get isConfigured => appId.isNotEmpty;

  bool _isStarted = false;

  /// Whether the device is currently set to receive push.
  bool get isOptedIn => OneSignal.User.pushSubscription.optedIn ?? false;

  Future<void> initialize() async {
    if (_isStarted) return;

    if (!isConfigured) {
      debugPrint(
        'OneSignal: no App ID set in push_service.dart — skipping. '
        'Push notifications are disabled.',
      );
      return;
    }

    OneSignal.Debug.setLogLevel(
      kDebugMode ? OSLogLevel.verbose : OSLogLevel.none,
    );
    OneSignal.initialize(appId);
    _isStarted = true;

    // The token is not available immediately, and it changes — observe it
    // rather than reading it once.
    OneSignal.User.pushSubscription.addObserver((state) {
      final token = state.current.token;
      if (token != null && token.isNotEmpty) {
        _registerTokenWithSingular(token);
      }
    });

    final existingToken = OneSignal.User.pushSubscription.token;
    if (existingToken != null && existingToken.isNotEmpty) {
      _registerTokenWithSingular(existingToken);
    }

    // Asks the user for permission. On iOS this is a system prompt, so it is
    // deliberately not fired at the same moment as the ATT prompt — iOS shows
    // only one system dialog at a time and the second one would be dropped.
    await OneSignal.Notifications.requestPermission(false);
  }

  void _registerTokenWithSingular(String token) {
    if (Platform.isIOS) {
      Singular.registerDeviceTokenForUninstall(token);
    } else {
      Singular.setFCMDeviceToken(token);
    }
  }

  /// Turns push on or off for this device, for the settings screen.
  Future<void> setEnabled(bool enabled) async {
    if (!_isStarted) return;
    if (enabled) {
      await OneSignal.User.pushSubscription.optIn();
    } else {
      await OneSignal.User.pushSubscription.optOut();
    }
  }

  /// Tags drive segmentation in the OneSignal dashboard — they are what lets a
  /// campaign target only the users who asked for that kind of reminder.
  Future<void> setTag(String key, bool value) async {
    if (!_isStarted) return;
    await OneSignal.User.addTagWithKey(key, value.toString());
  }
}
