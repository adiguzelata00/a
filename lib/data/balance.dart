// Every balance number of the game lives in this file.
//
// Tweak values here; logic in lib/core never hard-codes balance numbers.

import '../core/hands/hand_type.dart';
import '../core/round/round.dart';
import '../core/scoring/kut.dart';
import '../core/scoring/scoring_engine.dart';

abstract final class Balance {
  // ---------------------------------------------------------------------
  // Round limits
  // ---------------------------------------------------------------------
  static const RoundConfig round = RoundConfig(
    handSize: 10,
    hands: 4,
    discards: 3,
    maxTilesPerAction: 6,
  );

  // ---------------------------------------------------------------------
  // Hand types: base chips / mult and per-level increase (Destan).
  // ---------------------------------------------------------------------
  static const Map<HandType, HandStats> hands = {
    HandType.single: HandStats(
      chips: 5,
      mult: 1,
      chipsPerLevel: 10,
      multPerLevel: 1,
    ),
    HandType.pair: HandStats(
      chips: 10,
      mult: 2,
      chipsPerLevel: 15,
      multPerLevel: 1,
    ),
    HandType.twoPair: HandStats(
      chips: 20,
      mult: 2,
      chipsPerLevel: 20,
      multPerLevel: 1,
    ),
    HandType.run3: HandStats(
      chips: 25,
      mult: 3,
      chipsPerLevel: 20,
      multPerLevel: 2,
    ),
    HandType.group3: HandStats(
      chips: 30,
      mult: 3,
      chipsPerLevel: 25,
      multPerLevel: 2,
    ),
    HandType.threePairs: HandStats(
      chips: 45,
      mult: 4,
      chipsPerLevel: 30,
      multPerLevel: 2,
    ),
    HandType.run4: HandStats(
      chips: 45,
      mult: 4,
      chipsPerLevel: 30,
      multPerLevel: 3,
    ),
    HandType.rainbowRun: HandStats(
      chips: 40,
      mult: 4,
      chipsPerLevel: 30,
      multPerLevel: 3,
    ),
    HandType.run5: HandStats(
      chips: 70,
      mult: 5,
      chipsPerLevel: 35,
      multPerLevel: 3,
    ),
    HandType.group4: HandStats(
      chips: 60,
      mult: 7,
      chipsPerLevel: 30,
      multPerLevel: 3,
    ),
    HandType.run6: HandStats(
      chips: 100,
      mult: 8,
      chipsPerLevel: 40,
      multPerLevel: 4,
    ),
    HandType.skyMeld: HandStats(
      chips: 120,
      mult: 9,
      chipsPerLevel: 50,
      multPerLevel: 4,
    ),
  };

  static HandLevels newHandLevels() => HandLevels(hands);

  // ---------------------------------------------------------------------
  // Tile enhancements & seals
  // ---------------------------------------------------------------------
  static const TileEffectTuning tileEffects = TileEffectTuning(
    boneChips: 30,
    ironXMult: 1.5,
    crystalXMult: 2.0,
    crystalBreakChance: 0.25,
    goldSealMoney: 3,
    goldTileRoundEndMoney: 3,
  );

  // ---------------------------------------------------------------------
  // Run structure: 8 floors × (small, big, boss)
  // ---------------------------------------------------------------------
  static const int floorCount = 8;

  /// Small-trial target per floor. Big = ×1.5, Boss = ×2 (see below).
  /// Growth is ~1.75× per floor.
  static const List<int> floorBaseTargets = [
    300,
    525,
    900,
    1600,
    2800,
    4800,
    8400,
    14500,
  ];
  static const List<double> roundTargetMultipliers = [1.0, 1.5, 2.0];

  /// Endless mode ("Sonsuz Gök"): growth per floor after floor 8.
  static const double endlessGrowth = 1.9;

  static int targetFor(int floor, int roundInFloor) {
    final base = floor <= floorCount
        ? floorBaseTargets[floor - 1]
        : floorBaseTargets.last * _pow(endlessGrowth, floor - floorCount);
    return (base * roundTargetMultipliers[roundInFloor]).round();
  }

  static double _pow(double b, int e) {
    var r = 1.0;
    for (var i = 0; i < e; i++) {
      r *= b;
    }
    return r;
  }

  // ---------------------------------------------------------------------
  // Economy (Akçe)
  // ---------------------------------------------------------------------
  static const int startingMoney = 4;
  static const List<int> roundRewards = [3, 4, 5]; // small, big, boss
  static const int moneyPerHandLeft = 1;
  static const int interestPer = 5;
  static const int interestCap = 5;
  static const int rerollBaseCost = 5;
  static const int rerollCostStep = 1;

  // ---------------------------------------------------------------------
  // Shop ("Pazar")
  // ---------------------------------------------------------------------
  static const int shopItemSlots = 2;
  static const int shopPackSlots = 2;
  static const int packPrice = 4;

  /// Options inside an opened pack (choose one).
  static const int packChoices = 3;

  /// Item slot contents: Kut / Destan / Tılsım.
  static const Map<String, int> shopItemWeights = {
    'kut': 70,
    'destan': 15,
    'tilsim': 15,
  };
  static const Map<Rarity, int> rarityWeights = {
    Rarity.common: 70,
    Rarity.rare: 25,
    Rarity.legendary: 5,
  };
  static const int destanPrice = 3;
  static const int tilsimPrice = 3;
  static const int voucherPrice = 10;

  /// Discount voucher: prices × this (rounded down, min 1).
  static const double discountFactor = 0.75;

  /// Interest voucher: raises the interest cap by this much.
  static const int interestCapPerVoucher = 5;

  /// "Akçe" skip tag reward.
  static const int skipMoney = 5;

  // ---------------------------------------------------------------------
  // Kut prices & slots
  // ---------------------------------------------------------------------
  static const int kutSlots = 5;
  static const int consumableSlots = 2;
  static const Map<Rarity, int> kutPrices = {
    Rarity.common: 5,
    Rarity.rare: 8,
    Rarity.legendary: 12,
  };

  // ---------------------------------------------------------------------
  // Kut effect values (ids match lib/data/kuts.dart)
  // ---------------------------------------------------------------------
  static const int umayAnaMult = 4;
  static const int ayAtaChips = 30;
  static const int gunAnaMult = 3;
  static const int karaDagChips = 20;
  static const int karaDagMult = 1;
  static const int bozkurtMult = 10;
  static const double asenaXMult = 2;
  static const int tulparChipsPerDiscard = 15;
  static const int kopuzMaxTiles = 3;
  static const int kopuzMult = 20;
  static const int kamDavuluExtraTriggers = 1;
  static const double erlikPazarligiXMult = 3;
  static const int erlikPazarligiHandsDelta = -1;
  static const double ulgenIsigiXMult = 3;
  static const double kayraHanXMultPerDestan = 0.25;
  static const double zumruduankaThreshold = 0.25;
  static const int oguzKaganChips = 50;
  static const int oguzKaganMult = 5;
  static const int dedeKorkutMoneyPerHand = 2;
  static const int yadaTasiMultPerTile = 1;
  static const int nazarBoncuguMult = 15;
  static const int ergenekonChips = 20;
  static const double gokBoruXMultPerGroup4 = 1;
}
