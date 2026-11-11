import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/data/online_config.dart';

import '../settings_service.dart';
import '../storage.dart';
import 'firebase_leaderboard.dart';
import 'leaderboard_service.dart';

/// Non-web builds (Android, desktop): Firebase when it is configured
/// (see `OnlineConfig`), otherwise no leaderboard.
LeaderboardService createPlatformLeaderboard(Ref ref) {
  if (!OnlineConfig.isConfigured) return const UnavailableLeaderboardService();
  return FirebaseLeaderboardService(
    projectId: OnlineConfig.firebaseProjectId,
    apiKey: OnlineConfig.firebaseApiKey,
    store: ref.read(storageProvider),
    playerName: () => ref.read(settingsProvider).playerName,
  );
}
