import '../hands/hand_type.dart';
import '../tiles/tile.dart';

/// Consumable families.
enum ConsumableKind {
  /// Destan: levels up a hand type.
  destan,

  /// Tılsım: changes tiles (or creates something).
  tilsim,
}

/// What a Tılsım does.
enum TilsimEffect {
  /// Demirci: selected tiles become Demir (iron).
  iron,

  /// Simyacı: selected tile becomes Altın (gold).
  gold,

  /// Renk: selected tiles are painted the Tılsım's color.
  paint,

  /// Ayna: a copy of the selected tile is added to the deck.
  copy,

  /// Yakma: selected tiles are removed from the deck for good.
  destroy,

  /// Kam: creates a random Kut (needs a free slot).
  createKut,

  /// Tamga: a random seal is stamped on the selected tile.
  seal,

  /// Yükseltme: selected tiles get +1 (13 wraps to 1).
  increment,
}

/// Static definition of a consumable (data in `lib/data/consumables.dart`).
class ConsumableDefinition {
  const ConsumableDefinition.destan({
    required this.id,
    required HandType this.hand,
    required this.price,
  }) : kind = ConsumableKind.destan,
       effect = null,
       maxTargets = 0;

  const ConsumableDefinition.tilsim({
    required this.id,
    required TilsimEffect this.effect,
    required this.price,
    this.maxTargets = 0,
  }) : kind = ConsumableKind.tilsim,
       hand = null;

  /// Stable id, also the localization key.
  final String id;
  final ConsumableKind kind;
  final int price;

  /// Destan: hand type it levels up.
  final HandType? hand;

  /// Tılsım: its effect.
  final TilsimEffect? effect;

  /// Number of rack tiles that may be targeted (0 = no target needed).
  final int maxTargets;

  bool get needsTiles => maxTargets > 0;
  int get sellValue => price ~/ 2;
}

/// A consumable the player holds.
class ConsumableInstance {
  const ConsumableInstance(this.definition, {this.color});

  final ConsumableDefinition definition;

  /// Renk Tılsımı: the color it paints (rolled when the item is created).
  /// RULE DECISION: the color is part of the item instead of a picker.
  final TileColor? color;

  String get id => definition.id;
}

/// Permanent run upgrades bought in the shop ("Kupon").
enum VoucherEffect {
  extraHand,
  extraDiscard,
  extraHandSize,
  extraKutSlot,
  extraConsumableSlot,
  discount,
  interestCap,
}

class VoucherDefinition {
  const VoucherDefinition({
    required this.id,
    required this.effect,
    required this.price,
  });

  final String id;
  final VoucherEffect effect;
  final int price;
}

/// Reward for skipping a Small or Big trial ("etiket").
enum SkipTag {
  /// Immediate Akçe.
  money,

  /// A free Kut Kesesi opens right away.
  kutPack,

  /// A free Destan Kesesi opens right away.
  destanPack,

  /// A free Tılsım Kesesi opens right away.
  tilsimPack,
}

/// Booster pack kinds ("Kese").
enum PackKind { kut, destan, tilsim, tile }
