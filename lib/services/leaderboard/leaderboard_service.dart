import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/core/core.dart';

import 'leaderboard_platform.dart'
    if (dart.library.js_interop) 'leaderboard_web.dart';

/// One row of a daily leaderboard.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.name,
    required this.isMe,
    required this.floor,
    required this.score,
    required this.won,
    required this.finished,
  });

  /// Display name as this viewer sees it ("" if unknown).
  final String name;
  final bool isMe;
  final int floor;
  final int score;
  final bool won;

  /// The run is over (false = still climbing).
  final bool finished;

  /// Ranking: higher floor first, then higher total score.
  static int compare(LeaderboardEntry a, LeaderboardEntry b) {
    if (a.won != b.won) return a.won ? -1 : 1;
    final f = b.floor.compareTo(a.floor);
    return f != 0 ? f : b.score.compareTo(a.score);
  }
}

/// Daily challenge leaderboard backend.
///
/// The web build published on claude.ai uses the page's shared database
/// (see `leaderboard_web.dart` and the bridge in the page). Other builds
/// have none yet: an online backend (e.g. Firebase) can implement this
/// interface later and be provided through [leaderboardServiceProvider].
abstract class LeaderboardService {
  /// Whether rankings can be read in this build / view.
  Future<bool> isAvailable();

  /// Publishes this player's result for [date]. Returns true on success.
  Future<bool> submit(String date, DailyResult result);

  /// All results of [date], ranked best first; null when unavailable.
  Future<List<LeaderboardEntry>?> top(String date);
}

/// No backend: everything reports "unavailable".
class UnavailableLeaderboardService implements LeaderboardService {
  const UnavailableLeaderboardService();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<bool> submit(String date, DailyResult result) async => false;

  @override
  Future<List<LeaderboardEntry>?> top(String date) async => null;
}

final leaderboardServiceProvider = Provider<LeaderboardService>(
  (ref) => createPlatformLeaderboard(),
);

/// Ranked rows of a day (null = leaderboard unavailable here).
final dailyLeaderboardProvider = FutureProvider.autoDispose
    .family<List<LeaderboardEntry>?, String>((ref, date) async {
      final rows = await ref.watch(leaderboardServiceProvider).top(date);
      if (rows == null) return null;
      return [...rows]..sort(LeaderboardEntry.compare);
    });
