// Kut catalogue. Display names / descriptions are localized by `id`
// (ARB keys like `kut_umay_ana_name`, added in Phase 5).

import '../core/hands/hand_type.dart';
import '../core/scoring/kut.dart';
import '../core/tiles/tile.dart';
import 'balance.dart';
import 'kut_behaviors.dart';

KutDefinition _kut(
  String id,
  Rarity rarity,
  KutBehavior behavior, {
  int? price,
}) => KutDefinition(
  id: id,
  rarity: rarity,
  price: price ?? Balance.kutPrices[rarity]!,
  behavior: behavior,
);

bool _kopuzCondition(KutHandContext ctx) =>
    ctx.playedCount <= Balance.kopuzMaxTiles;

bool _bigRun(KutHandContext ctx) =>
    ctx.handType == HandType.run5 || ctx.handType == HandType.run6;

final List<KutDefinition> allKuts = [
  _kut(
    'umay_ana',
    Rarity.common,
    const ColorTileKut(TileColor.red, mult: Balance.umayAnaMult),
  ),
  _kut(
    'ay_ata',
    Rarity.common,
    const ColorTileKut(TileColor.blue, chips: Balance.ayAtaChips),
  ),
  _kut(
    'gun_ana',
    Rarity.common,
    const ColorTileKut(TileColor.yellow, mult: Balance.gunAnaMult),
  ),
  _kut(
    'kara_dag',
    Rarity.common,
    const ColorTileKut(
      TileColor.black,
      chips: Balance.karaDagChips,
      mult: Balance.karaDagMult,
    ),
  ),
  _kut(
    'bozkurt',
    Rarity.common,
    const ConditionalHandKut(handHasRun, mult: Balance.bozkurtMult),
  ),
  _kut(
    'asena',
    Rarity.rare,
    const ConditionalHandKut(handHasGroup, xMult: Balance.asenaXMult),
  ),
  _kut(
    'tulpar',
    Rarity.common,
    const ChipsPerDiscardKut(Balance.tulparChipsPerDiscard),
  ),
  _kut(
    'kopuz',
    Rarity.common,
    const ConditionalHandKut(_kopuzCondition, mult: Balance.kopuzMult),
  ),
  _kut(
    'kam_davulu',
    Rarity.rare,
    const FirstTileRetriggerKut(Balance.kamDavuluExtraTriggers),
  ),
  _kut(
    'erlik_pazarligi',
    Rarity.rare,
    const ConditionalHandKut(
      always,
      xMult: Balance.erlikPazarligiXMult,
      handsDeltaValue: Balance.erlikPazarligiHandsDelta,
    ),
  ),
  _kut(
    'ulgen_isigi',
    Rarity.legendary,
    const ConditionalHandKut(okeyUsedAsWild, xMult: Balance.ulgenIsigiXMult),
  ),
  _kut(
    'kayra_han',
    Rarity.legendary,
    const DestanScalingKut(Balance.kayraHanXMultPerDestan),
  ),
  _kut(
    'zumruduanka',
    Rarity.rare,
    const LastChanceKut(Balance.zumruduankaThreshold),
  ),
  _kut(
    'oguz_kagan',
    Rarity.rare,
    const ConditionalHandKut(
      _bigRun,
      chips: Balance.oguzKaganChips,
      mult: Balance.oguzKaganMult,
    ),
  ),
  _kut(
    'dede_korkut',
    Rarity.common,
    const MoneyPerHandLeftKut(Balance.dedeKorkutMoneyPerHand),
  ),
  _kut('kervan', Rarity.common, const FreeRerollKut()),
  _kut(
    'yada_tasi',
    Rarity.rare,
    const DiscardStackKut(Balance.yadaTasiMultPerTile),
  ),
  _kut(
    'nazar_boncugu',
    Rarity.common,
    const ConditionalHandKut(isBossRound, mult: Balance.nazarBoncuguMult),
  ),
  _kut('ergenekon', Rarity.rare, const IronChipsKut(Balance.ergenekonChips)),
  _kut(
    'gok_boru',
    Rarity.legendary,
    const HandTypeScalingKut(HandType.group4, Balance.gokBoruXMultPerGroup4),
  ),
  // Phase 4 additions.
  _kut(
    'od_ana',
    Rarity.common,
    const ConditionalHandKut(handHasPairs, mult: Balance.odAnaMult),
  ),
  _kut('yer_su', Rarity.common, const PerHeldTileKut(Balance.yerSuMultPerTile)),
  _kut(
    'otuken',
    Rarity.rare,
    const MoneyMultKut(
      per: Balance.otukenAkcePerStep,
      mult: Balance.otukenMultPerStep,
    ),
  ),
  _kut(
    'kok_tengri',
    Rarity.legendary,
    const HandsLeftXMultKut(Balance.kokTengriXMultPerHand),
  ),
];

final Map<String, KutDefinition> kutsById = {for (final k in allKuts) k.id: k};

KutDefinition kutById(String id) {
  final k = kutsById[id];
  if (k == null) throw ArgumentError.value(id, 'id', 'Unknown Kut');
  return k;
}
