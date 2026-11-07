import 'package:flutter_test/flutter_test.dart';
import 'package:tengri_taslari/core/core.dart';

import '../helpers.dart';

void main() {
  group('RunDeck.standard', () {
    final deck = RunDeck.standard();

    test('has 106 tiles with unique ids', () {
      expect(deck.length, 106);
      expect(deck.tiles.map((t) => t.id).toSet(), hasLength(106));
    });

    test('has 2 of every color/number and 2 fake okeys', () {
      final real = deck.tiles.where((t) => !t.isFakeOkey).toList();
      expect(real, hasLength(104));
      for (final c in TileColor.values) {
        for (var n = 1; n <= 13; n++) {
          expect(real.where((t) => t.color == c && t.number == n), hasLength(2));
        }
      }
      expect(deck.tiles.where((t) => t.isFakeOkey), hasLength(2));
    });

    test('copy / remove / replace keep ids unique', () {
      final d = RunDeck.standard();
      final copy = d.addCopyOf(d.tiles.first);
      expect(d.length, 107);
      expect(copy.id, isNot(d.tiles.first.id));
      expect(d.remove(copy.id), isTrue);
      expect(d.remove(copy.id), isFalse);
      d.replace(d.tiles.first.copyWith(enhancement: Enhancement.iron));
      expect(d.tiles.first.enhancement, Enhancement.iron);
    });

    test('json round-trip', () {
      final d = RunDeck.standard();
      d.replace(d.tiles[3].copyWith(enhancement: Enhancement.gold, seal: Seal.crimson));
      final restored = RunDeck.fromJson(d.toJson());
      expect(restored.tiles, d.tiles);
      expect(restored.allocateId(), d.allocateId());
    });
  });

  group('DrawPile', () {
    test('same seed => same order', () {
      final tiles = RunDeck.standard().tiles;
      final a = DrawPile.shuffled(tiles, SeededRng(1)).draw(10);
      final b = DrawPile.shuffled(tiles, SeededRng(1)).draw(10);
      final c = DrawPile.shuffled(tiles, SeededRng(2)).draw(10);
      expect(a, b);
      expect(a, isNot(c));
    });

    test('draw never exceeds remaining tiles', () {
      final pile = DrawPile.ordered(ts('R1 R2 R3'));
      expect(pile.draw(5), hasLength(3));
      expect(pile.isEmpty, isTrue);
    });
  });

  group('chip values', () {
    test('1 counts as 15, others face value', () {
      expect(chipValueOf(1), 15);
      expect(chipValueOf(2), 2);
      expect(chipValueOf(13), 13);
    });
  });
}
