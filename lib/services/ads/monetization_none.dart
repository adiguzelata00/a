import '../monetization_service.dart';

/// Web: no ads.
MonetizationService createPlatformMonetization() =>
    const NoMonetizationService();
