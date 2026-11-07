import '../tiles/okey.dart';
import '../tiles/tile.dart';
import 'hand_type.dart';

/// A tile that is part of the scoring meld, with its resolved face.
class CountedTile {
  const CountedTile({
    required this.playedIndex,
    required this.tile,
    required this.number,
    required this.color,
    required this.anyColor,
    required this.usedAsWild,
  });

  /// Index of the tile in the played list (left to right).
  final int playedIndex;
  final Tile tile;

  /// Number the tile represents in the meld (wild okey -> assigned number).
  final int number;

  /// Color the tile represents in the meld (wild okey -> assigned color).
  final TileColor color;

  /// Gök Taşı: the tile counts as every color for color checks.
  final bool anyColor;

  /// Real okey used as a joker.
  final bool usedAsWild;

  int get chipValue => chipValueOf(number);

  /// Color check used by effects such as "every red tile counted".
  bool matchesColor(TileColor c) => anyColor || color == c;

  @override
  String toString() =>
      'Counted(#$playedIndex ${color.name}$number${usedAsWild ? ' wild' : ''})';
}

/// Result of evaluating a set of played tiles.
class HandResult {
  const HandResult({
    required this.type,
    required this.counted,
    required this.played,
  });

  final HandType type;

  /// Tiles that make up the meld, ordered left to right (by played index).
  final List<CountedTile> counted;

  /// All played tiles (left to right). Tiles not in [counted] score nothing
  /// but are still played and discarded.
  final List<Tile> played;

  /// Sum of the counted tiles' chip values.
  int get tileChips => counted.fold(0, (sum, t) => sum + t.chipValue);

  /// Whether a wild okey is part of the meld.
  bool get usesWild => counted.any((t) => t.usedAsWild);

  /// Preview score without any effects: (base chips + tiles) × base mult.
  int baseScore(HandLevels levels) =>
      (levels.chipsOf(type) + tileChips) * levels.multOf(type);

  @override
  String toString() => 'HandResult(${type.name}, $counted)';
}

/// Finds the best scoring hand type in a selection of tiles.
///
/// Wild okeys and Gök Taşı tiles are resolved automatically to the
/// assignment that maximises the preview score
/// `(handChips + countedTileChips) × handMult` at the current hand levels.
/// Effects (Kut, enhancements ...) are intentionally NOT part of the choice:
/// the preview shown to the player must match the chosen hand.
class HandEvaluator {
  const HandEvaluator();

  /// Evaluates [played] (in rack order). Returns null for an empty list.
  HandResult? evaluate(List<Tile> played, OkeyInfo okey, HandLevels levels) {
    if (played.isEmpty) return null;
    final slots = [
      for (var i = 0; i < played.length; i++) _Slot.from(i, played[i], okey),
    ];

    HandResult? best;
    var bestScore = -1;

    void consider(HandType type, List<_Assigned>? assignment) {
      if (assignment == null) return;
      final counted = [
        for (final a in assignment)
          CountedTile(
            playedIndex: a.slot.index,
            tile: a.slot.tile,
            number: a.number,
            color: a.color,
            anyColor: a.slot.anyColor,
            usedAsWild: a.slot.wild,
          ),
      ]..sort((x, y) => x.playedIndex.compareTo(y.playedIndex));
      final result = HandResult(type: type, counted: counted, played: played);
      final score = result.baseScore(levels);
      if (score > bestScore ||
          (score == bestScore && type.index > best!.type.index)) {
        best = result;
        bestScore = score;
      }
    }

    for (final type in HandType.values) {
      if (type.size > slots.length) continue;
      for (final subset in _combinations(slots, type.size)) {
        consider(type, _bestAssignment(type, subset));
      }
    }
    return best;
  }

  /// Best assignment (highest tile chips) of [s] as [type], or null.
  static List<_Assigned>? _bestAssignment(HandType type, List<_Slot> s) {
    switch (type) {
      case HandType.single:
        return _single(s.single);
      case HandType.pair:
        return _pair(s);
      case HandType.twoPair:
      case HandType.threePairs:
        return _multiPair(s);
      case HandType.run3:
      case HandType.run4:
      case HandType.run5:
      case HandType.run6:
        return _run(s, distinctColors: false);
      case HandType.rainbowRun:
        return _run(s, distinctColors: true);
      case HandType.group3:
      case HandType.group4:
        return _group(s);
      case HandType.skyMeld:
        return _skyMeld(s);
    }
  }

  static List<_Assigned> _single(_Slot slot) => [
    _Assigned(slot, slot.number ?? 1, slot.color ?? TileColor.red),
  ];

  static List<_Assigned>? _pair(List<_Slot> s) {
    final colors = _assignColors(s, distinct: false);
    if (colors == null) return null;
    final number = _commonNumber(s);
    if (number == null) return null;
    return [
      for (var i = 0; i < s.length; i++) _Assigned(s[i], number, colors[i]),
    ];
  }

  /// Best partition of [s] (even length) into valid pairs.
  static List<_Assigned>? _multiPair(List<_Slot> s) {
    if (s.isEmpty) return [];
    final first = s.first;
    List<_Assigned>? best;
    var bestValue = -1;
    for (var j = 1; j < s.length; j++) {
      final pair = _pair([first, s[j]]);
      if (pair == null) continue;
      final rest = [
        for (var k = 1; k < s.length; k++)
          if (k != j) s[k],
      ];
      final restAssign = _multiPair(rest);
      if (restAssign == null) continue;
      final all = [...pair, ...restAssign];
      final value = _value(all);
      if (value > bestValue) {
        best = all;
        bestValue = value;
      }
    }
    return best;
  }

  static List<_Assigned>? _group(List<_Slot> s) {
    if (s.length > TileColor.values.length) return null;
    final colors = _assignColors(s, distinct: true);
    if (colors == null) return null;
    final number = _commonNumber(s);
    if (number == null) return null;
    return [
      for (var i = 0; i < s.length; i++) _Assigned(s[i], number, colors[i]),
    ];
  }

  /// Runs use "positions" 1..14 where position 14 is a 1 placed after 13.
  /// This makes 12-13-1 valid while 13-1-2 is not.
  static List<_Assigned>? _run(List<_Slot> s, {required bool distinctColors}) {
    final k = s.length;
    if (distinctColors && k > TileColor.values.length) return null;
    final colors = _assignColors(s, distinct: distinctColors);
    if (colors == null) return null;

    List<int>? bestPositions;
    var bestValue = -1;
    for (var start = 1; start + k - 1 <= 14; start++) {
      final end = start + k - 1;
      final positions = List<int>.filled(k, 0);
      final used = <int>{};
      var ok = true;
      for (var i = 0; i < k && ok; i++) {
        final n = s[i].number;
        if (n == null) continue;
        int pos;
        if (n == 1) {
          pos = start == 1 ? 1 : 14;
        } else {
          pos = n;
        }
        if (pos < start || pos > end || !used.add(pos)) {
          ok = false;
        } else {
          positions[i] = pos;
        }
      }
      if (!ok) continue;
      final free = [
        for (var p = start; p <= end; p++)
          if (!used.contains(p)) p,
      ];
      var f = 0;
      for (var i = 0; i < k; i++) {
        if (s[i].number == null) positions[i] = free[f++];
      }
      var value = 0;
      for (var p = start; p <= end; p++) {
        value += chipValueOf(_numberAtPosition(p));
      }
      if (value > bestValue) {
        bestValue = value;
        bestPositions = positions;
      }
    }
    if (bestPositions == null) return null;
    return [
      for (var i = 0; i < k; i++)
        _Assigned(s[i], _numberAtPosition(bestPositions[i]), colors[i]),
    ];
  }

  static List<_Assigned>? _skyMeld(List<_Slot> s) {
    List<_Assigned>? best;
    var bestValue = -1;
    for (final groupPart in _combinations(s, 3)) {
      final runPart = [
        for (final slot in s)
          if (!groupPart.contains(slot)) slot,
      ];
      final g = _group(groupPart);
      if (g == null) continue;
      final r = _run(runPart, distinctColors: false);
      if (r == null) continue;
      final all = [...g, ...r];
      final value = _value(all);
      if (value > bestValue) {
        best = all;
        bestValue = value;
      }
    }
    return best;
  }

  static int _numberAtPosition(int p) => p == 14 ? 1 : p;

  static int _value(List<_Assigned> a) =>
      a.fold(0, (sum, x) => sum + chipValueOf(x.number));

  /// The number all fixed slots share (1 if every slot is wild),
  /// or null when fixed numbers differ.
  static int? _commonNumber(List<_Slot> s) {
    int? number;
    for (final slot in s) {
      final n = slot.number;
      if (n == null) continue;
      if (number != null && number != n) return null;
      number = n;
    }
    // All wild: 1 has the highest chip value.
    return number ?? 1;
  }

  /// Assigns a concrete color to every slot or returns null if impossible.
  ///
  /// [distinct] = all colors must differ (groups, rainbow runs); otherwise all
  /// colors must be equal. Slots without a fixed color (wild okey, Gök Taşı)
  /// take the shared color or the remaining colors in enum order.
  static List<TileColor>? _assignColors(
    List<_Slot> s, {
    required bool distinct,
  }) {
    final fixed = [
      for (final slot in s)
        if (slot.color != null) slot.color!,
    ];
    if (!distinct) {
      final set = fixed.toSet();
      if (set.length > 1) return null;
      final color = set.isEmpty ? TileColor.red : set.single;
      return List.filled(s.length, color);
    }
    if (fixed.toSet().length != fixed.length) return null;
    final remaining = [
      for (final c in TileColor.values)
        if (!fixed.contains(c)) c,
    ];
    var r = 0;
    final result = <TileColor>[];
    for (final slot in s) {
      if (slot.color != null) {
        result.add(slot.color!);
      } else {
        if (r >= remaining.length) return null;
        result.add(remaining[r++]);
      }
    }
    return result;
  }
}

/// All k-element combinations of [items], preserving order.
Iterable<List<T>> _combinations<T>(List<T> items, int k) sync* {
  if (k == 0) {
    yield <T>[];
    return;
  }
  for (var i = 0; i <= items.length - k; i++) {
    for (final rest in _combinations(items.sublist(i + 1), k - 1)) {
      yield [items[i], ...rest];
    }
  }
}

/// A played tile prepared for matching. `null` number/color = wildcard.
class _Slot {
  _Slot(
    this.index,
    this.tile,
    this.number,
    this.color,
    this.wild,
    this.anyColor,
  );

  factory _Slot.from(int index, Tile tile, OkeyInfo okey) {
    final anyColor = tile.enhancement == Enhancement.skyStone;
    if (okey.isWild(tile)) {
      return _Slot(index, tile, null, null, true, anyColor);
    }
    final face = okey.faceOf(tile);
    return _Slot(
      index,
      tile,
      face.number,
      anyColor ? null : face.color,
      false,
      anyColor,
    );
  }

  final int index;
  final Tile tile;
  final int? number;
  final TileColor? color;
  final bool wild;
  final bool anyColor;
}

class _Assigned {
  _Assigned(this.slot, this.number, this.color);
  final _Slot slot;
  final int number;
  final TileColor color;
}
