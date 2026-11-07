// Boss catalogue. Names / descriptions are localized by `id`.

import '../core/round/round_rules.dart';
import '../core/run/boss.dart';

export '../core/run/boss.dart';

const List<BossDefinition> allBosses = [
  BossDefinition(id: 'tepegoz', rules: RoundRules(singleColorPerHand: true)),
  BossDefinition(id: 'erlik_han', rules: RoundRules(firstHandScoresZero: true)),
  BossDefinition(id: 'al_karisi', rules: RoundRules(stealTileAfterHand: true)),
  BossDefinition(
    id: 'yel_ana',
    rules: RoundRules(shuffleAndHideAfterHand: true),
    minFloor: 2,
  ),
  BossDefinition(id: 'sahmeran', rules: RoundRules(runScoreFactor: 0.5)),
  BossDefinition(id: 'albasti', rules: RoundRules(noDiscards: true)),
  BossDefinition(id: 'demirkiyak', rules: RoundRules(maxTilesPerPlay: 4)),
  BossDefinition(
    id: 'kara_kus',
    rules: RoundRules(okeyIsWild: false),
    minFloor: 2,
  ),
];

final Map<String, BossDefinition> bossesById = {
  for (final b in allBosses) b.id: b,
};
