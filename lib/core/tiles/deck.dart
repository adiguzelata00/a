import '../rng/seeded_rng.dart';
import 'tile.dart';

/// Number of copies of each colored tile in a classic set.
const int copiesPerTile = 2;

/// Number of fake okey tiles in a classic set.
const int fakeOkeyCount = 2;

/// The player's persistent tile collection for a whole run.
///
/// Tılsım effects (copy, destroy, enhance ...) mutate this deck. Each round
/// draws from a shuffled copy of it (see [DrawPile]).
class RunDeck {
  RunDeck(List<Tile> tiles, {int? nextId})
      : _tiles = List.of(tiles),
        _nextId = nextId ??
            (tiles.isEmpty
                ? 0
                : tiles.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1);

  /// Classic 106 tile okey set: 4 colors × 1..13 × 2 copies + 2 fake okeys.
  factory RunDeck.standard() {
    final tiles = <Tile>[];
    var id = 0;
    for (final color in TileColor.values) {
      for (var number = minTileNumber; number <= maxTileNumber; number++) {
        for (var copy = 0; copy < copiesPerTile; copy++) {
          tiles.add(Tile(id: id++, color: color, number: number));
        }
      }
    }
    for (var i = 0; i < fakeOkeyCount; i++) {
      tiles.add(Tile.fakeOkey(id: id++));
    }
    return RunDeck(tiles, nextId: id);
  }

  final List<Tile> _tiles;
  int _nextId;

  List<Tile> get tiles => List.unmodifiable(_tiles);
  int get length => _tiles.length;

  /// Allocates a fresh unique tile id.
  int allocateId() => _nextId++;

  /// Adds a copy of [tile] with a new id and returns it.
  Tile addCopyOf(Tile tile) {
    final copy = tile.copyWith(id: allocateId());
    _tiles.add(copy);
    return copy;
  }

  /// Replaces the tile with the same id as [tile].
  void replace(Tile tile) {
    final index = _tiles.indexWhere((t) => t.id == tile.id);
    if (index < 0) throw StateError('Tile ${tile.id} not in deck');
    _tiles[index] = tile;
  }

  /// Permanently removes the tile with [id]. Returns false if absent.
  bool remove(int id) {
    final before = _tiles.length;
    _tiles.removeWhere((t) => t.id == id);
    return _tiles.length != before;
  }

  Tile? byId(int id) {
    for (final t in _tiles) {
      if (t.id == id) return t;
    }
    return null;
  }

  Map<String, Object> toJson() => {
        'next': _nextId,
        'tiles': [for (final t in _tiles) t.toJson()],
      };

  factory RunDeck.fromJson(Map<String, dynamic> json) => RunDeck(
        [
          for (final t in json['tiles'] as List)
            Tile.fromJson(Map<String, dynamic>.from(t as Map)),
        ],
        nextId: json['next'] as int,
      );
}

/// Shuffled draw pile used during a single round.
class DrawPile {
  DrawPile._(this._tiles);

  /// Creates a pile from [tiles] shuffled with [rng].
  factory DrawPile.shuffled(List<Tile> tiles, SeededRng rng) {
    final list = List.of(tiles);
    rng.shuffle(list);
    return DrawPile._(list);
  }

  /// Restores an already ordered pile (top of pile = last element).
  factory DrawPile.ordered(List<Tile> tiles) => DrawPile._(List.of(tiles));

  final List<Tile> _tiles;

  int get remaining => _tiles.length;
  bool get isEmpty => _tiles.isEmpty;
  List<Tile> get tiles => List.unmodifiable(_tiles);

  /// Draws up to [count] tiles from the top.
  List<Tile> draw(int count) {
    final n = count.clamp(0, _tiles.length);
    final drawn = <Tile>[];
    for (var i = 0; i < n; i++) {
      drawn.add(_tiles.removeLast());
    }
    return drawn;
  }

  /// Draws the first tile (from the top) that satisfies [test], or null.
  Tile? drawWhere(bool Function(Tile) test) {
    for (var i = _tiles.length - 1; i >= 0; i--) {
      if (test(_tiles[i])) return _tiles.removeAt(i);
    }
    return null;
  }
}
