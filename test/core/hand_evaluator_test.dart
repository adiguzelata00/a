import 'package:flutter_test/flutter_test.dart';
import 'package:tengri_taslari/core/core.dart';

import '../helpers.dart';

List<int> numbers(HandResult r) => [for (final c in r.counted) c.number];

void main() {
  group('basic hand types', () {
    test('empty selection => null', () {
      expect(evaluator.evaluate([], neutralOkey, levels()), isNull);
    });

    test('Tek Taş counts only the highest tile (1 = 15)', () {
      final r = eval(ts('R3 Y13 B1'));
      expect(r.type, HandType.single);
      expect(r.counted.single.tile.color, TileColor.blue);
      expect(r.tileChips, 15);
      expect(r.baseScore(levels()), (5 + 15) * 1);
    });

    test('Çift = same color and same number', () {
      final r = eval(ts('R5 Y9 R5'));
      expect(r.type, HandType.pair);
      expect([for (final c in r.counted) c.playedIndex], [0, 2]);
      expect(r.baseScore(levels()), (10 + 10) * 2);
    });

    test('same number but different color is not a pair', () {
      expect(eval(ts('R5 Y5')).type, HandType.single);
    });

    test('İki Çift', () {
      final r = eval(ts('R5 R5 K9 K9'));
      expect(r.type, HandType.twoPair);
      expect(r.baseScore(levels()), (20 + 28) * 2);
    });

    test('Üç Çift', () {
      final r = eval(ts('R2 R2 Y3 Y3 B4 B4'));
      expect(r.type, HandType.threePairs);
      expect(r.counted, hasLength(6));
    });

    test('Seri-3 regardless of selection order', () {
      final r = eval(ts('R6 R4 R5'));
      expect(r.type, HandType.run3);
      expect(r.baseScore(levels()), (25 + 15) * 3);
    });

    test('Seri-4 / Seri-5 / Seri-6', () {
      expect(eval(ts('B2 B3 B4 B5')).type, HandType.run4);
      expect(eval(ts('B2 B3 B4 B5 B6')).type, HandType.run5);
      expect(eval(ts('B8 B9 B10 B11 B12 B13')).type, HandType.run6);
    });

    test('Grup-3 needs 3 different colors', () {
      expect(eval(ts('R7 Y7 B7')).type, HandType.group3);
      // Duplicate color: only the pair survives.
      expect(eval(ts('R7 R7 Y7')).type, HandType.pair);
    });

    test('Grup-4', () {
      final r = eval(ts('R7 Y7 B7 K7'));
      expect(r.type, HandType.group4);
      expect(r.baseScore(levels()), (60 + 28) * 7);
    });

    test('Alaca Seri = 4 consecutive numbers, all colors different', () {
      final r = eval(ts('R3 Y4 B5 K6'));
      expect(r.type, HandType.rainbowRun);
      expect(eval(ts('R3 R4 B5 K6')).type, isNot(HandType.rainbowRun));
    });

    test('Gök Per = Grup-3 + Seri-3', () {
      final r = eval(ts('R5 Y5 B5 K8 K9 K10'));
      expect(r.type, HandType.skyMeld);
      expect(r.baseScore(levels()), (120 + 15 + 27) * 9);
    });

    test('tiles outside the meld are played but not counted', () {
      final r = eval(ts('R4 R5 R6 K13'));
      expect(r.type, HandType.run3);
      expect(r.played, hasLength(4));
      expect(r.counted, hasLength(3));
      expect(r.tileChips, 15);
    });
  });

  group('run boundaries (okey rules)', () {
    test('12-13-1 is a valid run, 1 counts 15', () {
      final r = eval(ts('K12 K13 K1'));
      expect(r.type, HandType.run3);
      expect(r.tileChips, 12 + 13 + 15);
    });

    test('1-2-3 is a valid run', () {
      expect(eval(ts('K1 K2 K3')).type, HandType.run3);
    });

    test('13-1-2 is NOT a valid run', () {
      expect(eval(ts('K13 K1 K2')).type, isNot(HandType.run3));
    });

    test('9-10-11-12-13-1 is a valid Seri-6', () {
      expect(eval(ts('B9 B10 B11 B12 B13 B1')).type, HandType.run6);
    });

    test('duplicate numbers break a run', () {
      expect(eval(ts('R4 R4 R5')).type, HandType.pair);
    });
  });

  group('okey as joker', () {
    final okey = okeyIs('Y5'); // every Y5 is wild

    test('fills a gap in a run', () {
      final r = eval([t('R4'), t('Y5'), t('R6')], okey: okey);
      expect(r.type, HandType.run3);
      final wild = r.counted.firstWhere((c) => c.usedAsWild);
      expect(wild.number, 5);
      expect(wild.color, TileColor.red);
      expect(r.usesWild, isTrue);
    });

    test('takes the highest scoring value (12-13-okey => okey = 1)', () {
      final r = eval([t('K12'), t('K13'), t('Y5')], okey: okey);
      expect(r.type, HandType.run3);
      expect(numbers(r), [12, 13, 1]);
      expect(r.tileChips, 40);
    });

    test('13-1-okey becomes 12-13-1', () {
      final r = eval([t('K13'), t('K1'), t('Y5')], okey: okey);
      expect(r.type, HandType.run3);
      expect(numbers(r)..sort(), [1, 12, 13]);
    });

    test('completes a group with a missing color', () {
      final r = eval([t('R9'), t('K9'), t('Y5')], okey: okey);
      expect(r.type, HandType.group3);
      final wild = r.counted.firstWhere((c) => c.usedAsWild);
      expect(wild.number, 9);
      expect(wild.color, isNot(anyOf(TileColor.red, TileColor.black)));
    });

    test('completes a rainbow run', () {
      final r = eval([t('R3'), t('Y4'), t('Y5'), t('K6')], okey: okey);
      expect(r.type, HandType.rainbowRun);
      final wild = r.counted.firstWhere((c) => c.usedAsWild);
      expect(wild.number, 5);
      expect(wild.color, TileColor.blue);
    });

    test('two okeys + one tile: the best of run and group is chosen', () {
      // run 10-11-12 = (25+33)×3 = 174, group 10s = (30+30)×3 = 180.
      final r = eval([t('R10'), t('Y5'), t('Y5')], okey: okey);
      expect(r.type, HandType.group3);
      expect(r.baseScore(levels()), 180);
    });

    test('two okeys alone form a pair of 1s', () {
      final r = eval([t('Y5'), t('Y5')], okey: okey);
      expect(r.type, HandType.pair);
      expect(r.tileChips, 30);
    });

    test('single okey counts as 15', () {
      final r = eval([t('Y5')], okey: okey);
      expect(r.type, HandType.single);
      expect(r.tileChips, 15);
    });

    test('okey makes a Seri-5 out of four tiles', () {
      final r = eval([t('B2'), t('B3'), t('Y5'), t('B5'), t('B6')], okey: okey);
      expect(r.type, HandType.run5);
      expect(numbers(r), [2, 3, 4, 5, 6]);
    });
  });

  group('Gök Taşı (color wildcard)', () {
    test('counts as any color in a run', () {
      final r = eval([t('Y4'), t('K5', enh: Enhancement.skyStone), t('Y6')]);
      expect(r.type, HandType.run3);
      final sky = r.counted[1];
      expect(sky.anyColor, isTrue);
      expect(sky.matchesColor(TileColor.red), isTrue);
      expect(sky.number, 5, reason: 'number stays fixed');
    });

    test('can complete a group despite a duplicate color', () {
      final r = eval([t('R8'), t('R8', enh: Enhancement.skyStone), t('Y8')]);
      expect(r.type, HandType.group3);
    });
  });

  group('best hand selection', () {
    test('Gök Per beats the Seri-4 / Grup-3 inside it', () {
      final r = eval(ts('R4 R5 R6 R7 Y7 B7'));
      expect(r.type, HandType.skyMeld);
    });

    test('hand levels change the chosen hand', () {
      final tiles = ts('R2 R3 R4 Y4 B4');
      expect(eval(tiles).type, HandType.group3);
      final lv = levels()..levelUp(HandType.run3, 2);
      expect(eval(tiles, lv: lv).type, HandType.run3);
    });

    test('Üç Çift beats İki Çift', () {
      expect(eval(ts('R2 R2 Y3 Y3 B4 B4')).type, HandType.threePairs);
    });
  });

  group('HandLevels', () {
    test('each level adds the configured increment', () {
      final lv = levels();
      final c1 = lv.chipsOf(HandType.run4);
      final m1 = lv.multOf(HandType.run4);
      lv.levelUp(HandType.run4);
      final s = lv.table[HandType.run4]!;
      expect(lv.levelOf(HandType.run4), 2);
      expect(lv.chipsOf(HandType.run4), c1 + s.chipsPerLevel);
      expect(lv.multOf(HandType.run4), m1 + s.multPerLevel);
    });

    test('json round-trip', () {
      final lv = levels()..levelUp(HandType.pair, 3);
      final restored = HandLevels.fromJson(lv.table, lv.toJson());
      expect(restored.levelOf(HandType.pair), 4);
      expect(restored.levelOf(HandType.run3), 1);
    });
  });
}
