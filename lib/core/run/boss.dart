import '../round/round_rules.dart';

/// A boss ("mitolojik varlık"): a round restriction. Instances live in
/// `lib/data/bosses.dart`; names are localized by [id].
class BossDefinition {
  const BossDefinition({
    required this.id,
    required this.rules,
    this.minFloor = 1,
  });

  final String id;
  final RoundRules rules;

  /// First floor on which this boss may appear.
  final int minFloor;
}
