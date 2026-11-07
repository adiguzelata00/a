import '../tiles/okey.dart';
import '../tiles/tile.dart';

/// "Sayıya göre diz": by number (1 last, as it is mostly played high),
/// then color. Wild okeys go to the far right.
List<Tile> sortByNumber(List<Tile> tiles, OkeyInfo okey) {
  int key(Tile t) {
    final f = okey.faceOf(t);
    return _numberRank(f.number) * 10 + f.color.index;
  }

  return _sortWithWildsLast(tiles, okey, key);
}

/// "Renge göre diz": by color, then number. Wild okeys go to the far right.
List<Tile> sortByColor(List<Tile> tiles, OkeyInfo okey) {
  int key(Tile t) {
    final f = okey.faceOf(t);
    return f.color.index * 100 + _numberRank(f.number);
  }

  return _sortWithWildsLast(tiles, okey, key);
}

/// RULE DECISION: 1 is sorted after 13 because it scores 15 chips and
/// 12-13-1 runs are common; 1-2-3 runs are still easy to see.
int _numberRank(int number) => number == 1 ? 14 : number;

List<Tile> _sortWithWildsLast(
  List<Tile> tiles,
  OkeyInfo okey,
  int Function(Tile) key,
) {
  final indexed = [for (var i = 0; i < tiles.length; i++) (i, tiles[i])];
  indexed.sort((a, b) {
    final wa = okey.isWild(a.$2) ? 1 : 0;
    final wb = okey.isWild(b.$2) ? 1 : 0;
    if (wa != wb) return wa - wb;
    final c = key(a.$2).compareTo(key(b.$2));
    // Stable: keep original order for equal keys.
    return c != 0 ? c : a.$1.compareTo(b.$1);
  });
  return [for (final e in indexed) e.$2];
}
