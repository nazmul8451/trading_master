import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _riskAd;
  InterstitialAd? _moneyAd;
  bool _isRiskLoaded = false;
  bool _isMoneyLoaded = false;
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

  static String get riskInterstitialId {
    if (kDebugMode) return 'ca-app-pub-3940256099942544/1033173712';
    return 'ca-app-pub-5476141804305525/4544598552';
  }

  static String get moneyInterstitialId {
    if (kDebugMode) return 'ca-app-pub-3940256099942544/1033173712';
    return 'ca-app-pub-5476141804305525/5904472171';
  }

  Future<void> init() async {
    await MobileAds.instance.initialize();
    loadRiskAd();
    loadMoneyAd();
  }

  void loadRiskAd() {
    InterstitialAd.load(
      adUnitId: riskInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _riskAd = ad;
          _isRiskLoaded = true;
          debugPrint('Risk Interstitial Loaded');
        },
        onAdFailedToLoad: (error) {
          _isRiskLoaded = false;
          debugPrint('Risk Interstitial Failed to Load: $error');
        },
      ),
    );
  }

  void loadMoneyAd() {
    InterstitialAd.load(
      adUnitId: moneyInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _moneyAd = ad;
          _isMoneyLoaded = true;
          debugPrint('Money Interstitial Loaded');
        },
        onAdFailedToLoad: (error) {
          _isMoneyLoaded = false;
          debugPrint('Money Interstitial Failed to Load: $error');
        },
      ),
    );
  }

  void showInterstitialAd({bool isRiskType = false}) {
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

    final isLoaded = isRiskType ? _isRiskLoaded : _isMoneyLoaded;
    final ad = isRiskType ? _riskAd : _moneyAd;

    if (isLoaded && ad != null) {
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (a) {
          a.dispose();
          if (isRiskType) {
            _isRiskLoaded = false;
            loadRiskAd();
          } else {
            _isMoneyLoaded = false;
            loadMoneyAd();
          }
        },
        onAdFailedToShowFullScreenContent: (a, error) {
          a.dispose();
          if (isRiskType) {
            _isRiskLoaded = false;
            loadRiskAd();
          } else {
            _isMoneyLoaded = false;
            loadMoneyAd();
          }
        },
      );
      ad.show();
      _lastInterstitialShowTime = DateTime.now();
    } else {
      debugPrint('Ad not ready yet');
      isRiskType ? loadRiskAd() : loadMoneyAd();
    }
  }
}
