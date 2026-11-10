import 'package:flutter_test/flutter_test.dart';
import 'package:tengri_taslari/core/core.dart';

import '../helpers.dart';

void main() {
  group('Okey from indicator', () {
    test('okey is one above the indicator, same color', () {
      final info = OkeyInfo(indicator: t('B7'));
      expect(info.okeyFace, const TileFace(TileColor.blue, 8));
    });

    test('13 wraps to 1', () {
      final info = OkeyInfo(indicator: t('R13'));
      expect(info.okeyFace, const TileFace(TileColor.red, 1));
    });

    test('fake okey can not be an indicator', () {
      expect(() => OkeyInfo(indicator: t('F')), throwsA(isA<AssertionError>()));
    });

    test('isOkey / isWild', () {
      final info = OkeyInfo(indicator: t('Y4'));
      expect(info.isOkey(t('Y5')), isTrue);
      expect(info.isWild(t('Y5')), isTrue);
      expect(info.isOkey(t('R5')), isFalse);
      expect(info.isOkey(t('F')), isFalse, reason: 'fake okey is not a joker');
      final noWild = info.copyWith(okeyIsWild: false);
      expect(noWild.isOkey(t('Y5')), isTrue);
      expect(noWild.isWild(t('Y5')), isFalse);
    });

    test('fake okey takes the okey face', () {
      final info = OkeyInfo(indicator: t('K12'));
      expect(info.faceOf(t('F')), const TileFace(TileColor.black, 13));
      expect(info.faceOf(t('R3')), const TileFace(TileColor.red, 3));
    });
  });

  group('Fake okey in melds', () {
    test('fake okey acts as a normal tile with the okey value', () {
      final okey = okeyIs('B8'); // fake okey = blue 8
      final r = eval([t('B6'), t('B7'), t('F')], okey: okey);
      expect(r.type, HandType.run3);
      expect(r.counted.map((c) => c.number), [6, 7, 8]);
      expect(r.usesWild, isFalse);
    });

    test('fake okey is not a joker', () {
      final okey = okeyIs('B8');
      final r = eval([t('R2'), t('R3'), t('F')], okey: okey);
      expect(r.type, isNot(HandType.run3));
    });
  });

  group('Kara Kuş: okey not wild', () {
    test('real okey behaves as its face value', () {
      final wild = okeyIs('Y5');
      final notWild = okeyIs('Y5', wild: false);
      final tiles = [t('R9'), t('R10'), t('Y5')];
      expect(eval(tiles, okey: wild).type, HandType.run3);
      final r = eval(tiles, okey: notWild);
      expect(r.type, HandType.single);
    });
  });
}
