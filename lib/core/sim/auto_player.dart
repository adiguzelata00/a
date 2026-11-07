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
      final toss = _leastConnected(round.rack, round.okey, round.config.maxTilesPerAction);
      if (toss.isNotEmpty) return AutoAction.discard(toss);
    }
    return AutoAction.play(best);
  }

  /// Exhaustive search over all selections of 1..maxTilesPerPlay tiles.
  List<int> bestPlay(Round round) {
    final n = round.rack.length;
    final maxK = round.maxTilesPerPlay < n ? round.maxTilesPerPlay : n;
    List<int> best = const [0];
    var bestScore = -1;
    var bestSize = 0;
    void visit(int start, List<int> current) {
      if (current.isNotEmpty) {
        final s = round.simulate(current).score;
        // Prefer higher score, then fewer tiles (keeps tiles for later).
        if (s > bestScore || (s == bestScore && current.length < bestSize)) {
          bestScore = s;
          bestSize = current.length;
          best = List.of(current);
        }
      }
      if (current.length == maxK) return;
      for (var i = start; i < n; i++) {
        current.add(i);
        visit(i + 1, current);
        current.removeLast();
      }
    }

    visit(0, []);
    return best;
  }

  List<int> _leastConnected(List<Tile> rack, OkeyInfo okey, int max) {
    int connections(int i) {
      final t = rack[i];
      if (okey.isWild(t)) return 99;
      final f = okey.faceOf(t);
      var c = 0;
      for (var j = 0; j < rack.length; j++) {
        if (j == i) continue;
        final o = rack[j];
        if (okey.isWild(o)) {
          c++;
          continue;
        }
        final g = okey.faceOf(o);
        final sameColorNear = g.color == f.color && (g.number - f.number).abs() <= 2;
        final sameNumber = g.number == f.number;
        if (sameColorNear || sameNumber) c++;
      }
      return c;
    }

    final lonely = [
      for (var i = 0; i < rack.length; i++)
        if (connections(i) == 0) i,
    ];
    return lonely.take(max).toList();
  }
}
