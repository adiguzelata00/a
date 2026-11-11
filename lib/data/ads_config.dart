// AdMob configuration.
//
// The defaults are Google's public TEST ids: they always show a "Test Ad"
// and never pay. Real ids (from the AdMob console) can be given at build
// time: --dart-define=ADMOB_INTERSTITIAL_ID=ca-app-pub-.../...
// The Android app id must also be set in AndroidManifest.xml
// (com.google.android.gms.ads.APPLICATION_ID) and on iOS in Info.plist
// (GADApplicationIdentifier).

abstract final class AdsConfig {
  /// Google's sample interstitial unit (Android).
  static const testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';

  /// Google's sample interstitial unit (iOS).
  static const testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';

  static const String _interstitialId = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ID',
  );

  /// Interstitial shown after every boss victory.
  static String interstitialId({required bool ios}) =>
      _interstitialId.isNotEmpty
      ? _interstitialId
      : (ios ? testInterstitialIos : testInterstitialAndroid);
}
