import 'package:flutter_test/flutter_test.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/data/balance.dart';
import 'package:tengri_taslari/data/bosses.dart';
import 'package:tengri_taslari/data/kuts.dart';

Round newRound({
  int seed = 1,
  int target = 300,
  RoundRules rules = RoundRules.normal,
  List<String> kuts = const [],
}) => Round(
  deckTiles: RunDeck.standard().tiles,
  target: target,
  rng: SeededRng(seed),
  levels: Balance.newHandLevels(),
  config: Balance.round,
  rules: rules,
  kuts: [for (final id in kuts) KutInstance(kutById(id))],
  tuning: Balance.tileEffects,
);

void main() {
  group('round setup', () {
    test('rack of 10, 4 hands, 3 discards, indicator removed from pile', () {
      final r = newRound();
      expect(r.rack, hasLength(10));
      expect(r.handsLeft, 4);
      expect(r.discardsLeft, 3);
      expect(r.drawPileCount, 106 - 1 - 10);
      expect(r.okey.indicator.isFakeOkey, isFalse);
      expect(r.phase, RoundPhase.playing);
    });

    test('same seed => same indicator and rack; other seed differs', () {
      expect(newRound(seed: 5).rack, newRound(seed: 5).rack);
      expect(
        newRound(seed: 5).okey.indicator,
        newRound(seed: 5).okey.indicator,
      );
      expect(newRound(seed: 5).rack, isNot(newRound(seed: 6).rack));
    });

    test('indicator is never a fake okey', () {
      for (var s = 0; s < 300; s++) {
        expect(newRound(seed: s).okey.indicator.isFakeOkey, isFalse);
      }
    });

    test('same seed + same moves => same result', () {
      int playOut(int seed) {
        final r = newRound(seed: seed, target: 100000);
        r.discard([0, 1]);
        r.play([0, 1, 2]);
        r.play([3, 4]);
        return r.score;
      }

      expect(playOut(11), playOut(11));
    });
  });

  group('playing', () {
    test('invalid selections are rejected', () {
      final r = newRound();
      ActionError err(void Function() f) {
        try {
          f();
        } on RoundActionException catch (e) {
          return e.error;
        }
        fail('no exception');
      }

      expect(err(() => r.play([])), ActionError.noSelection);
      expect(
        err(() => r.play([0, 1, 2, 3, 4, 5, 6])),
        ActionError.tooManyTiles,
      );
      expect(err(() => r.play([1, 1])), ActionError.invalidIndex);
      expect(err(() => r.play([10])), ActionError.invalidIndex);
      expect(r.handsLeft, 4, reason: 'failed actions change nothing');
    });

    test('play scores, uses a hand and refills the rack', () {
      final r = newRound(target: 100000);
      final played = [r.rack[0], r.rack[1]];
      final out = r.play([0, 1]);
      expect(r.handsLeft, 3);
      expect(r.rack, hasLength(10));
      expect(r.score, out.scoring.score);
      expect(out.drawn, hasLength(2));
      expect(r.discardPile, containsAll(played));
      expect(r.rack.any(played.contains), isFalse);
    });

    test('reaching the target wins immediately', () {
      final r = newRound(target: 1);
      r.play([0]);
      expect(r.phase, RoundPhase.won);
      expect(() => r.play([0]), throwsA(isA<RoundActionException>()));
    });

    test('running out of hands below target loses', () {
      final r = newRound(target: 1 << 30);
      for (var i = 0; i < 4; i++) {
        r.play([0]);
      }
      expect(r.phase, RoundPhase.lost);
    });

    test('preview / simulate do not change state', () {
      final r = newRound();
      final rack = r.rack;
      final p = r.preview([0, 1, 2])!;
      final s = r.simulate([0, 1, 2]);
      expect(p.chips, Balance.newHandLevels().chipsOf(p.type));
      expect(s.handType, p.type);
      expect(r.rack, rack);
      expect(r.score, 0);
      expect(r.handsLeft, 4);
    });
  });

  group('discarding', () {
    test('discard replaces tiles and uses a discard', () {
      final r = newRound();
      final out = r.discard([0, 1, 2]);
      expect(out.discarded, hasLength(3));
      expect(out.drawn, hasLength(3));
      expect(r.rack, hasLength(10));
      expect(r.discardsLeft, 2);
      expect(r.score, 0);
    });

    test('no discards left => error', () {
      final r = newRound();
      for (var i = 0; i < 3; i++) {
        r.discard([0]);
      }
      expect(() => r.discard([0]), throwsA(isA<RoundActionException>()));
    });

    test('Yada Taşı accumulates +1 mult per discarded tile', () {
      final r = newRound(kuts: ['yada_tasi'], target: 1 << 30);
      r.discard([0, 1, 2]);
      expect(r.kuts.single.state['mult'], 3);
      final base = Balance.newHandLevels().multOf(r.simulate([0]).handType);
      expect(r.simulate([0]).mult, base + 3);
    });
  });

  group('rack management', () {
    test('moveTile reorders', () {
      final r = newRound();
      final tile = r.rack[7];
      r.moveTile(7, 0);
      expect(r.rack.first, tile);
      expect(r.rack, hasLength(10));
    });

    test('sort by number puts wild okeys last and is ordered', () {
      final r = newRound(seed: 3);
      r.sortRackByNumber();
      final ranks = [
        for (final t in r.rack.where((t) => !r.okey.isWild(t)))
          (r.okey.faceOf(t).number == 1 ? 14 : r.okey.faceOf(t).number),
      ];
      expect(ranks, [...ranks]..sort());
    });

    test('sort by color groups colors', () {
      final r = newRound(seed: 4);
      r.sortRackByColor();
      final colors = [
        for (final t in r.rack.where((t) => !r.okey.isWild(t)))
          r.okey.faceOf(t).color.index,
      ];
      expect(colors, [...colors]..sort());
    });
  });

  group('boss rules in rounds', () {
    RoundRules boss(String id) => bossesById[id]!.rules;

    test('Albastı: no discards', () {
      expect(newRound(rules: boss('albasti')).discardsLeft, 0);
    });

    test('Demirkıyak: max 4 tiles per play (discard still 6)', () {
      final r = newRound(rules: boss('demirkiyak'));
      expect(
        () => r.play([0, 1, 2, 3, 4]),
        throwsA(isA<RoundActionException>()),
      );
      r.discard([0, 1, 2, 3, 4]);
    });

    test('Al Karısı: a tile is stolen after each hand', () {
      final r = newRound(rules: boss('al_karisi'), target: 1 << 30);
      final out = r.play([0]);
      expect(out.stolen, isNotNull);
      expect(r.rack, hasLength(9));
    });

    test('Yel Ana: rack shuffled and hidden after a hand; reveal works', () {
      final r = newRound(rules: boss('yel_ana'), target: 1 << 30);
      r.play([0]);
      expect(
        List.generate(r.rack.length, r.isFaceDown).every((x) => x),
        isTrue,
      );
      r.reveal(2);
      expect(r.isFaceDown(2), isFalse);
    });

    test('Tepegöz: a counted color is active', () {
      expect(newRound(rules: boss('tepegoz')).countedColor, isNotNull);
      expect(newRound().countedColor, isNull);
    });

    test('Abası: rack is 2 tiles smaller and refills to that size', () {
      final r = newRound(rules: boss('abasi'), target: 1 << 30);
      expect(r.rack, hasLength(8));
      r.play([0, 1]);
      expect(r.rack, hasLength(8));
    });

    test('Kara Kuş: okey not wild', () {
      expect(newRound(rules: boss('kara_kus')).okey.okeyIsWild, isFalse);
    });

    test('Erlik\'in Pazarlığı Kut removes one hand', () {
      expect(newRound(kuts: ['erlik_pazarligi']).handsLeft, 3);
    });
  });

  group('AutoPlayer', () {
    test('plays a full round to the end deterministically', () {
      RoundPhase run(int seed) {
        final r = newRound(seed: seed);
        const bot = AutoPlayer();
        while (r.phase == RoundPhase.playing) {
          final a = bot.decide(r);
          a.isDiscard ? r.discard(a.indices) : r.play(a.indices);
        }
        return r.phase;
      }

      final results = [for (var s = 0; s < 10; s++) run(s)];
      expect(results, [for (var s = 0; s < 10; s++) run(s)]);
      expect(results.where((p) => p == RoundPhase.won), isNotEmpty);
    });
  });
}
