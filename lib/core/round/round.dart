import '../hands/hand_evaluator.dart';
import '../hands/hand_type.dart';
import '../rng/seeded_rng.dart';
import '../scoring/kut.dart';
import '../scoring/scoring_engine.dart';
import '../tiles/deck.dart';
import '../tiles/okey.dart';
import '../tiles/tile.dart';
import 'rack_sort.dart';
import 'round_rules.dart';

/// Base limits of a round (values from `lib/data/balance.dart`).
class RoundConfig {
  const RoundConfig({
    this.handSize = 10,
    this.hands = 4,
    this.discards = 3,
    this.maxTilesPerAction = 6,
  });

  final int handSize;
  final int hands;
  final int discards;
  final int maxTilesPerAction;
}

enum RoundPhase { playing, won, lost }

/// Why an action was rejected.
enum ActionError {
  roundOver,
  noSelection,
  tooManyTiles,
  invalidIndex,
  noHandsLeft,
  noDiscardsLeft,
}

class RoundActionException implements Exception {
  RoundActionException(this.error);
  final ActionError error;
  @override
  String toString() => 'RoundActionException(${error.name})';
}

/// Result of playing a hand.
class PlayOutcome {
  const PlayOutcome({
    required this.hand,
    required this.scoring,
    required this.scoreBefore,
    required this.scoreAfter,
    required this.drawn,
    this.stolen,
  });

  final HandResult hand;
  final ScoringResult scoring;
  final int scoreBefore;
  final int scoreAfter;
  final List<Tile> drawn;

  /// Tile stolen by "Al Karısı" after the hand (if any).
  final Tile? stolen;
}

/// Result of a discard.
class DiscardOutcome {
  const DiscardOutcome({required this.discarded, required this.drawn});
  final List<Tile> discarded;
  final List<Tile> drawn;

  /// Discarded tiles with a purple seal (each creates a Tılsım, Phase 3).
  List<Tile> get purpleSealed =>
      [for (final t in discarded) if (t.seal == Seal.purple) t];
}

/// Preview shown before playing ("Seri-4 — 45 × 4").
class HandPreview {
  const HandPreview(this.hand, this.chips, this.mult);
  final HandResult hand;
  final int chips;
  final int mult;
  HandType get type => hand.type;
}

/// State machine of a single round: draw, play, discard, win/lose.
///
/// Pure Dart: no Flutter, no I/O. All randomness comes from the [SeededRng]
/// passed in, so a round is fully reproducible.
class Round {
  Round({
    required List<Tile> deckTiles,
    required this.target,
    required SeededRng rng,
    required this.levels,
    this.config = const RoundConfig(),
    this.rules = RoundRules.normal,
    List<KutInstance> kuts = const [],
    this.isBossRound = false,
    this.tuning = const TileEffectTuning(),
    this.evaluator = const HandEvaluator(),
    this.engine = const ScoringEngine(),
  })  : _rng = rng,
        _kuts = List.of(kuts) {
    final shuffleRng = rng.fork('shuffle');
    _pile = DrawPile.shuffled(deckTiles, shuffleRng);
    // RULE DECISION: the indicator is removed from the pile for this round.
    // A fake okey can not be the indicator; the first real tile is used.
    final indicator = _pile.drawWhere((t) => !t.isFakeOkey);
    if (indicator == null) {
      throw StateError('Deck has no tile that can be an indicator');
    }
    okey = OkeyInfo(indicator: indicator, okeyIsWild: rules.okeyIsWild);

    var hands = config.hands;
    var discards = config.discards;
    for (final k in _kuts) {
      hands += k.behavior.handsDelta;
      discards += k.behavior.discardsDelta;
    }
    handsLeft = hands < 1 ? 1 : hands;
    discardsLeft = rules.noDiscards ? 0 : (discards < 0 ? 0 : discards);
    _rack.addAll(_pile.draw(config.handSize));
    _rollCountedColor();
  }

  final int target;
  final HandLevels levels;
  final RoundConfig config;
  final RoundRules rules;
  final bool isBossRound;
  final TileEffectTuning tuning;
  final HandEvaluator evaluator;
  final ScoringEngine engine;
  final SeededRng _rng;

  late final OkeyInfo okey;
  late final DrawPile _pile;
  final List<Tile> _rack = [];
  final List<Tile> _discardPile = [];
  final List<Tile> _destroyed = [];
  final Set<int> _faceDownIds = {};
  List<KutInstance> _kuts;

  int score = 0;
  late int handsLeft;
  late int discardsLeft;
  int handsPlayed = 0;
  int moneyEarned = 0;
  RoundPhase phase = RoundPhase.playing;

  /// Tepegöz: color counted in the current hand.
  TileColor? countedColor;

  /// Best single hand score of the round.
  int bestHandScore = 0;

  List<Tile> get rack => List.unmodifiable(_rack);
  List<Tile> get discardPile => List.unmodifiable(_discardPile);
  int get drawPileCount => _pile.remaining;
  List<KutInstance> get kuts => List.unmodifiable(_kuts);

  /// Tiles destroyed this round (crystal shatters); remove from run deck.
  List<Tile> get destroyedTiles => List.unmodifiable(_destroyed);

  int get maxTilesPerPlay =>
      rules.maxTilesPerPlay ?? config.maxTilesPerAction;

  bool isFaceDown(int rackIndex) => _faceDownIds.contains(_rack[rackIndex].id);

  /// Reveals a face-down tile (Yel Ana).
  void reveal(int rackIndex) => _faceDownIds.remove(_rack[rackIndex].id);

  /// Moves a tile inside the rack (drag & drop).
  void moveTile(int from, int to) {
    if (from < 0 || from >= _rack.length || to < 0 || to >= _rack.length) {
      throw RoundActionException(ActionError.invalidIndex);
    }
    final tile = _rack.removeAt(from);
    _rack.insert(to, tile);
  }

  void sortRackByNumber() => _replaceRack(sortByNumber(_rack, okey));
  void sortRackByColor() => _replaceRack(sortByColor(_rack, okey));

  void _replaceRack(List<Tile> sorted) {
    _rack
      ..clear()
      ..addAll(sorted);
  }

  /// Hand preview for the selected rack indices (no side effects).
  HandPreview? preview(List<int> rackIndices) {
    if (rackIndices.isEmpty) return null;
    final played = _selected(rackIndices, maxTilesPerPlay);
    final hand = evaluator.evaluate(played, okey, levels)!;
    return HandPreview(hand, levels.chipsOf(hand.type), levels.multOf(hand.type));
  }

  /// Full scoring simulation of a selection without changing any state
  /// (no crystal shatter, Kut state untouched). Used by AI / tooling.
  ScoringResult simulate(List<int> rackIndices) {
    final played = _selected(rackIndices, maxTilesPerPlay);
    final hand = evaluator.evaluate(played, okey, levels)!;
    return engine.score(_scoringInput(hand, rackIndices, rng: null));
  }

  /// Plays the selected tiles ("Oyna").
  PlayOutcome play(List<int> rackIndices) {
    _ensurePlaying();
    if (handsLeft <= 0) throw RoundActionException(ActionError.noHandsLeft);
    final played = _selected(rackIndices, maxTilesPerPlay);
    final hand = evaluator.evaluate(played, okey, levels)!;

    final result = engine.score(
      _scoringInput(hand, rackIndices, rng: _rng.fork('hand$handsPlayed')),
    );

    final before = score;
    score += result.score;
    if (result.score > bestHandScore) bestHandScore = result.score;
    moneyEarned += result.moneyEarned;
    _kuts = result.updatedKuts;
    handsLeft--;
    handsPlayed++;

    final playedIds = {for (final t in played) t.id};
    _rack.removeWhere((t) => playedIds.contains(t.id));
    _faceDownIds.removeAll(playedIds);
    final brokenIds = {for (final t in result.brokenTiles) t.id};
    for (final t in played) {
      (brokenIds.contains(t.id) ? _destroyed : _discardPile).add(t);
    }

    final drawn = <Tile>[];
    Tile? stolen;
    if (score >= target) {
      phase = RoundPhase.won;
    } else if (handsLeft <= 0) {
      phase = RoundPhase.lost;
    } else {
      drawn.addAll(_refill());
      stolen = _applyAfterHandRules();
      _rollCountedColor();
      if (_rack.isEmpty) phase = RoundPhase.lost; // deck exhausted
    }

    return PlayOutcome(
      hand: hand,
      scoring: result,
      scoreBefore: before,
      scoreAfter: score,
      drawn: drawn,
      stolen: stolen,
    );
  }

  /// Discards the selected tiles and draws replacements ("Değiştir").
  DiscardOutcome discard(List<int> rackIndices) {
    _ensurePlaying();
    if (discardsLeft <= 0) throw RoundActionException(ActionError.noDiscardsLeft);
    final tiles = _selected(rackIndices, config.maxTilesPerAction);
    discardsLeft--;
    final ids = {for (final t in tiles) t.id};
    _rack.removeWhere((t) => ids.contains(t.id));
    _faceDownIds.removeAll(ids);
    _discardPile.addAll(tiles);
    for (final k in _kuts) {
      k.behavior.onDiscard(k, tiles);
    }
    return DiscardOutcome(discarded: tiles, drawn: _refill());
  }

  /// Round-end money from Kuts and gold tiles held in the rack.
  /// Call once after the round is won.
  int roundEndMoney() {
    final info = RoundEndInfo(
      handsLeft: handsLeft,
      discardsLeft: discardsLeft,
      isBossRound: isBossRound,
    );
    var money = 0;
    for (final k in _kuts) {
      money += k.behavior.roundEndMoney(k, info);
    }
    for (final t in _rack) {
      if (t.enhancement == Enhancement.gold) {
        money += tuning.goldTileRoundEndMoney;
      }
    }
    return money;
  }

  ScoringInput _scoringInput(HandResult hand, List<int> rackIndices,
      {required SeededRng? rng}) {
    final selected = rackIndices.toSet();
    final held = [
      for (var i = 0; i < _rack.length; i++)
        if (!selected.contains(i)) _rack[i],
    ];
    return ScoringInput(
      hand: hand,
      heldTiles: held,
      levels: levels,
      kuts: _kuts,
      rules: rules,
      tuning: tuning,
      handsLeft: handsLeft - 1,
      discardsLeft: discardsLeft,
      handNumber: handsPlayed,
      isBossRound: isBossRound,
      countedColor: countedColor,
      rng: rng,
    );
  }

  List<Tile> _refill() {
    final drawn = _pile.draw(config.handSize - _rack.length);
    _rack.addAll(drawn);
    return drawn;
  }

  Tile? _applyAfterHandRules() {
    Tile? stolen;
    final rng = _rng.fork('boss$handsPlayed');
    if (rules.stealTileAfterHand && _rack.isNotEmpty) {
      stolen = _rack.removeAt(rng.nextInt(_rack.length));
      _discardPile.add(stolen);
    }
    if (rules.shuffleAndHideAfterHand) {
      rng.shuffle(_rack);
      _faceDownIds
        ..clear()
        ..addAll(_rack.map((t) => t.id));
    }
    return stolen;
  }

  void _rollCountedColor() {
    if (!rules.singleColorPerHand) return;
    countedColor =
        _rng.fork('color$handsPlayed').pick(TileColor.values);
  }

  /// Validated, rack-ordered (left to right) selection.
  List<Tile> _selected(List<int> rackIndices, int max) {
    if (rackIndices.isEmpty) throw RoundActionException(ActionError.noSelection);
    final unique = rackIndices.toSet().toList()..sort();
    if (unique.length != rackIndices.length ||
        unique.first < 0 ||
        unique.last >= _rack.length) {
      throw RoundActionException(ActionError.invalidIndex);
    }
    if (unique.length > max) throw RoundActionException(ActionError.tooManyTiles);
    return [for (final i in unique) _rack[i]];
  }

  void _ensurePlaying() {
    if (phase != RoundPhase.playing) {
      throw RoundActionException(ActionError.roundOver);
    }
  }
}
