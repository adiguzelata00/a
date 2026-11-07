import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/data/balance.dart';

var _nextId = 1000;

/// Parses a tile code: `R5` red 5, `Y13` yellow 13, `B1` blue 1,
/// `K7` black (kara) 7, `F` fake okey.
/// Options: `enh` enhancement, `seal` seal.
Tile t(
  String code, {
  Enhancement enh = Enhancement.none,
  Seal seal = Seal.none,
}) {
  if (code == 'F') {
    return Tile.fakeOkey(id: _nextId++, enhancement: enh, seal: seal);
  }
  final color = switch (code[0]) {
    'R' => TileColor.red,
    'Y' => TileColor.yellow,
    'B' => TileColor.blue,
    'K' => TileColor.black,
    _ => throw ArgumentError(code),
  };
  return Tile(
    id: _nextId++,
    color: color,
    number: int.parse(code.substring(1)),
    enhancement: enh,
    seal: seal,
  );
}

List<Tile> ts(String codes) => [for (final c in codes.split(' ')) t(c)];

/// Okey info whose *okey* is [okeyCode] (indicator = one below).
OkeyInfo okeyIs(String okeyCode, {bool wild = true}) {
  final o = t(okeyCode);
  final indicatorNumber = o.number == 1 ? 13 : o.number - 1;
  return OkeyInfo(
    indicator: o.copyWith(number: indicatorNumber),
    okeyIsWild: wild,
  );
}

/// A neutral okey (black 13 -> okey black 1) for tests that don't use okeys.
OkeyInfo get neutralOkey => okeyIs('K1');

HandLevels levels() => Balance.newHandLevels();

const evaluator = HandEvaluator();

HandResult eval(List<Tile> tiles, {OkeyInfo? okey, HandLevels? lv}) =>
    evaluator.evaluate(tiles, okey ?? neutralOkey, lv ?? levels())!;
