import 'daily.dart';
import 'run_state.dart';

/// Persistent player profile across runs: Kut collection and records.
class Profile {
  Profile({
    Set<String>? discoveredKuts,
    Set<String>? seenBosses,
    this.runsStarted = 0,
    this.runsWon = 0,
    this.bestHand = 0,
    this.highestFloor = 0,
    Map<String, DailyResult>? dailyResults,
  }) : discoveredKuts = discoveredKuts ?? {},
       seenBosses = seenBosses ?? {},
       dailyResults = dailyResults ?? {};

  /// Daily challenge results by date (yyyy-MM-dd).
  final Map<String, DailyResult> dailyResults;

  /// Stores the current state of a daily run. Returns true if changed.
  bool recordDaily(RunState run) {
    final date = run.dailyDate;
    if (date == null) return false;
    final next = DailyResult.of(run);
    final prev = dailyResults[date];
    if (prev != null &&
        prev.floor == next.floor &&
        prev.score == next.score &&
        prev.won == next.won &&
        prev.finished == next.finished) {
      return false;
    }
    dailyResults[date] = next;
    return true;
  }

  /// Kuts the player has owned at least once ("açılan Kut'lar").
  final Set<String> discoveredKuts;

  /// Bosses the player has met.
  final Set<String> seenBosses;
  int runsStarted;
  int runsWon;
  int bestHand;
  int highestFloor;

  /// Records what [run] has revealed so far. Returns true if anything changed.
  bool observe(RunState run) {
    var changed = false;
    for (final k in run.kuts) {
      changed |= discoveredKuts.add(k.id);
    }
    if (run.phase != RunPhase.won || run.endless) {
      // The current floor's boss is visible on the round select screen.
      changed |= seenBosses.add(run.boss.id);
    }
    if (run.stats.bestHand > bestHand) {
      bestHand = run.stats.bestHand;
      changed = true;
    }
    if (run.floor > highestFloor) {
      highestFloor = run.floor;
      changed = true;
    }
    return changed;
  }

  Map<String, Object?> toJson() => {
    'kuts': discoveredKuts.toList()..sort(),
    'bosses': seenBosses.toList()..sort(),
    'started': runsStarted,
    'won': runsWon,
    'best': bestHand,
    'floor': highestFloor,
    'daily': {for (final e in dailyResults.entries) e.key: e.value.toJson()},
  };

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
    discoveredKuts: {
      for (final k in (j['kuts'] as List? ?? const [])) k as String,
    },
    seenBosses: {
      for (final b in (j['bosses'] as List? ?? const [])) b as String,
    },
    runsStarted: j['started'] as int? ?? 0,
    runsWon: j['won'] as int? ?? 0,
    bestHand: j['best'] as int? ?? 0,
    highestFloor: j['floor'] as int? ?? 0,
    dailyResults: {
      for (final e in Map<String, dynamic>.from(
        j['daily'] as Map? ?? const {},
      ).entries)
        e.key: DailyResult.fromJson(Map<String, dynamic>.from(e.value as Map)),
    },
  );
}
