import 'package:flutter_test/flutter_test.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/data/balance.dart';
import 'package:tengri_taslari/data/kuts.dart';

import '../helpers.dart';

const engine = ScoringEngine();

ScoringResult score(
  List<Tile> played, {
  List<Tile> held = const [],
  List<String> kuts = const [],
  List<KutInstance>? kutInstances,
  OkeyInfo? okey,
  RoundRules rules = RoundRules.normal,
  int handNumber = 0,
  int discardsLeft = 0,
  bool boss = false,
  TileColor? countedColor,
  SeededRng? rng,
}) {
  final lv = levels();
  final hand = evaluator.evaluate(played, okey ?? neutralOkey, lv)!;
  return engine.score(
    ScoringInput(
      hand: hand,
      heldTiles: held,
      levels: lv,
      kuts: kutInstances ?? [for (final id in kuts) KutInstance(kutById(id))],
      rules: rules,
      tuning: Balance.tileEffects,
      handNumber: handNumber,
      discardsLeft: discardsLeft,
      isBossRound: boss,
      countedColor: countedColor,
      rng: rng,
    ),
  );
}

void main() {
  group('base scoring', () {
    test('Seri-3 4-5-6: (25 + 15) × 3', () {
      final r = score(ts('R4 R5 R6'));
      expect(r.score, 120);
      expect(r.events.first.kind, ScoreEventKind.handBase);
      expect(
        r.events.where((e) => e.kind == ScoreEventKind.chips),
        hasLength(3),
      );
    });

    test('tiles outside the meld add nothing', () {
      expect(score(ts('R4 R5 R6 K13')).score, 120);
    });

    test('final score floors chips × mult', () {
      final r = score(ts('R5 R5'), held: [t('K9', enh: Enhancement.iron)]);
      // 20 × (2 × 1.5) = 60
      expect(r.score, 60);
    });
  });

  group('tile enhancements & seals', () {
    test('Kemik: +30 chips', () {
      expect(score([t('R13', enh: Enhancement.bone)]).score, (5 + 13 + 30) * 1);
    });

    test('Kristal: ×2 mult', () {
      expect(score([t('R5', enh: Enhancement.crystal), t('R5')]).score, 20 * 4);
    });

    test('Kristal never breaks in preview (rng == null)', () {
      for (var i = 0; i < 50; i++) {
        expect(score([t('R5', enh: Enhancement.crystal)]).brokenTiles, isEmpty);
      }
    });

    test('Kristal breaks with ~25% chance and is deterministic per seed', () {
      var broken = 0;
      for (var seed = 0; seed < 400; seed++) {
        final a = score([
          t('R5', enh: Enhancement.crystal),
        ], rng: SeededRng(seed));
        final b = score([
          t('R5', enh: Enhancement.crystal),
        ], rng: SeededRng(seed));
        expect(a.brokenTiles.length, b.brokenTiles.length);
        broken += a.brokenTiles.length;
      }
      expect(broken, inInclusiveRange(60, 140));
    });

    test('Demir held: ×1.5 per iron tile each hand', () {
      final r = score(
        ts('R5 R5'),
        held: [
          t('K9', enh: Enhancement.iron),
          t('K10', enh: Enhancement.iron),
        ],
      );
      expect(r.mult, 2 * 1.5 * 1.5);
      expect(r.score, 90);
    });

    test('Demir does nothing when played', () {
      expect(score([t('R5', enh: Enhancement.iron), t('R5')]).score, 40);
    });

    test('Kızıl Tamga: counted tile triggers twice', () {
      final r = score([t('R5', seal: Seal.crimson), t('R5')]);
      expect(r.chips, 10 + 5 + 5 + 5);
      expect(
        r.events.where((e) => e.kind == ScoreEventKind.retrigger),
        hasLength(1),
      );
    });

    test('Kızıl Tamga on a held iron tile retriggers the held effect', () {
      final r = score(
        ts('R5 R5'),
        held: [t('K9', enh: Enhancement.iron, seal: Seal.crimson)],
      );
      expect(r.mult, 2 * 1.5 * 1.5);
    });

    test('Altın Tamga: +3 money when counted', () {
      final r = score([t('R5', seal: Seal.gold), t('R5')]);
      expect(r.moneyEarned, 3);
    });
  });

  group('Kut trigger order', () {
    test('per-tile Kut fires right after each matching tile', () {
      // Group R7 Y7 B7 + Umay Ana (+4 per red) => 51 × 7
      final r = score(ts('R7 Y7 B7'), kuts: ['umay_ana']);
      expect(r.score, 51 * 7);
      final seq = [
        for (final e in r.events)
          '${e.source.name}:${e.sourceIndex}:${e.kind.name}',
      ];
      expect(seq, [
        'hand:-1:handBase',
        'playedTile:0:chips',
        'kut:0:mult', // Umay Ana right after R7
        'playedTile:1:chips',
        'playedTile:2:chips',
      ]);
    });

    test('full order: tiles → held → hand Kuts', () {
      final r = score(
        ts('R4 R5 R6'),
        held: [t('K9', enh: Enhancement.iron)],
        kuts: ['bozkurt', 'umay_ana'],
      );
      final sources = [for (final e in r.events) e.source];
      final firstHeld = sources.indexOf(ScoreSourceKind.heldTile);
      final lastPlayed = sources.lastIndexOf(ScoreSourceKind.playedTile);
      final bozkurt = r.events.indexWhere(
        (e) => e.source == ScoreSourceKind.kut && e.sourceIndex == 0,
      );
      expect(lastPlayed, lessThan(firstHeld));
      expect(firstHeld, lessThan(bozkurt));
      // chips 40; mult: 3 +4+4+4 (umay) = 15, ×1.5 (iron) = 22.5, +10 = 32.5
      expect(r.mult, 32.5);
      expect(r.score, (40 * 32.5).floor());
    });

    test('Kut order matters: +mult before ×mult beats the reverse', () {
      final group = ts('R7 Y7 B7'); // chips 51, mult 3
      final addThenMul = score(group, kuts: ['kopuz', 'asena']);
      final mulThenAdd = score(group, kuts: ['asena', 'kopuz']);
      expect(addThenMul.score, 51 * ((3 + Balance.kopuzMult) * 2));
      expect(mulThenAdd.score, 51 * (3 * 2 + Balance.kopuzMult));
      expect(addThenMul.score, greaterThan(mulThenAdd.score));
    });

    test('Kam Davulu retriggers only the first counted tile', () {
      final r = score(ts('R5 R5'), kuts: ['kam_davulu']);
      expect(r.chips, 10 + 5 + 5 + 5);
    });

    test('Kam Davulu stacks with Kızıl Tamga', () {
      final r = score(
        [t('R5', seal: Seal.crimson), t('R5')],
        kuts: ['kam_davulu'],
      );
      expect(r.chips, 10 + 5 * 3 + 5);
    });

    test('retrigger repeats per-tile Kut effects', () {
      final r = score(
        [t('R5', seal: Seal.crimson), t('R5')],
        kuts: ['umay_ana'],
      );
      expect(r.mult, 2 + 4 * 3);
    });
  });

  group('individual Kuts', () {
    test('Ay Ata / Gün Ana / Kara Dağ react to their color', () {
      expect(score(ts('B5 B5'), kuts: ['ay_ata']).chips, 20 + 60);
      expect(score(ts('Y5 Y5'), kuts: ['gun_ana']).mult, 2 + 6);
      final k = score(ts('K5 K5'), kuts: ['kara_dag']);
      expect(k.chips, 20 + 40);
      expect(k.mult, 2 + 2);
    });

    test('color Kuts see Gök Taşı as every color', () {
      final r = score(
        [t('Y4'), t('K5', enh: Enhancement.skyStone), t('Y6')],
        kuts: ['umay_ana'],
      );
      expect(r.mult, 3 + 4);
    });

    test('Bozkurt only for hands with a run, Asena only with a group', () {
      expect(score(ts('R4 R5 R6'), kuts: ['bozkurt']).mult, 13);
      expect(score(ts('R5 R5'), kuts: ['bozkurt']).mult, 2);
      expect(score(ts('R7 Y7 B7'), kuts: ['asena']).mult, 6);
      expect(
        score(ts('R5 Y5 B5 K8 K9 K10'), kuts: ['bozkurt', 'asena']).mult,
        (9 + 10) * 2,
      );
    });

    test('Tulpar: +15 chips per remaining discard', () {
      expect(
        score(ts('R5 R5'), kuts: ['tulpar'], discardsLeft: 2).chips,
        20 + 30,
      );
    });

    test('Kopuz: only for 3 or fewer played tiles', () {
      expect(
        score(ts('R5 R5 K9'), kuts: ['kopuz']).mult,
        2 + Balance.kopuzMult,
      );
      expect(score(ts('R5 R5 K9 K11'), kuts: ['kopuz']).mult, 2);
    });

    test('Ülgen\'in Işığı: ×3 only when a wild okey is in the meld', () {
      final okey = okeyIs('Y5');
      expect(
        score(
          [t('R4'), t('Y5'), t('R6')],
          okey: okey,
          kuts: ['ulgen_isigi'],
        ).mult,
        9,
      );
      expect(score(ts('R4 R5 R6'), okey: okey, kuts: ['ulgen_isigi']).mult, 3);
    });

    test('Oğuz Kağan: Seri-5 and above', () {
      expect(
        score(ts('R2 R3 R4 R5 R6'), kuts: ['oguz_kagan']).mult,
        5 + Balance.oguzKaganMult,
      );
      expect(score(ts('R2 R3 R4 R5'), kuts: ['oguz_kagan']).mult, 4);
    });

    test('Nazar Boncuğu: only in boss rounds', () {
      expect(score(ts('R5 R5'), kuts: ['nazar_boncugu'], boss: true).mult, 17);
      expect(score(ts('R5 R5'), kuts: ['nazar_boncugu']).mult, 2);
    });

    test('Ergenekon: held iron tiles also give +20 chips', () {
      final r = score(
        ts('R5 R5'),
        held: [
          t('K9', enh: Enhancement.iron),
          t('K3'),
        ],
        kuts: ['ergenekon'],
      );
      expect(r.chips, 20 + Balance.ergenekonChips);
    });

    test(
      'Gök Börü grows before scoring; state is only returned, not mutated',
      () {
        final kut = KutInstance(kutById('gok_boru'));
        final r = score(ts('R7 Y7 B7 K7'), kutInstances: [kut]);
        expect(r.mult, 7 * 2);
        expect(r.updatedKuts.single.state['xMult'], 2);
        expect(kut.state['xMult'], 1, reason: 'input instance untouched');
        // Other hands do not grow it.
        expect(
          score(
            ts('R5 R5'),
            kutInstances: [kut],
          ).updatedKuts.single.state['xMult'],
          1,
        );
      },
    );

    test('Kayra Han: +0.25 × per Destan used', () {
      final kut = KutInstance(kutById('kayra_han'));
      expect(score(ts('R5 R5'), kutInstances: [kut]).mult, 2);
      kut.behavior.onDestanUsed(kut);
      kut.behavior.onDestanUsed(kut);
      expect(score(ts('R5 R5'), kutInstances: [kut]).mult, 2 * 1.5);
    });

    test('Erlik\'in Pazarlığı: ×3 and one hand less', () {
      expect(score(ts('R5 R5'), kuts: ['erlik_pazarligi']).mult, 6);
      expect(kutById('erlik_pazarligi').behavior.handsDelta, -1);
    });
  });

  group('boss rules in scoring', () {
    test('Tepegöz: only the active color is counted', () {
      final r = score(ts('R7 Y7 B7'), countedColor: TileColor.red);
      expect(r.chips, 30 + 7);
      expect(
        r.events.where((e) => e.kind == ScoreEventKind.tileDebuffed),
        hasLength(2),
      );
    });

    test('Tepegöz: Gök Taşı still counts', () {
      final r = score([
        t('R7'),
        t('Y7', enh: Enhancement.skyStone),
        t('B7'),
      ], countedColor: TileColor.red);
      expect(r.chips, 30 + 14);
    });

    test('Erlik Han: first hand scores 0, later hands normal', () {
      const rules = RoundRules(firstHandScoresZero: true);
      expect(score(ts('R4 R5 R6'), rules: rules, handNumber: 0).score, 0);
      expect(score(ts('R4 R5 R6'), rules: rules, handNumber: 1).score, 120);
    });

    test('Şahmeran: runs give half, other hands unaffected', () {
      const rules = RoundRules(runScoreFactor: 0.5);
      expect(score(ts('R4 R5 R6'), rules: rules).score, 60);
      expect(score(ts('R5 R5'), rules: rules).score, 40);
    });
  });
}
