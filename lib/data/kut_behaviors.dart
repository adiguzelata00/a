// Reusable, parameterised Kut behaviours. Concrete Kuts are assembled from
// these in kuts.dart, so new content is mostly data.

import '../core/hands/hand_evaluator.dart';
import '../core/hands/hand_type.dart';
import '../core/scoring/kut.dart';
import '../core/tiles/tile.dart';

/// "Every [color] tile counted: +chips, +mult."
class ColorTileKut extends KutBehavior {
  const ColorTileKut(this.color, {this.chips = 0, this.mult = 0});
  final TileColor color;
  final num chips;
  final num mult;

  @override
  void onTileScored(KutHandContext ctx, CountedTile tile) {
    if (!tile.matchesColor(color)) return;
    if (chips != 0) ctx.addChips(chips);
    if (mult != 0) ctx.addMult(mult);
  }
}

/// Hand-level bonus when [condition] holds.
class ConditionalHandKut extends KutBehavior {
  const ConditionalHandKut(
    this.condition, {
    this.chips = 0,
    this.mult = 0,
    this.xMult = 1,
    this.handsDeltaValue = 0,
  });

  final bool Function(KutHandContext ctx) condition;
  final num chips;
  final num mult;
  final num xMult;
  final int handsDeltaValue;

  @override
  int get handsDelta => handsDeltaValue;

  @override
  void onHandScored(KutHandContext ctx) {
    if (!condition(ctx)) return;
    if (chips != 0) ctx.addChips(chips);
    if (mult != 0) ctx.addMult(mult);
    if (xMult != 1) ctx.multiplyMult(xMult);
  }
}

bool always(KutHandContext ctx) => true;
bool handHasPairs(KutHandContext ctx) =>
    ctx.handType == HandType.pair ||
    ctx.handType == HandType.twoPair ||
    ctx.handType == HandType.threePairs;
bool handHasRun(KutHandContext ctx) => ctx.handType.isRun;
bool handHasGroup(KutHandContext ctx) => ctx.handType.isGroup;
bool isBossRound(KutHandContext ctx) => ctx.isBossRound;
bool okeyUsedAsWild(KutHandContext ctx) => ctx.hand.usesWild;

/// Tulpar: +chips for every remaining discard.
class ChipsPerDiscardKut extends KutBehavior {
  const ChipsPerDiscardKut(this.chipsPerDiscard);
  final int chipsPerDiscard;

  @override
  void onHandScored(KutHandContext ctx) {
    if (ctx.discardsLeft > 0) ctx.addChips(chipsPerDiscard * ctx.discardsLeft);
  }
}

/// Kam Davulu: the first counted tile triggers extra times.
class FirstTileRetriggerKut extends KutBehavior {
  const FirstTileRetriggerKut(this.extra);
  final int extra;

  @override
  int extraTileTriggers(
    KutHandContext ctx,
    CountedTile tile,
    int countedPosition,
  ) => countedPosition == 0 ? extra : 0;
}

/// Kayra Han: gains ×mult permanently whenever a Destan is used.
class DestanScalingKut extends KutBehavior {
  const DestanScalingKut(this.step);
  final double step;

  @override
  Map<String, num> initialState() => const {'xMult': 1.0};

  @override
  void onDestanUsed(KutInstance self) {
    self.state['xMult'] = (self.state['xMult'] ?? 1) + step;
  }

  @override
  void onHandScored(KutHandContext ctx) {
    final x = ctx.self.state['xMult'] ?? 1;
    if (x != 1) ctx.multiplyMult(x);
  }
}

/// Gök Börü: gains ×mult permanently every time [trigger] is played.
/// The gain happens *before* scoring, so it already counts that hand.
class HandTypeScalingKut extends KutBehavior {
  const HandTypeScalingKut(this.trigger, this.step);
  final HandType trigger;
  final double step;

  @override
  Map<String, num> initialState() => const {'xMult': 1.0};

  @override
  void beforeScoring(KutHandContext ctx) {
    if (ctx.handType == trigger) {
      ctx.self.state['xMult'] = (ctx.self.state['xMult'] ?? 1) + step;
    }
  }

  @override
  void onHandScored(KutHandContext ctx) {
    final x = ctx.self.state['xMult'] ?? 1;
    if (x != 1) ctx.multiplyMult(x);
  }
}

/// Yada Taşı: +mult per discarded tile this round; resets at round end.
class DiscardStackKut extends KutBehavior {
  const DiscardStackKut(this.multPerTile);
  final int multPerTile;

  @override
  Map<String, num> initialState() => const {'mult': 0};

  @override
  void onDiscard(KutInstance self, List<Tile> discarded) {
    self.state['mult'] =
        (self.state['mult'] ?? 0) + multPerTile * discarded.length;
  }

  @override
  void onHandScored(KutHandContext ctx) {
    final m = ctx.self.state['mult'] ?? 0;
    if (m != 0) ctx.addMult(m);
  }

  @override
  void onRoundEnd(KutInstance self) => self.state['mult'] = 0;
}

/// Ergenekon: held iron tiles also give +chips.
class IronChipsKut extends KutBehavior {
  const IronChipsKut(this.chips);
  final int chips;

  @override
  void onHeldTile(KutHandContext ctx, Tile tile) {
    if (tile.enhancement == Enhancement.iron) ctx.addChips(chips);
  }
}

/// Dede Korkut: money per remaining hand at round end.
class MoneyPerHandLeftKut extends KutBehavior {
  const MoneyPerHandLeftKut(this.money);
  final int money;

  @override
  int roundEndMoney(KutInstance self, RoundEndInfo info) =>
      money * info.handsLeft;
}

/// Kervan: first shop reroll is free.
class FreeRerollKut extends KutBehavior {
  const FreeRerollKut();
  @override
  bool get firstRerollFree => true;
}

/// Zümrüdüanka: saves a lost run once if the score reached a share of the
/// target. The run logic destroys the Kut afterwards.
class LastChanceKut extends KutBehavior {
  const LastChanceKut(this.threshold);
  final double threshold;

  @override
  bool preventsLoss(KutInstance self, int roundScore, int target) =>
      roundScore >= target * threshold;
}

/// Yer-Su: +mult for every tile held in the rack.
class PerHeldTileKut extends KutBehavior {
  const PerHeldTileKut(this.multPerTile);
  final num multPerTile;

  @override
  void onHandScored(KutHandContext ctx) {
    final n = ctx.heldTiles.length;
    if (n > 0) ctx.addMult(multPerTile * n);
  }
}

/// Ötüken: +mult for every [per] Akçe held.
class MoneyMultKut extends KutBehavior {
  const MoneyMultKut({required this.per, required this.mult});
  final int per;
  final num mult;

  @override
  void onHandScored(KutHandContext ctx) {
    final steps = ctx.money ~/ per;
    if (steps > 0) ctx.addMult(mult * steps);
  }
}

/// Kök Tengri: ×(1 + step × hands left after this one).
class HandsLeftXMultKut extends KutBehavior {
  const HandsLeftXMultKut(this.step);
  final double step;

  @override
  void onHandScored(KutHandContext ctx) {
    if (ctx.handsLeft > 0) ctx.multiplyMult(1 + step * ctx.handsLeft);
  }
}
