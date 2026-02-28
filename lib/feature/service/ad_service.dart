import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  DateTime? _lastInterstitialShowTime;

  // Test Ad IDs (Official Google Test IDs)
  static String get bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }
    // Replace with real ID for production
    return Platform.isAndroid ? 'YOUR_ANDROID_BANNER_ID' : 'YOUR_IOS_BANNER_ID';
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) return 'ca-app-pub-3940256099942544/1033173712';
    return 'ca-app-pub-5476141804305525/5904472171';
  }

  Future<void> init() async {
    await MobileAds.instance.initialize();
    loadInterstitialAd();
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          debugPrint('Interstitial Ad Loaded');
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoaded = false;
          debugPrint('Interstitial Ad Failed to Load: $error');
        },
      ),
    );
  }

  void showInterstitialAd() {
    // Frequency capping: Don't show ads more than once every 2 minutes (10s in debug)
    if (_lastInterstitialShowTime != null) {
      final difference = DateTime.now().difference(_lastInterstitialShowTime!);
      final cooldown = kDebugMode
          ? const Duration(seconds: 10)
          : const Duration(minutes: 2);
      if (difference < cooldown) {
        debugPrint('Interstitial skip: Cooldown active');
        return;
      }
    }

    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isInterstitialAdLoaded = false;
          loadInterstitialAd(); // Load next ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isInterstitialAdLoaded = false;
          loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _lastInterstitialShowTime = DateTime.now();
    } else {
      debugPrint('Ad not ready yet');
      loadInterstitialAd();
    }
  }
}
