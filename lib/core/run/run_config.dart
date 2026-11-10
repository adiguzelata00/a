import '../round/round.dart';
import '../hands/hand_type.dart';
import '../scoring/kut.dart';
import '../scoring/scoring_engine.dart';
import 'boss.dart';
import 'items.dart';

/// Every number the run loop needs. Built from `lib/data/balance.dart`, so
/// core never hard-codes balance values.
class RunRules {
  const RunRules({
    required this.round,
    required this.handStats,
    required this.tileEffects,
    required this.floorCount,
    required this.targetFor,
    required this.startingMoney,
    required this.roundRewards,
    required this.moneyPerHandLeft,
    required this.interestPer,
    required this.interestCap,
    required this.rerollBaseCost,
    required this.rerollCostStep,
    required this.kutSlots,
    required this.consumableSlots,
    required this.shopItemSlots,
    required this.shopPackSlots,
    required this.packPrice,
    required this.packChoices,
    required this.itemWeights,
    required this.rarityWeights,
    required this.skipMoney,
    required this.discountFactor,
    required this.interestCapPerVoucher,
  });

  final RoundConfig round;
  final Map<HandType, HandStats> handStats;
  final TileEffectTuning tileEffects;
  final int floorCount;

  /// Target score for floor (1-based) and round in floor (0 small, 1 big,
  /// 2 boss). Floors beyond [floorCount] are endless mode.
  final int Function(int floor, int roundInFloor) targetFor;

  final int startingMoney;

  /// Rewards for small, big, boss.
  final List<int> roundRewards;
  final int moneyPerHandLeft;
  final int interestPer;
  final int interestCap;
  final int rerollBaseCost;
  final int rerollCostStep;
  final int kutSlots;
  final int consumableSlots;
  final int shopItemSlots;
  final int shopPackSlots;
  final int packPrice;

  /// Options shown when a pack is opened (choose one).
  final int packChoices;

  /// Weights for a shop item slot: kut / destan / tilsim.
  final Map<String, int> itemWeights;
  final Map<Rarity, int> rarityWeights;
  final int skipMoney;

  /// Price multiplier with the discount voucher.
  final double discountFactor;
  final int interestCapPerVoucher;

  RunRules copyWith({
    int Function(int floor, int roundInFloor)? targetFor,
    int? startingMoney,
    int? floorCount,
  }) => RunRules(
    round: round,
    handStats: handStats,
    tileEffects: tileEffects,
    floorCount: floorCount ?? this.floorCount,
    targetFor: targetFor ?? this.targetFor,
    startingMoney: startingMoney ?? this.startingMoney,
    roundRewards: roundRewards,
    moneyPerHandLeft: moneyPerHandLeft,
    interestPer: interestPer,
    interestCap: interestCap,
    rerollBaseCost: rerollBaseCost,
    rerollCostStep: rerollCostStep,
    kutSlots: kutSlots,
    consumableSlots: consumableSlots,
    shopItemSlots: shopItemSlots,
    shopPackSlots: shopPackSlots,
    packPrice: packPrice,
    packChoices: packChoices,
    itemWeights: itemWeights,
    rarityWeights: rarityWeights,
    skipMoney: skipMoney,
    discountFactor: discountFactor,
    interestCapPerVoucher: interestCapPerVoucher,
  );
}

/// All content a run can draw from (from `lib/data`).
class RunCatalog {
  const RunCatalog({
    required this.kuts,
    required this.bosses,
    required this.consumables,
    required this.vouchers,
  });

  final List<KutDefinition> kuts;
  final List<BossDefinition> bosses;
  final List<ConsumableDefinition> consumables;
  final List<VoucherDefinition> vouchers;

  List<ConsumableDefinition> get destans => [
    for (final c in consumables)
      if (c.kind == ConsumableKind.destan) c,
  ];

  List<ConsumableDefinition> get tilsims => [
    for (final c in consumables)
      if (c.kind == ConsumableKind.tilsim) c,
  ];

  ConsumableDefinition destanFor(HandType type) =>
      destans.firstWhere((d) => d.hand == type);

  KutDefinition kut(String id) => kuts.firstWhere((k) => k.id == id);
}
