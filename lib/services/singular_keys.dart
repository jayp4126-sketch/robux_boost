/// Singular credentials, from Developer Tools > SDK Integration > SDK Keys in
/// the Singular dashboard.
///
/// These are the SDK Key and SDK Secret — not the Reporting API Key, which is a
/// server-side credential and must never ship inside the app.
class SingularKeys {
  const SingularKeys._();

  static const String apiKey = 'galinikaion_4ac86a9f';
  static const String apiSecret = '25d8fb8544e99f53568c23de3d1e163e';

  static bool get isConfigured => apiKey.isNotEmpty && apiSecret.isNotEmpty;
}

/// Event names reported to Singular.
///
/// Singular matches these against the events configured in the dashboard, and
/// Unity Ads optimises campaigns against whichever ones are mapped there, so
/// the strings have to stay stable once a campaign is live. Renaming one resets
/// the optimisation model.
class SingularEvents {
  const SingularEvents._();

  /// The user finished watching a rewarded ad — the core engagement signal.
  static const String rewardedAdCompleted = 'rewarded_ad_completed';

  /// One round of any mini game was completed. Carries `total_games_played`.
  static const String gamePlayed = 'game_played';

  /// The very first round, fired once per install. The usual early-funnel
  /// optimisation target, because it arrives soon enough after install for a
  /// network to learn from.
  static const String firstGamePlayed = 'first_game_played';

  /// Coins were awarded. Carries `amount` and `source`.
  static const String rewardClaimed = 'reward_claimed';

  /// A redemption was confirmed — the deepest point of the funnel, and the
  /// strongest signal of a valuable user.
  static const String redeemRequested = 'redeem_requested';

  /// The user entered the app — cold start or return from the background.
  /// Carries `session_number`, `hours_since_last_session` and
  /// `is_returning_user`, which is how retention is measured.
  static const String sessionStart = 'session_start';

  /// The user left the app. Carries `duration_seconds` and the running
  /// `total_play_seconds`.
  static const String sessionEnd = 'session_end';

  /// A full-screen ad was displayed. Carries `format` and the running counts.
  static const String adImpression = 'ad_impression';

  /// Ad platform label sent alongside impression revenue.
  static const String adRevenuePlatform = 'AdMob';
}

/// Values sent as the `format` argument of [SingularEvents.adImpression].
class SingularAdFormats {
  const SingularAdFormats._();

  static const String banner = 'banner';
  static const String native = 'native';
  static const String interstitial = 'interstitial';
  static const String rewarded = 'rewarded';
  static const String appOpen = 'app_open';
}
