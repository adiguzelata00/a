import '../hands/hand_evaluator.dart';
import '../hands/hand_type.dart';
import '../tiles/tile.dart';

/// Kut rarity.
enum Rarity { common, rare, legendary }

/// Read-only information + mutation API given to Kut hooks while a hand is
/// scored. Implemented by the scoring engine.
abstract class KutHandContext {
  KutInstance get self;
  HandResult get hand;
  HandType get handType => hand.type;
  List<CountedTile> get counted => hand.counted;

  /// Number of tiles played (including tiles not part of the meld).
  int get playedCount;

  /// Tiles left in the rack while this hand is scored.
  List<Tile> get heldTiles;

  /// Remaining hands after this one is played.
  int get handsLeft;
  int get discardsLeft;
  bool get isBossRound;

  /// 0-based index of this hand within the round.
  int get handNumber;

  void addChips(num amount);
  void addMult(num amount);
  void multiplyMult(num factor);
  void earnMoney(int amount);
}

/// Information passed to round-end hooks.
class RoundEndInfo {
  const RoundEndInfo({
    required this.handsLeft,
    required this.discardsLeft,
    required this.isBossRound,
  });
  final int handsLeft;
  final int discardsLeft;
  final bool isBossRound;
}

/// Behaviour of a Kut. Every hook has a no-op default so a Kut only
/// overrides what it needs. Behaviours must be stateless; per-instance
/// state lives in [KutInstance.state].
///
/// Trigger order while scoring a hand (see `ScoringEngine`):
///   1. [beforeScoring] for every Kut (state updates such as "Gök Börü").
///   2. For each counted tile left to right, per trigger:
///      tile chips → enhancement → seal → [onTileScored] of each Kut.
///      Extra triggers come from Kızıl Tamga and [extraTileTriggers].
///   3. For each held tile left to right: held effects (Demir) →
///      [onHeldTile] of each Kut.
///   4. [onHandScored] of each Kut, left to right.
abstract class KutBehavior {
  const KutBehavior();

  void beforeScoring(KutHandContext ctx) {}

  /// Additional times the counted tile at [countedPosition] triggers.
  int extraTileTriggers(
    KutHandContext ctx,
    CountedTile tile,
    int countedPosition,
  ) => 0;

  void onTileScored(KutHandContext ctx, CountedTile tile) {}

  void onHeldTile(KutHandContext ctx, Tile tile) {}

  void onHandScored(KutHandContext ctx) {}

  /// Called after a discard ("Değiştir") with the discarded tiles.
  void onDiscard(KutInstance self, List<Tile> discarded) {}

  /// Called when a Destan item is used.
  void onDestanUsed(KutInstance self) {}

  /// Money earned at round end.
  int roundEndMoney(KutInstance self, RoundEndInfo info) => 0;

  /// Called when a round ends (after money), e.g. to reset per-round state.
  void onRoundEnd(KutInstance self) {}

  /// Change to the number of hands per round.
  int get handsDelta => 0;

  /// Change to the number of discards per round.
  int get discardsDelta => 0;

  /// Whether the first shop reroll each shop visit is free.
  bool get firstRerollFree => false;

  /// Return true to prevent losing the run (the Kut is then destroyed).
  bool preventsLoss(KutInstance self, int roundScore, int target) => false;

  /// Initial per-instance state.
  Map<String, num> initialState() => const {};
}

/// Static definition of a Kut (data driven, see `lib/data/kuts.dart`).
class KutDefinition {
  const KutDefinition({
    required this.id,
    required this.rarity,
    required this.price,
    required this.behavior,
  });

  /// Stable identifier, also used as localization key.
  final String id;
  final Rarity rarity;

  /// Shop price in Akçe (sell value = price ~/ 2).
  final int price;
  final KutBehavior behavior;

  int get sellValue => price ~/ 2;
}

/// A Kut owned by the player, with mutable per-instance state.
class KutInstance {
  KutInstance(this.definition, [Map<String, num>? state])
    : state = state ?? Map.of(definition.behavior.initialState());

  final KutDefinition definition;
  final Map<String, num> state;

  KutBehavior get behavior => definition.behavior;
  String get id => definition.id;

  /// Deep copy, used so previews never mutate real state.
  KutInstance copy() => KutInstance(definition, Map.of(state));

  Map<String, Object> toJson() => {'id': id, 'state': state};

  @override
  String toString() => 'Kut($id${state.isEmpty ? '' : ' $state'})';
}
