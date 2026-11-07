/// Hand types ("per"), ordered from weakest to strongest.
///
/// Ordinal order is also used as a tie-breaker when two hand types produce
/// the same preview score (the higher ordinal wins).
enum HandType {
  /// Tek Taş – no meld, only the highest tile counts.
  single(size: 1),

  /// Çift – same color + same number.
  pair(size: 2),

  /// İki Çift – two separate pairs.
  twoPair(size: 4),

  /// Seri-3 – same color, 3 consecutive numbers.
  run3(size: 3, isRun: true),

  /// Grup-3 – same number, 3 different colors.
  group3(size: 3, isGroup: true),

  /// Üç Çift – three separate pairs.
  threePairs(size: 6),

  /// Seri-4 – same color, 4 consecutive numbers.
  run4(size: 4, isRun: true),

  /// Alaca Seri – 4 consecutive numbers, all different colors.
  ///
  /// RULE DECISION: the spec says "4+" but with only four colors and the
  /// "all different colors" constraint, a rainbow run can only be exactly
  /// 4 tiles long.
  rainbowRun(size: 4, isRun: true),

  /// Seri-5 – same color, 5 consecutive numbers.
  run5(size: 5, isRun: true),

  /// Grup-4 – same number, all 4 colors.
  group4(size: 4, isGroup: true),

  /// Seri-6 – same color, 6 consecutive numbers.
  run6(size: 6, isRun: true),

  /// Gök Per – a Grup-3 and a Seri-3 at the same time (6 tiles).
  skyMeld(size: 6, isRun: true, isGroup: true);

  const HandType({required this.size, this.isRun = false, this.isGroup = false});

  /// Number of tiles that make up (and are counted by) this hand type.
  final int size;

  /// Whether the hand contains a run ("Seri içeren el").
  final bool isRun;

  /// Whether the hand contains a group ("Grup içeren el").
  final bool isGroup;
}

/// Base values of a hand type and how much each level adds.
class HandStats {
  const HandStats({
    required this.chips,
    required this.mult,
    required this.chipsPerLevel,
    required this.multPerLevel,
  });

  final int chips;
  final int mult;
  final int chipsPerLevel;
  final int multPerLevel;
}

/// Current level of each hand type for a run (upgraded by Destan items).
class HandLevels {
  HandLevels(this.table, [Map<HandType, int>? levels])
      : _levels = {for (final t in HandType.values) t: levels?[t] ?? 1};

  final Map<HandType, HandStats> table;
  final Map<HandType, int> _levels;

  int levelOf(HandType type) => _levels[type]!;

  void levelUp(HandType type, [int amount = 1]) {
    _levels[type] = _levels[type]! + amount;
  }

  /// Base chips at the current level.
  int chipsOf(HandType type) {
    final s = table[type]!;
    return s.chips + (levelOf(type) - 1) * s.chipsPerLevel;
  }

  /// Base mult at the current level.
  int multOf(HandType type) {
    final s = table[type]!;
    return s.mult + (levelOf(type) - 1) * s.multPerLevel;
  }

  HandLevels copy() => HandLevels(table, Map.of(_levels));

  Map<String, int> toJson() => {for (final e in _levels.entries) e.key.name: e.value};

  factory HandLevels.fromJson(
          Map<HandType, HandStats> table, Map<String, dynamic> json) =>
      HandLevels(table, {
        for (final t in HandType.values)
          if (json[t.name] != null) t: json[t.name] as int,
      });
}
