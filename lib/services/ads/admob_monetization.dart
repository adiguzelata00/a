import 'dart:async';
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tengri_taslari/data/ads_config.dart';

import '../monetization_service.dart';

/// Android/iOS: AdMob. Other io platforms (desktop, tests): no ads.
MonetizationService createPlatformMonetization() =>
    Platform.isAndroid || Platform.isIOS
    ? AdMobMonetizationService(
        interstitialId: AdsConfig.interstitialId(ios: Platform.isIOS),
      )
    : const NoMonetizationService();

/// Interstitial ads through Google Mobile Ads, with Google's consent form
/// (UMP) shown first where required (EEA, UK, ...). One ad is kept
/// preloaded so it shows without waiting after a boss.
class AdMobMonetizationService implements MonetizationService {
  AdMobMonetizationService({required this.interstitialId});

  final String interstitialId;

  Future<void>? _init;
  bool _ready = false;
  InterstitialAd? _ad;
  bool _loading = false;
  Timer? _retry;

  @override
  bool get adsEnabled => true;

  @override
  Future<void> initialize() => _init ??= _start();

  Future<void> _start() async {
    try {
      final updated = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
          if (!updated.isCompleted) updated.complete();
        },
        (_) {
          if (!updated.isCompleted) updated.complete();
        },
      );
      await updated.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () {},
      );
      if (!await ConsentInformation.instance.canRequestAds()) return;
      await MobileAds.instance.initialize();
      _ready = true;
      _load();
    } catch (_) {
      // No ads this session; the game goes on.
    }
  }

  void _load() {
    if (!_ready || _ad != null || _loading) return;
    _loading = true;
    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _ad = ad;
        },
        onAdFailedToLoad: (_) {
          _loading = false;
          // Offline or no fill: try again a bit later.
          _retry?.cancel();
          _retry = Timer(const Duration(seconds: 60), _load);
        },
      ),
    );
  }

  @override
  Future<void> showInterstitial(String placement) async {
    final ad = _ad;
    if (ad == null) {
      _load();
      return;
    }
    _ad = null;
    final closed = Completer<void>();
    void done(InterstitialAd a) {
      a.dispose();
      if (!closed.isCompleted) closed.complete();
      _load();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: done,
      onAdFailedToShowFullScreenContent: (a, _) => done(a),
    );
    try {
      await ad.show();
      await closed.future.timeout(const Duration(minutes: 3), onTimeout: () {});
    } catch (_) {
      done(ad);
    }
  }

  @override
  Future<bool> privacyOptionsRequired() async {
    try {
      return await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> showPrivacyOptions() async {
    try {
      await ConsentForm.showPrivacyOptionsForm((_) {});
    } catch (_) {}
  }

  // Not offered yet.
  @override
  Future<bool> showRewardedAd(String placement) async => false;

  @override
  Future<bool> purchase(String productId) async => false;

  @override
  Future<void> restorePurchases() async {}
}
