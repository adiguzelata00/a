// AdMob configuration (these ids are not secrets: they are in every app).
//
// App id: android/app/src/main/AndroidManifest.xml
// (com.google.android.gms.ads.APPLICATION_ID) = ca-app-pub-7273709401055080~2304804446
//
// Builds that are only for testing (the APK built by GitHub Actions) pass
// --dart-define=ADMOB_TEST_ADS=true and show Google's sample "Test Ad"s:
// never click real ads of your own app, AdMob closes accounts for it.
// The store build (no flag) shows real ads.

abstract final class AdsConfig {
  /// "boss_sonrasi": interstitial after every boss victory (Android).
  static const bossInterstitialAndroid =
      'ca-app-pub-7273709401055080/3969560705';

  /// Google's sample interstitial units.
  static const testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';

  static const bool useTestAds = bool.fromEnvironment('ADMOB_TEST_ADS');

  /// Interstitial unit to load. iOS has no real unit yet: test ads only.
  static String interstitialId({required bool ios}) {
    if (ios) return testInterstitialIos;
    return useTestAds ? testInterstitialAndroid : bossInterstitialAndroid;
  }
}
