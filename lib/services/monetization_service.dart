import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ads/monetization_none.dart'
    if (dart.library.io) 'ads/admob_monetization.dart';

/// Ads and in-app purchases.
///
/// Android/iOS builds use AdMob (`ads/admob_monetization.dart`); the web
/// build and tests have none ([NoMonetizationService]).
abstract class MonetizationService {
  /// Whether ads may be shown (e.g. false after a "remove ads" purchase).
  bool get adsEnabled;

  /// Asks for ad consent where the law requires it and starts the ad SDK.
  /// Safe to call more than once.
  Future<void> initialize();

  /// Shows a full-screen ad between levels (after a boss). Completes when
  /// the ad is closed, or at once when no ad is ready: never blocks play.
  Future<void> showInterstitial(String placement);

  /// Whether the player must be able to reopen the ad consent choices
  /// (Settings shows a "Privacy options" button then).
  Future<bool> privacyOptionsRequired();

  /// Reopens the ad consent form.
  Future<void> showPrivacyOptions();

  /// Optional rewarded ad (e.g. an extra reroll). Returns true if the
  /// reward was earned.
  Future<bool> showRewardedAd(String placement);

  /// Starts a purchase of [productId]. Returns true when completed.
  Future<bool> purchase(String productId);

  /// Restores earlier purchases.
  Future<void> restorePurchases();
}

/// No ads, no purchases (web, desktop, tests).
class NoMonetizationService implements MonetizationService {
  const NoMonetizationService();

  @override
  bool get adsEnabled => false;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> showInterstitial(String placement) async {}

  @override
  Future<bool> privacyOptionsRequired() async => false;

  @override
  Future<void> showPrivacyOptions() async {}

  @override
  Future<bool> showRewardedAd(String placement) async => false;

  @override
  Future<bool> purchase(String productId) async => false;

  @override
  Future<void> restorePurchases() async {}
}

final monetizationServiceProvider = Provider<MonetizationService>(
  (ref) => createPlatformMonetization(),
);
