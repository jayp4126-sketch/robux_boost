import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'singular_keys.dart';
import 'singular_service.dart';

/// Tracks how often the user comes back, how long they stay, and how many ads
/// they see, and reports it to Singular.
///
/// These are the signals Unity Ads needs to tell a user who installs and leaves
/// from one who keeps coming back — retention and time-in-app are what its
/// models optimise towards once the early-funnel events stop discriminating.
class SessionTracker with WidgetsBindingObserver {
  static final SessionTracker _instance = SessionTracker._internal();
  factory SessionTracker() => _instance;
  SessionTracker._internal();

  static const String _kSessionCount = 'sng_session_count';
  static const String _kLastSessionEnd = 'sng_last_session_end_epoch';
  static const String _kTotalPlaySeconds = 'sng_total_play_seconds';
  static const String _kTotalAdsSeen = 'sng_total_ads_seen';

  SharedPreferences? _prefs;
  DateTime? _sessionStart;

  /// Impressions counted since the current session began, by format.
  final Map<String, int> _sessionAdsByFormat = {};
  int _sessionAdsSeen = 0;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    WidgetsBinding.instance.addObserver(this);
    _startSession();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _startSession();
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _endSession();
      case AppLifecycleState.inactive:
        // Fires when an ad covers the app, which is not the user leaving.
        break;
    }
  }

  void _startSession() {
    if (_sessionStart != null) return;
    final prefs = _prefs;
    if (prefs == null) return;

    _sessionStart = DateTime.now();
    _sessionAdsSeen = 0;
    _sessionAdsByFormat.clear();

    final sessionNumber = (prefs.getInt(_kSessionCount) ?? 0) + 1;
    prefs.setInt(_kSessionCount, sessionNumber);

    final lastEndEpoch = prefs.getInt(_kLastSessionEnd);
    final hoursAway = lastEndEpoch == null
        ? 0
        : DateTime.now()
                .difference(DateTime.fromMillisecondsSinceEpoch(lastEndEpoch))
                .inMinutes /
            60;

    SingularService().logEventWithArgs(SingularEvents.sessionStart, {
      'session_number': sessionNumber,
      // 0 on the very first session; afterwards, how long the user stayed away.
      'hours_since_last_session': double.parse(hoursAway.toStringAsFixed(2)),
      'is_returning_user': sessionNumber > 1,
      'total_ads_seen': prefs.getInt(_kTotalAdsSeen) ?? 0,
    });
  }

  void _endSession() {
    final start = _sessionStart;
    final prefs = _prefs;
    if (start == null || prefs == null) return;
    _sessionStart = null;

    final durationSeconds = DateTime.now().difference(start).inSeconds;
    final totalPlaySeconds =
        (prefs.getInt(_kTotalPlaySeconds) ?? 0) + durationSeconds;

    prefs.setInt(_kTotalPlaySeconds, totalPlaySeconds);
    prefs.setInt(_kLastSessionEnd, DateTime.now().millisecondsSinceEpoch);

    SingularService().logEventWithArgs(SingularEvents.sessionEnd, {
      'duration_seconds': durationSeconds,
      'total_play_seconds': totalPlaySeconds,
      'ads_seen_in_session': _sessionAdsSeen,
      'banners_in_session': _sessionAdsByFormat[SingularAdFormats.banner] ?? 0,
      'native_in_session': _sessionAdsByFormat[SingularAdFormats.native] ?? 0,
    });
  }

  /// Called by [AdService] every time an ad is actually displayed.
  ///
  /// Banners and native ads refresh on their own and would flood the dashboard
  /// as individual events, so only full-screen formats are reported one by one.
  /// Every format still counts towards the session and lifetime totals.
  void recordAdImpression(String format, {required bool reportEvent}) {
    final prefs = _prefs;
    if (prefs == null) return;

    _sessionAdsSeen++;
    _sessionAdsByFormat[format] = (_sessionAdsByFormat[format] ?? 0) + 1;

    final totalAdsSeen = (prefs.getInt(_kTotalAdsSeen) ?? 0) + 1;
    prefs.setInt(_kTotalAdsSeen, totalAdsSeen);

    if (!reportEvent) return;
    SingularService().logEventWithArgs(SingularEvents.adImpression, {
      'format': format,
      'ads_seen_in_session': _sessionAdsSeen,
      'total_ads_seen': totalAdsSeen,
    });
  }
}
