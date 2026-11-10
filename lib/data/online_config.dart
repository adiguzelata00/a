// Online services configuration (daily leaderboard on Firebase).
//
// The values below are not secrets: a Firebase Web API key only identifies
// the project; what anyone may read or write is decided by the Firestore
// security rules in `firebase/firestore.rules`. They can also be given at
// build time: --dart-define=FIREBASE_PROJECT_ID=... and
// --dart-define=FIREBASE_API_KEY=...

abstract final class OnlineConfig {
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  );

  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '',
  );

  /// The leaderboard is offline until both values are set.
  static bool get isConfigured =>
      firebaseProjectId.isNotEmpty && firebaseApiKey.isNotEmpty;
}
