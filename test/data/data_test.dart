import 'package:flutter_test/flutter_test.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/data/balance.dart';
import 'package:tengri_taslari/data/bosses.dart';
import 'package:tengri_taslari/data/kuts.dart';

void main() {
  test('at least 20 Kuts with unique ids and sensible prices', () {
    expect(allKuts.length, greaterThanOrEqualTo(24));
    expect(allKuts.map((k) => k.id).toSet(), hasLength(allKuts.length));
    for (final k in allKuts) {
      expect(k.sellValue, k.price ~/ 2);
      expect(k.price, greaterThan(0));
    }
  });

  test('at least 8 bosses with unique ids', () {
    expect(allBosses.length, greaterThanOrEqualTo(12));
    expect(bossesById, hasLength(allBosses.length));
  });

  test('every hand type has stats; base table matches the design', () {
    for (final h in HandType.values) {
      expect(Balance.hands[h], isNotNull, reason: h.name);
    }
    expect(Balance.hands[HandType.skyMeld]!.chips, 120);
    expect(Balance.hands[HandType.skyMeld]!.mult, 9);
    expect(Balance.hands[HandType.group4]!.mult, 7);
  });

  test(
    'targets: floor 1 = 250/375/500, increasing within and across floors',
    () {
      expect(Balance.targetFor(1, 0), 250);
      expect(Balance.targetFor(1, 1), 375);
      expect(Balance.targetFor(1, 2), 500);
      for (var f = 1; f <= 10; f++) {
        expect(Balance.targetFor(f, 1), greaterThan(Balance.targetFor(f, 0)));
        expect(Balance.targetFor(f, 2), greaterThan(Balance.targetFor(f, 1)));
        if (f > 1) {
          // Same slot on the next floor grows ~1.6-1.9×.
          final growth = Balance.targetFor(f, 0) / Balance.targetFor(f - 1, 0);
          expect(growth, inInclusiveRange(1.6, 1.95));
        }
      }
    },
  );
}
