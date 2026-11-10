/// The four tile colors of an okey set.
///
/// Each color is also identified by a symbol in the UI (color-blind support):
/// red = sun, yellow = star, blue = moon, black = mountain.
enum TileColor { red, yellow, blue, black }

/// Tile material upgrade ("geliştirme").
enum Enhancement {
  none,

  /// Kemik: +chips when counted.
  bone,

  /// Demir: ×mult every hand while *held* in the rack.
  iron,

  /// Altın: money at round end while held in the rack.
  gold,

  /// Kristal: ×mult when counted, may shatter.
  crystal,

  /// Gök Taşı: counts as every color (color wildcard, number fixed).
  skyStone,
}

/// Seal stamped on a tile ("tamga").
enum Seal {
  none,

  /// Kızıl Tamga: tile triggers twice.
  crimson,

  /// Altın Tamga: money when counted.
  gold,

  /// Gök Tamga: creates a Destan at round end while held.
  sky,

  /// Mor Tamga: creates a Tılsım when discarded.
  purple,
}

/// Lowest / highest face number of a tile.
const int minTileNumber = 1;
const int maxTileNumber = 13;

/// Chip value of a tile number: 1 counts as 15, everything else face value.
int chipValueOf(int number) => number == 1 ? 15 : number;

/// Immutable okey tile.
///
/// [id] is unique within a run deck and identifies a physical tile (two
/// "red 5" tiles have different ids). For a fake okey ([isFakeOkey]) the
/// [color] / [number] fields are meaningless: its face is resolved from the
/// round's okey (see `OkeyInfo.faceOf`).
class Tile {
  const Tile({
    required this.id,
    required this.color,
    required this.number,
    this.isFakeOkey = false,
    this.enhancement = Enhancement.none,
    this.seal = Seal.none,
  }) : assert(number >= minTileNumber && number <= maxTileNumber);

  /// Convenience constructor for a fake okey tile.
  const Tile.fakeOkey({
    required this.id,
    this.enhancement = Enhancement.none,
    this.seal = Seal.none,
  }) : color = TileColor.black,
       number = 1,
       isFakeOkey = true;

  final int id;
  final TileColor color;
  final int number;
  final bool isFakeOkey;
  final Enhancement enhancement;
  final Seal seal;

  Tile copyWith({
    int? id,
    TileColor? color,
    int? number,
    bool? isFakeOkey,
    Enhancement? enhancement,
    Seal? seal,
  }) => Tile(
    id: id ?? this.id,
    color: color ?? this.color,
    number: number ?? this.number,
    isFakeOkey: isFakeOkey ?? this.isFakeOkey,
    enhancement: enhancement ?? this.enhancement,
    seal: seal ?? this.seal,
  );

  Map<String, Object> toJson() => {
    'id': id,
    'c': color.index,
    'n': number,
    if (isFakeOkey) 'f': true,
    if (enhancement != Enhancement.none) 'e': enhancement.index,
    if (seal != Seal.none) 's': seal.index,
  };

  factory Tile.fromJson(Map<String, dynamic> json) => Tile(
    id: json['id'] as int,
    color: TileColor.values[json['c'] as int],
    number: json['n'] as int,
    isFakeOkey: (json['f'] as bool?) ?? false,
    enhancement: Enhancement.values[(json['e'] as int?) ?? 0],
    seal: Seal.values[(json['s'] as int?) ?? 0],
  );

  @override
  bool operator ==(Object other) =>
      other is Tile &&
      other.id == id &&
      other.color == color &&
      other.number == number &&
      other.isFakeOkey == isFakeOkey &&
      other.enhancement == enhancement &&
      other.seal == seal;

  @override
  int get hashCode =>
      Object.hash(id, color, number, isFakeOkey, enhancement, seal);

  /// Debug representation, e.g. `R5#12`, `FAKE#105`, `B13+iron`.
  @override
  String toString() {
    final face = isFakeOkey ? 'FAKE' : '${color.name[0].toUpperCase()}$number';
    final extras = [
      if (enhancement != Enhancement.none) enhancement.name,
      if (seal != Seal.none) 'seal:${seal.name}',
    ];
    return '$face#$id${extras.isEmpty ? '' : '+${extras.join('+')}'}';
  }
}
