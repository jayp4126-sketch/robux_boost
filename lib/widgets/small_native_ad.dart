import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_ids.dart';
import '../services/session_tracker.dart';
import '../services/singular_keys.dart';

class SmallNativeAd extends StatefulWidget {
  const SmallNativeAd({super.key});

  @override
  State<SmallNativeAd> createState() => _SmallNativeAdState();
}

class _SmallNativeAdState extends State<SmallNativeAd> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  static String get _adUnitId => AdIds.nativeAdvanced;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: _adUnitId,
      listener: NativeAdListener(
        onAdImpression: (ad) => SessionTracker().recordAdImpression(
          SingularAdFormats.native,
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
          debugPrint('Small native ad failed to load: $error');
          ad.dispose();
          _nativeAd = null;
          Future.delayed(const Duration(seconds: 30), () {
            if (mounted) _loadAd();
          });
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: const Color(0xFF1A1A2E),
        cornerRadius: 15.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: const Color(0xFF7C3AED),
          style: NativeTemplateFontStyle.bold,
          size: 14.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          style: NativeTemplateFontStyle.bold,
          size: 14.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          style: NativeTemplateFontStyle.normal,
          size: 10.0,
        ),
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 320,
        minHeight: 90,
        maxWidth: 400,
        maxHeight: 200,
      ),
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
