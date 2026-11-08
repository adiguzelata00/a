import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hook for future ads / in-app purchases. NOTHING is implemented on
/// purpose: the game ships without ads or IAP. A real implementation can be
/// provided later by overriding [monetizationServiceProvider].
abstract class MonetizationService {
  /// Whether ads may be shown (e.g. false after a "remove ads" purchase).
  bool get adsEnabled;

  /// Optional rewarded ad (e.g. an extra reroll). Returns true if the
  /// reward was earned.
  Future<bool> showRewardedAd(String placement);

  /// Starts a purchase of [productId]. Returns true when completed.
  Future<bool> purchase(String productId);

  /// Restores earlier purchases (required on iOS).
  Future<void> restorePurchases();
}

/// Default: no ads, no purchases.
class NoMonetizationService implements MonetizationService {
  const NoMonetizationService();

  @override
  bool get adsEnabled => false;

  @override
  Future<bool> showRewardedAd(String placement) async => false;

  @override
  Future<bool> purchase(String productId) async => false;

  @override
  Future<void> restorePurchases() async {}
}

final monetizationServiceProvider = Provider<MonetizationService>(
  (ref) => const NoMonetizationService(),
);
