import 'package:flutter_test/flutter_test.dart';
import 'package:tengri_taslari/core/core.dart';

void main() {
  group('SeededRng', () {
    test('same seed produces the same sequence', () {
      final a = SeededRng(42);
      final b = SeededRng(42);
      expect(List.generate(50, (_) => a.nextUint32()),
          List.generate(50, (_) => b.nextUint32()));
    });

    test('different seeds produce different sequences', () {
      final a = SeededRng(1);
      final b = SeededRng(2);
      expect(List.generate(10, (_) => a.nextUint32()),
          isNot(List.generate(10, (_) => b.nextUint32())));
    });

    test('golden values stay stable across versions/platforms', () {
      // If this fails, saved runs / shared seeds would change behaviour.
      final r = SeededRng(12345);
      expect(List.generate(3, (_) => r.nextUint32()),
          [518667457, 440444462, 4232892992]);
      expect(seedFromCode('TENGRI42'), 2749712248);
    });

    test('nextInt stays within bounds and covers the range', () {
      final r = SeededRng(7);
      final seen = <int>{};
      for (var i = 0; i < 2000; i++) {
        final v = r.nextInt(6);
        expect(v, inInclusiveRange(0, 5));
        seen.add(v);
      }
      expect(seen, hasLength(6));
    });

    test('nextDouble is in [0,1)', () {
      final r = SeededRng(9);
      for (var i = 0; i < 1000; i++) {
        expect(r.nextDouble(), allOf(greaterThanOrEqualTo(0), lessThan(1)));
      }
    });

    test('shuffle is a deterministic permutation', () {
      final a = List.generate(30, (i) => i);
      final b = List.generate(30, (i) => i);
      SeededRng(99).shuffle(a);
      SeededRng(99).shuffle(b);
      expect(a, b);
      expect(a.toSet(), List.generate(30, (i) => i).toSet());
      expect(a, isNot(List.generate(30, (i) => i)));
    });

    test('fork depends on seed + label, not on consumed state', () {
      final r1 = SeededRng(5);
      final r2 = SeededRng(5);
      for (var i = 0; i < 100; i++) {
        r2.nextUint32();
      }
      expect(r1.fork('shop').nextUint32(), r2.fork('shop').nextUint32());
      expect(r1.fork('shop').nextUint32(), isNot(r1.fork('deck').nextUint32()));
    });

    test('state round-trips', () {
      final r = SeededRng(77);
      r.nextUint32();
      final restored = SeededRng.fromState(r.state);
      expect(restored.nextUint32(), r.nextUint32());
      expect(restored.seed, r.seed);
    });

    test('seed codes are case/whitespace insensitive', () {
      expect(seedFromCode(' tengri42 '), seedFromCode('TENGRI42'));
      expect(seedFromCode('A'), isNot(seedFromCode('B')));
    });

    test('generateSeedCode uses the unambiguous alphabet', () {
      final code = generateSeedCode(SeededRng(3));
      expect(code, hasLength(8));
      expect(code.split('').every(seedCodeAlphabet.contains), isTrue);
    });
  });
}
