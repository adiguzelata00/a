import 'leaderboard_service.dart';

/// Non-web builds: no leaderboard backend yet.
LeaderboardService createPlatformLeaderboard() =>
    const UnavailableLeaderboardService();
