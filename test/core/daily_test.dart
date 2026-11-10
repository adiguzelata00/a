import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/data/balance.dart';
import 'package:tengri_taslari/data/run_setup.dart';

DailyChallenge day(int y, int m, int d) =>
    DailyChallenge.forDay(DateTime(y, m, d, 15, 30), defaultCatalog);

RunState start(DailyChallenge c) => c.start(
  rules: defaultRunRules,
  catalog: defaultCatalog,
  bonusMoney: Balance.dailyBonusMoney,
);

void main() {
  test('same day => same challenge, regardless of the time of day', () {
    final a = DailyChallenge.forDay(
      DateTime(2026, 11, 8, 0, 1),
      defaultCatalog,
    );
    final b = DailyChallenge.forDay(
      DateTime(2026, 11, 8, 23, 59),
      defaultCatalog,
    );
    expect(a.date, '2026-11-08');
    expect(a.seedCode, 'GUN20261108');
    expect(b.seedCode, a.seedCode);
    expect(b.kutId, a.kutId);
    expect(b.bonus, a.bonus);
  });

  test('days differ and every bonus shows up over a season', () {
    final days = [
      for (var i = 0; i < 90; i++)
        DailyChallenge.forDay(
          DateTime(2026, 1, 1).add(Duration(days: i)),
          defaultCatalog,
        ),
    ];
    expect(days.map((d) => d.seedCode).toSet(), hasLength(90));
    expect(days.map((d) => d.bonus).toSet(), DailyBonus.values.toSet());
    expect(days.map((d) => d.kutId).toSet().length, greaterThan(10));
    for (final d in days) {
      expect(defaultCatalog.kut(d.kutId).rarity, isNot(Rarity.legendary));
    }
  });

  test('two players get exactly the same run', () {
    final a = start(day(2026, 11, 8));
    final b = start(day(2026, 11, 8));
    expect(a.boss.id, b.boss.id);
    a.startRound();
    b.startRound();
    expect(a.round!.rack, b.round!.rack);
    expect(a.isDaily, isTrue);
    expect(a.dailyDate, '2026-11-08');
  });

  test('the run starts with the Kut and the bonus of the day', () {
    for (var i = 0; i < 40; i++) {
      final c = DailyChallenge.forDay(
        DateTime(2026, 3, 1).add(Duration(days: i)),
        defaultCatalog,
      );
      final r = start(c);
      expect(r.kuts.single.id, c.kutId);
      switch (c.bonus) {
        case DailyBonus.money:
          expect(
            r.money,
            defaultRunRules.startingMoney + Balance.dailyBonusMoney,
          );
        case DailyBonus.extraHand:
          expect(r.roundConfig.hands, defaultRunRules.round.hands + 1);
        case DailyBonus.extraDiscard:
          expect(r.roundConfig.discards, defaultRunRules.round.discards + 1);
        case DailyBonus.extraHandSize:
          expect(r.roundConfig.handSize, defaultRunRules.round.handSize + 1);
        case DailyBonus.discount:
          expect(r.vouchers, contains(VoucherEffect.discount));
        case DailyBonus.interestCap:
          expect(r.interestCap, greaterThan(defaultRunRules.interestCap));
      }
      if (r.floorVoucher != null) {
        expect(r.vouchers, isNot(contains(r.floorVoucher!.effect)));
      }
    }
  });

  test('daily runs keep their date through a save', () {
    final r = start(day(2026, 11, 8));
    final back = RunState.fromJson(
      jsonDecode(jsonEncode(r.toJson())) as Map<String, dynamic>,
      rules: r.rules,
      catalog: r.catalog,
    );
    expect(back.dailyDate, '2026-11-08');
    expect(back.kuts.single.id, r.kuts.single.id);
  });

  test('profile records daily results and keeps them', () {
    final p = Profile();
    final r = start(day(2026, 11, 8));
    expect(p.recordDaily(r), isTrue);
    expect(p.recordDaily(r), isFalse, reason: 'unchanged');
    expect(p.dailyResults['2026-11-08']!.finished, isFalse);
    r.phase = RunPhase.lost;
    expect(p.recordDaily(r), isTrue);
    final back = Profile.fromJson(
      jsonDecode(jsonEncode(p.toJson())) as Map<String, dynamic>,
    );
    expect(back.dailyResults['2026-11-08']!.finished, isTrue);
    expect(back.dailyResults['2026-11-08']!.floor, 1);
    expect(Profile().recordDaily(newRun('NORMAL')), isFalse);
  });
}
