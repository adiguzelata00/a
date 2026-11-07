// Wires lib/data content and balance numbers into the core run loop.

import '../core/run/run_config.dart';
import '../core/run/run_state.dart';
import 'balance.dart';
import 'bosses.dart';
import 'consumables.dart';
import 'kuts.dart';

final RunRules defaultRunRules = RunRules(
  round: Balance.round,
  handStats: Balance.hands,
  tileEffects: Balance.tileEffects,
  floorCount: Balance.floorCount,
  targetFor: Balance.targetFor,
  startingMoney: Balance.startingMoney,
  roundRewards: Balance.roundRewards,
  moneyPerHandLeft: Balance.moneyPerHandLeft,
  interestPer: Balance.interestPer,
  interestCap: Balance.interestCap,
  rerollBaseCost: Balance.rerollBaseCost,
  rerollCostStep: Balance.rerollCostStep,
  kutSlots: Balance.kutSlots,
  consumableSlots: Balance.consumableSlots,
  shopItemSlots: Balance.shopItemSlots,
  shopPackSlots: Balance.shopPackSlots,
  packPrice: Balance.packPrice,
  packChoices: Balance.packChoices,
  itemWeights: Balance.shopItemWeights,
  rarityWeights: Balance.rarityWeights,
  skipMoney: Balance.skipMoney,
  discountFactor: Balance.discountFactor,
  interestCapPerVoucher: Balance.interestCapPerVoucher,
);

final RunCatalog defaultCatalog = RunCatalog(
  kuts: allKuts,
  bosses: allBosses,
  consumables: allConsumables,
  vouchers: allVouchers,
);

RunState newRun(String seedCode) => RunState(
  seedCode: seedCode,
  rules: defaultRunRules,
  catalog: defaultCatalog,
);
