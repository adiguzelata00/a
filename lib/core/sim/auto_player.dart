import '../hands/hand_evaluator.dart';
import '../round/round.dart';
import '../tiles/okey.dart';
import '../tiles/tile.dart';

/// A decision of the [AutoPlayer].
class AutoAction {
  const AutoAction.play(this.indices) : isDiscard = false;
  const AutoAction.discard(this.indices) : isDiscard = true;
  final bool isDiscard;
  final List<int> indices;
}

/// Simple greedy bot used for console simulation and balance experiments.
///
/// It plays the selection with the highest simulated score (including Kuts
/// and held effects). If that hand is weak and discards are available it
/// throws away the tiles least connected to the rest of the rack.
class AutoPlayer {
  const AutoPlayer({this.weakScoreRatio = 1.0});

  /// A hand is "weak" when it scores less than this share of the points
  /// still needed per remaining hand.
  final double weakScoreRatio;

  AutoAction decide(Round round) {
    final best = bestPlay(round);
    final needed = (round.target - round.score) / round.handsLeft;
    final bestScore = round.simulate(best).score;
    if (round.discardsLeft > 0 &&
        round.handsLeft > 1 &&
        bestScore < needed * weakScoreRatio &&
        round.drawPileCount > 0) {
      final toss = _leastConnected(
        round.rack,
        round.okey,
        round.config.maxTilesPerAction - 1,
        keep: best.length > 1 ? best.toSet() : const {},
      );
      if (toss.isNotEmpty) return AutoAction.discard(toss);
    }
    return AutoAction.play(best);
  }

  /// Best selection among all exact melds and single tiles, scored with
  /// the full engine (Kuts, held effects, boss rules).
  List<int> bestPlay(Round round) {
    final candidates = const HandEvaluator().meldCandidates(
      round.rack,
      round.okey,
      maxSize: round.maxTilesPerPlay,
    );
    List<int> best = const [0];
    var bestScore = -1;
    var bestSize = 0;
    for (final c in candidates) {
      final s = round.simulate(c).score;
      // Prefer higher score, then fewer tiles (keeps tiles for later).
      if (s > bestScore || (s == bestScore && c.length < bestSize)) {
        bestScore = s;
        bestSize = c.length;
        best = c;
      }
    }
    return best;
  }

  /// Tiles worth throwing away: not wild, not in [keep], and with at most
  /// one neighbour (same color within 2, or same number) in the rack.
  /// Weakest first, at most [max].
  List<int> _leastConnected(
    List<Tile> rack,
    OkeyInfo okey,
    int max, {
    Set<int> keep = const {},
  }) {
    int connections(int i) {
      final f = okey.faceOf(rack[i]);
      var c = 0;
      for (var j = 0; j < rack.length; j++) {
        if (j == i || okey.isWild(rack[j])) continue;
        final g = okey.faceOf(rack[j]);
        final sameColorNear =
            g.color == f.color && (g.number - f.number).abs() <= 2;
        if (sameColorNear || g.number == f.number) c++;
      }
      return c;
    }

    final scored = [
      for (var i = 0; i < rack.length; i++)
        if (!okey.isWild(rack[i]) && !keep.contains(i)) (i, connections(i)),
    ]..sort((a, b) => a.$2.compareTo(b.$2));
    return [
      for (final (i, c) in scored)
        if (c <= 1) i,
    ].take(max).toList();
  }
}
