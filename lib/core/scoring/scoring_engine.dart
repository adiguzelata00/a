import '../hands/hand_evaluator.dart';
import '../hands/hand_type.dart';
import '../rng/seeded_rng.dart';
import '../round/round_rules.dart';
import '../tiles/tile.dart';
import 'kut.dart';
import 'score_event.dart';

/// Numbers for tile enhancements and seals (values come from
/// `lib/data/balance.dart`).
class TileEffectTuning {
  const TileEffectTuning({
    this.boneChips = 30,
    this.ironXMult = 1.5,
    this.crystalXMult = 2.0,
    this.crystalBreakChance = 0.25,
    this.goldSealMoney = 3,
    this.goldTileRoundEndMoney = 3,
  });

  final int boneChips;
  final double ironXMult;
  final double crystalXMult;
  final double crystalBreakChance;
  final int goldSealMoney;
  final int goldTileRoundEndMoney;
}

/// Everything needed to score one played hand.
class ScoringInput {
  const ScoringInput({
    required this.hand,
    required this.heldTiles,
    required this.levels,
    this.kuts = const [],
    this.rules = RoundRules.normal,
    this.tuning = const TileEffectTuning(),
    this.handsLeft = 0,
    this.discardsLeft = 0,
    this.handNumber = 0,
    this.isBossRound = false,
    this.countedColor,
    this.rng,
  });

  final HandResult hand;
  final List<Tile> heldTiles;
  final HandLevels levels;
  final List<KutInstance> kuts;
  final RoundRules rules;
  final TileEffectTuning tuning;

  /// Hands remaining *after* this one.
  final int handsLeft;
  final int discardsLeft;

  /// 0-based index of this hand within the round.
  final int handNumber;
  final bool isBossRound;

  /// Tepegöz: only counted tiles matching this color score (null = all).
  final TileColor? countedColor;

  /// Used for random effects (crystal shatter). `null` = preview mode:
  /// no random effect happens.
  final SeededRng? rng;
}

/// Output of [ScoringEngine.score].
class ScoringResult {
  const ScoringResult({
    required this.handType,
    required this.chips,
    required this.mult,
    required this.score,
    required this.moneyEarned,
    required this.events,
    required this.brokenTiles,
    required this.updatedKuts,
  });

  final HandType handType;
  final double chips;
  final double mult;

  /// Final score of the hand: floor(chips × mult) after boss rules.
  final int score;
  final int moneyEarned;
  final List<ScoreEvent> events;

  /// Crystal tiles that shattered (to be removed from the run deck).
  final List<Tile> brokenTiles;

  /// Copies of the input Kuts with updated state. The caller decides whether
  /// to commit them (real play) or drop them (preview).
  final List<KutInstance> updatedKuts;
}

/// Pure scoring pipeline. See [KutBehavior] for the exact trigger order.
///
/// RULE DECISIONS:
/// * Effects are applied strictly in trigger order (+mult and ×mult are
///   interleaved), which is what makes Kut ordering meaningful.
/// * Per-tile Kut reactions ("each red tile counted ...") fire as part of
///   the tile's trigger (step 2), hand-level Kut effects fire in step 4.
/// * A crystal tile rolls for shattering once per hand, after its triggers.
class ScoringEngine {
  const ScoringEngine();

  ScoringResult score(ScoringInput input) {
    final acc = _Accumulator(input);
    final hand = input.hand;
    final kuts = [for (final k in input.kuts) k.copy()];

    acc.chips = input.levels.chipsOf(hand.type).toDouble();
    acc.mult = input.levels.multOf(hand.type).toDouble();
    acc.emit(ScoreEventKind.handBase, ScoreSourceKind.hand, -1, acc.chips);

    final contexts = [
      for (var i = 0; i < kuts.length; i++) _KutCtx(acc, kuts[i], i),
    ];

    // 1. State updates before scoring.
    for (final ctx in contexts) {
      ctx.self.behavior.beforeScoring(ctx);
    }

    // 2. Counted tiles, left to right.
    final broken = <Tile>[];
    for (var pos = 0; pos < hand.counted.length; pos++) {
      final tile = hand.counted[pos];
      final idx = tile.playedIndex;
      if (input.countedColor != null && !tile.matchesColor(input.countedColor!)) {
        acc.emit(ScoreEventKind.tileDebuffed, ScoreSourceKind.playedTile, idx, 0);
        continue;
      }
      var triggers = 1;
      if (tile.tile.seal == Seal.crimson) triggers++;
      for (final ctx in contexts) {
        triggers += ctx.self.behavior.extraTileTriggers(ctx, tile, pos);
      }
      for (var t = 0; t < triggers; t++) {
        if (t > 0) {
          acc.emit(ScoreEventKind.retrigger, ScoreSourceKind.playedTile, idx, t);
        }
        _scoreCountedTile(acc, tile, contexts);
      }
      if (tile.tile.enhancement == Enhancement.crystal &&
          input.rng != null &&
          input.rng!.chance(input.tuning.crystalBreakChance)) {
        broken.add(tile.tile);
        acc.emit(ScoreEventKind.tileBroken, ScoreSourceKind.playedTile, idx, 0);
      }
    }

    // 3. Held tiles, left to right.
    for (var h = 0; h < input.heldTiles.length; h++) {
      final tile = input.heldTiles[h];
      final triggers = tile.seal == Seal.crimson ? 2 : 1;
      for (var t = 0; t < triggers; t++) {
        if (tile.enhancement == Enhancement.iron) {
          if (t > 0) {
            acc.emit(ScoreEventKind.retrigger, ScoreSourceKind.heldTile, h, t);
          }
          acc.multiplyMult(input.tuning.ironXMult, ScoreSourceKind.heldTile, h);
        }
        for (final ctx in contexts) {
          ctx.self.behavior.onHeldTile(ctx, tile);
        }
      }
    }

    // 4. Kut hand effects, left to right.
    for (final ctx in contexts) {
      ctx.self.behavior.onHandScored(ctx);
    }

    // 5. Final score + boss rules.
    var score = (acc.chips * acc.mult).floor();
    if (hand.type.isRun && input.rules.runScoreFactor != 1.0) {
      score = (score * input.rules.runScoreFactor).floor();
      acc.emit(ScoreEventKind.bossPenalty, ScoreSourceKind.boss, -1,
          input.rules.runScoreFactor);
    }
    if (input.rules.firstHandScoresZero && input.handNumber == 0) {
      score = 0;
      acc.emit(ScoreEventKind.bossPenalty, ScoreSourceKind.boss, -1, 0);
    }

    return ScoringResult(
      handType: hand.type,
      chips: acc.chips,
      mult: acc.mult,
      score: score,
      moneyEarned: acc.money,
      events: List.unmodifiable(acc.events),
      brokenTiles: broken,
      updatedKuts: kuts,
    );
  }

  void _scoreCountedTile(
    _Accumulator acc,
    CountedTile tile,
    List<_KutCtx> contexts,
  ) {
    final idx = tile.playedIndex;
    final tuning = acc.input.tuning;
    acc.addChips(tile.chipValue, ScoreSourceKind.playedTile, idx);
    switch (tile.tile.enhancement) {
      case Enhancement.bone:
        acc.addChips(tuning.boneChips, ScoreSourceKind.playedTile, idx);
      case Enhancement.crystal:
        acc.multiplyMult(tuning.crystalXMult, ScoreSourceKind.playedTile, idx);
      case Enhancement.none:
      case Enhancement.iron: // held effect only
      case Enhancement.gold: // round-end effect only
      case Enhancement.skyStone: // handled by the evaluator
        break;
    }
    if (tile.tile.seal == Seal.gold) {
      acc.earnMoney(tuning.goldSealMoney, ScoreSourceKind.playedTile, idx);
    }
    for (final ctx in contexts) {
      ctx.self.behavior.onTileScored(ctx, tile);
    }
  }
}

class _Accumulator {
  _Accumulator(this.input);

  final ScoringInput input;
  double chips = 0;
  double mult = 0;
  int money = 0;
  final List<ScoreEvent> events = [];

  void emit(ScoreEventKind kind, ScoreSourceKind source, int index, num amount) {
    events.add(ScoreEvent(
      kind: kind,
      source: source,
      sourceIndex: index,
      amount: amount,
      chipsAfter: chips,
      multAfter: mult,
    ));
  }

  void addChips(num amount, ScoreSourceKind source, int index) {
    chips += amount;
    emit(ScoreEventKind.chips, source, index, amount);
  }

  void addMult(num amount, ScoreSourceKind source, int index) {
    mult += amount;
    emit(ScoreEventKind.mult, source, index, amount);
  }

  void multiplyMult(num factor, ScoreSourceKind source, int index) {
    mult *= factor;
    emit(ScoreEventKind.xMult, source, index, factor);
  }

  void earnMoney(int amount, ScoreSourceKind source, int index) {
    money += amount;
    emit(ScoreEventKind.money, source, index, amount);
  }
}

class _KutCtx extends KutHandContext {
  _KutCtx(this._acc, this.self, this._index);

  final _Accumulator _acc;
  final int _index;

  @override
  final KutInstance self;

  ScoringInput get _in => _acc.input;

  @override
  HandResult get hand => _in.hand;
  @override
  int get playedCount => _in.hand.played.length;
  @override
  List<Tile> get heldTiles => _in.heldTiles;
  @override
  int get handsLeft => _in.handsLeft;
  @override
  int get discardsLeft => _in.discardsLeft;
  @override
  bool get isBossRound => _in.isBossRound;
  @override
  int get handNumber => _in.handNumber;

  @override
  void addChips(num amount) => _acc.addChips(amount, ScoreSourceKind.kut, _index);
  @override
  void addMult(num amount) => _acc.addMult(amount, ScoreSourceKind.kut, _index);
  @override
  void multiplyMult(num factor) =>
      _acc.multiplyMult(factor, ScoreSourceKind.kut, _index);
  @override
  void earnMoney(int amount) =>
      _acc.earnMoney(amount, ScoreSourceKind.kut, _index);
}
