import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_ids.dart';
import '../services/session_tracker.dart';
import '../services/singular_keys.dart';

class SimpleBannerAd extends StatefulWidget {
  const SimpleBannerAd({super.key});

  @override
  State<SimpleBannerAd> createState() => _SimpleBannerAdState();
}

class _SimpleBannerAdState extends State<SimpleBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  static String get _bannerAdUnitId => AdIds.banner;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdImpression: (ad) => SessionTracker().recordAdImpression(
          SingularAdFormats.banner,
          reportEvent: false,
        ),
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: $error');
          ad.dispose();
          _bannerAd = null;
          Future.delayed(const Duration(seconds: 30), () {
            if (mounted) _loadAd();
          });
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox(height: 50);
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
