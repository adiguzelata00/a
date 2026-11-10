import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/core/sim/run_bot.dart';
import 'package:tengri_taslari/data/kuts.dart';
import 'package:tengri_taslari/data/run_setup.dart';

RunState fresh(String seed, {int? money, int Function(int, int)? target}) =>
    RunState(
      seedCode: seed,
      rules: defaultRunRules.copyWith(startingMoney: money, targetFor: target),
      catalog: defaultCatalog,
    );

/// JSON round trip through a string, like the real save file.
RunState roundTrip(RunState r) => RunState.fromJson(
  jsonDecode(jsonEncode(r.toJson())) as Map<String, dynamic>,
  rules: r.rules,
  catalog: r.catalog,
);

void main() {
  test('a fresh run survives a round trip', () {
    final r = fresh('SAVE1');
    final back = roundTrip(r);
    expect(back.seedCode, 'SAVE1');
    expect(back.phase, RunPhase.roundSelect);
    expect(back.boss.id, r.boss.id);
    expect(back.floorTags, r.floorTags);
    expect(back.deck.tiles, r.deck.tiles);
    expect(back.money, r.money);
    expect(jsonEncode(back.toJson()), jsonEncode(r.toJson()));
  });

  test('saving during a round is refused', () {
    final r = fresh('SAVE2')..startRound();
    expect(() => r.toJson(), throwsStateError);
  });

  test('shop, items, Kut state, vouchers and stats are kept', () {
    final r = fresh('SAVE3', money: 100, target: (f, s) => 1);
    r.addKut(kutById('gok_boru'));
    r.addKut(kutById('yada_tasi'));
    r.startRound();
    r.play([0]);
    r.finishRound();
    expect(
      jsonEncode(roundTrip(r).toJson()),
      jsonEncode(r.toJson()),
      reason: 'cashout',
    );
    r.collectCashout();
    r.consumables.add(
      ConsumableInstance(defaultCatalog.tilsims.first, color: TileColor.blue),
    );
    r.vouchers.add(VoucherEffect.discount);
    r.kuts.first.state['xMult'] = 3;
    r.buyItem(0);
    r.reroll();

    final back = roundTrip(r);
    expect(back.phase, RunPhase.shop);
    expect(back.kuts.map((k) => k.id), r.kuts.map((k) => k.id));
    expect(back.kuts.first.state['xMult'], 3);
    expect(back.consumables.map((c) => c.id), r.consumables.map((c) => c.id));
    expect(back.vouchers, r.vouchers);
    expect(back.shop!.rerolls, 1);
    expect(back.rerollCost, r.rerollCost);
    expect(back.stats.handsPlayed, 1);
    expect(back.lastSummary!.total, r.lastSummary!.total);
    expect(jsonEncode(back.toJson()), jsonEncode(r.toJson()));
  });

  test('an open pack survives a round trip', () {
    final r = fresh('SAVE4', money: 100, target: (f, s) => 1);
    r.startRound();
    r.play([0]);
    r.finishRound();
    r.collectCashout();
    r.buyPack(0);
    final back = roundTrip(r);
    expect(back.phase, RunPhase.packOpen);
    expect(back.pack!.choices, hasLength(r.pack!.choices.length));
    back.skipPack();
    expect(back.phase, RunPhase.shop);
  });

  test('a restored run continues exactly like the original', () {
    // Play two runs side by side; one is saved and reloaded at every
    // between-round step. They must end identically.
    const bot = RunBot();
    final a = fresh('SAVE5');
    var b = fresh('SAVE5');
    var guard = 0;
    while (a.phase != RunPhase.won &&
        a.phase != RunPhase.lost &&
        guard++ < 3000) {
      if (b.phase != RunPhase.round) b = roundTrip(b);
      expect(b.phase, a.phase);
      bot.step(a);
      bot.step(b);
    }
    expect(b.phase, a.phase);
    expect(b.floor, a.floor);
    expect(b.money, a.money);
    expect(b.stats.totalScore, a.stats.totalScore);
  });

  test('profile collects Kuts, bosses and records', () {
    final p = Profile();
    final r = fresh('PROF', target: (f, s) => 1);
    r.addKut(kutById('asena'));
    expect(p.observe(r), isTrue);
    expect(p.discoveredKuts, contains('asena'));
    expect(p.seenBosses, contains(r.boss.id));
    expect(p.observe(r), isFalse, reason: 'nothing new');
    final back = Profile.fromJson(
      jsonDecode(jsonEncode(p.toJson())) as Map<String, dynamic>,
    );
    expect(back.discoveredKuts, p.discoveredKuts);
    expect(back.highestFloor, 1);
  });
}
