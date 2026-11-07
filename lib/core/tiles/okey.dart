import 'tile.dart';

/// The face (color + number) a tile shows in a given round.
class TileFace {
  const TileFace(this.color, this.number);
  final TileColor color;
  final int number;

  @override
  bool operator ==(Object other) =>
      other is TileFace && other.color == color && other.number == number;

  @override
  int get hashCode => Object.hash(color, number);

  @override
  String toString() => '${color.name}$number';
}

/// Number following [number] in okey order: 13 wraps to 1.
int nextTileNumber(int number) => number == maxTileNumber ? 1 : number + 1;

/// Indicator / okey information for one round.
///
/// * The okey is the tile one above the indicator (same color, 13 -> 1).
/// * Real okey tiles are jokers ([isWild]) unless [okeyIsWild] is false
///   (e.g. the "Kara Kuş" boss).
/// * Fake okeys take the okey's face and behave like normal tiles.
class OkeyInfo {
  OkeyInfo({required this.indicator, this.okeyIsWild = true})
      : assert(!indicator.isFakeOkey, 'A fake okey can not be the indicator'),
        okeyFace = TileFace(indicator.color, nextTileNumber(indicator.number));

  final Tile indicator;
  final TileFace okeyFace;
  final bool okeyIsWild;

  OkeyInfo copyWith({bool? okeyIsWild}) =>
      OkeyInfo(indicator: indicator, okeyIsWild: okeyIsWild ?? this.okeyIsWild);

  /// Whether [tile] is a real okey tile (regardless of wildness).
  bool isOkey(Tile tile) =>
      !tile.isFakeOkey &&
      tile.color == okeyFace.color &&
      tile.number == okeyFace.number;

  /// Whether [tile] acts as a joker this round.
  bool isWild(Tile tile) => okeyIsWild && isOkey(tile);

  /// The face [tile] represents this round (fake okey -> okey face).
  TileFace faceOf(Tile tile) =>
      tile.isFakeOkey ? okeyFace : TileFace(tile.color, tile.number);
}
