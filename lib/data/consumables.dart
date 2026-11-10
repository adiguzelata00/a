// Destan, Tılsım and Kupon catalogue. Names are localized by `id`.

import '../core/hands/hand_type.dart';
import '../core/run/items.dart';
import 'balance.dart';

/// One Destan per hand type (each levels that hand up by one).
const List<ConsumableDefinition> allDestans = [
  ConsumableDefinition.destan(
    id: 'goc_destani',
    hand: HandType.single,
    price: Balance.destanPrice,
  ),
  ConsumableDefinition.destan(
    id: 'tureyis_destani',
    hand: HandType.pair,
    price: Balance.destanPrice,
  ),
  ConsumableDefinition.destan(
    id: 'satuk_bugra_destani',
    hand: HandType.twoPair,
    price: Balance.destanPrice,
  ),
  ConsumableDefinition.destan(
    id: 'alpamis_destani',
    hand: HandType.run3,
    price: Balance.destanPrice,
  ),
  ConsumableDefinition.destan(
    id: 'koroglu_destani',
    hand: HandType.group3,
    price: Balance.destanPrice,
  ),
  ConsumableDefinition.destan(
    id: 'dede_korkut_hikayeleri',
    hand: HandType.threePairs,
    price: Balance.destanPrice,
  ),
  ConsumableDefinition.destan(
    id: 'manas_destani',
    hand: HandType.run4,
    price: Balance.destanPrice,
  ),
  ConsumableDefinition.destan(
    id: 'su_destani',
    hand: HandType.rainbowRun,
    price: Balance.destanPrice,
  ),
  ConsumableDefinition.destan(
    id: 'oguz_kagan_destani',
    hand: HandType.run5,
    price: Balance.destanPrice,
  ),
  ConsumableDefinition.destan(
    id: 'ergenekon_destani',
    hand: HandType.group4,
    price: Balance.destanPrice,
  ),
  ConsumableDefinition.destan(
    id: 'er_tostuk_destani',
    hand: HandType.run6,
    price: Balance.destanPrice,
  ),
  ConsumableDefinition.destan(
    id: 'yaratilis_destani',
    hand: HandType.skyMeld,
    price: Balance.destanPrice,
  ),
];

const List<ConsumableDefinition> allTilsims = [
  ConsumableDefinition.tilsim(
    id: 'demirci_tilsimi',
    effect: TilsimEffect.iron,
    maxTargets: 2,
    price: Balance.tilsimPrice,
  ),
  ConsumableDefinition.tilsim(
    id: 'simyaci_tilsimi',
    effect: TilsimEffect.gold,
    maxTargets: 1,
    price: Balance.tilsimPrice,
  ),
  ConsumableDefinition.tilsim(
    id: 'renk_tilsimi',
    effect: TilsimEffect.paint,
    maxTargets: 3,
    price: Balance.tilsimPrice,
  ),
  ConsumableDefinition.tilsim(
    id: 'ayna_tilsimi',
    effect: TilsimEffect.copy,
    maxTargets: 1,
    price: Balance.tilsimPrice,
  ),
  ConsumableDefinition.tilsim(
    id: 'yakma_tilsimi',
    effect: TilsimEffect.destroy,
    maxTargets: 2,
    price: Balance.tilsimPrice,
  ),
  ConsumableDefinition.tilsim(
    id: 'kam_tilsimi',
    effect: TilsimEffect.createKut,
    price: Balance.tilsimPrice,
  ),
  ConsumableDefinition.tilsim(
    id: 'tamga_tilsimi',
    effect: TilsimEffect.seal,
    maxTargets: 1,
    price: Balance.tilsimPrice,
  ),
  ConsumableDefinition.tilsim(
    id: 'yukseltme_tilsimi',
    effect: TilsimEffect.increment,
    maxTargets: 2,
    price: Balance.tilsimPrice,
  ),
];

const List<ConsumableDefinition> allConsumables = [
  ...allDestans,
  ...allTilsims,
];

const List<VoucherDefinition> allVouchers = [
  VoucherDefinition(
    id: 'ek_el',
    effect: VoucherEffect.extraHand,
    price: Balance.voucherPrice,
  ),
  VoucherDefinition(
    id: 'ek_degistir',
    effect: VoucherEffect.extraDiscard,
    price: Balance.voucherPrice,
  ),
  VoucherDefinition(
    id: 'genis_istaka',
    effect: VoucherEffect.extraHandSize,
    price: Balance.voucherPrice,
  ),
  VoucherDefinition(
    id: 'kut_yuvasi',
    effect: VoucherEffect.extraKutSlot,
    price: Balance.voucherPrice,
  ),
  VoucherDefinition(
    id: 'heybe',
    effect: VoucherEffect.extraConsumableSlot,
    price: Balance.voucherPrice,
  ),
  VoucherDefinition(
    id: 'pazarlik',
    effect: VoucherEffect.discount,
    price: Balance.voucherPrice,
  ),
  VoucherDefinition(
    id: 'hazine',
    effect: VoucherEffect.interestCap,
    price: Balance.voucherPrice,
  ),
];
