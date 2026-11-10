import 'package:flutter_test/flutter_test.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/data/balance.dart';
import 'package:tengri_taslari/data/kuts.dart';
import 'package:tengri_taslari/data/run_setup.dart';

RunState run({
  String seed = 'TESTRUN1',
  int Function(int floor, int round)? target,
  int? money,
  int? floors,
}) => RunState(
  seedCode: seed,
  rules: defaultRunRules.copyWith(
    targetFor: target,
    startingMoney: money,
    floorCount: floors,
  ),
  catalog: defaultCatalog,
);

/// Plays single tiles until the round ends.
void playOut(RunState r) {
  while (r.round!.phase == RoundPhase.playing) {
    r.play([0]);
  }
}

/// Wins the current round instantly (target 1) and collects the cashout.
void winRound(RunState r) {
  r.startRound();
  r.play([0]);
  r.finishRound();
  r.collectCashout();
}

void main() {
  group('run setup', () {
    test('starts on floor 1, small trial, with boss/tags/voucher', () {
      final r = run();
      expect(r.phase, RunPhase.roundSelect);
      expect(r.floor, 1);
      expect(r.roundInFloor, 0);
      expect(r.money, 4);
      expect(r.boss.minFloor, lessThanOrEqualTo(1));
      expect(r.floorTags, hasLength(2));
      expect(r.floorVoucher, isNotNull);
      expect(r.slots.first, RoundSlotStatus.current);
      expect(r.currentTarget, Balance.targetFor(1, 0));
      expect(r.world, 0);
    });

    test('same seed => same boss, tags, voucher and first rack', () {
      final a = run(seed: 'SAME');
      final b = run(seed: 'SAME');
      expect(a.boss.id, b.boss.id);
      expect(a.floorTags, b.floorTags);
      expect(a.floorVoucher?.id, b.floorVoucher?.id);
      a.startRound();
      b.startRound();
      expect(a.round!.rack, b.round!.rack);
    });
  });

  group('round select', () {
    test('skipping small trial grants its tag and moves to big', () {
      final r = run(seed: 'SKIPPER');
      final tag = r.floorTags[0];
      r.skipRound();
      expect(r.slots[0], RoundSlotStatus.skipped);
      expect(r.roundInFloor, 1);
      if (tag == SkipTag.money) {
        expect(r.money, 4 + defaultRunRules.skipMoney);
        expect(r.phase, RunPhase.roundSelect);
      } else {
        expect(r.phase, RunPhase.packOpen);
        r.skipPack();
        expect(r.phase, RunPhase.roundSelect);
      }
    });

    test('the boss can not be skipped', () {
      final r = run();
      r.skipRound();
      if (r.phase == RunPhase.packOpen) r.skipPack();
      r.skipRound();
      if (r.phase == RunPhase.packOpen) r.skipPack();
      expect(r.isBossRound, isTrue);
      expect(() => r.skipRound(), throwsA(isA<RunActionException>()));
    });

    test('boss round uses the boss rules', () {
      final r = run(target: (f, s) => 1);
      winRound(r);
      r.leaveShop();
      winRound(r);
      r.leaveShop();
      r.startRound();
      expect(r.round!.rules, same(r.boss.rules));
      expect(r.round!.isBossRound, isTrue);
    });
  });

  group('cashout', () {
    test('reward + hands left + interest', () {
      final r = run(target: (f, s) => 1, money: 12);
      r.startRound();
      r.play([0]);
      r.finishRound();
      expect(r.phase, RunPhase.cashout);
      final lines = {for (final l in r.lastSummary!.lines) l.kind: l.amount};
      expect(lines[CashoutKind.roundReward], 3);
      expect(lines[CashoutKind.handsLeft], 3);
      expect(lines[CashoutKind.interest], 2); // 12 Akçe -> +2
      r.collectCashout();
      expect(r.money, 12 + 3 + 3 + 2);
      expect(r.phase, RunPhase.shop);
      expect(r.roundInFloor, 1);
    });

    test('interest is capped', () {
      final r = run(target: (f, s) => 1, money: 100);
      r.startRound();
      r.play([0]);
      r.finishRound();
      final lines = {for (final l in r.lastSummary!.lines) l.kind: l.amount};
      expect(lines[CashoutKind.interest], defaultRunRules.interestCap);
    });

    test('Dede Korkut pays per hand left, gold tiles pay when held', () {
      final r = run(target: (f, s) => 1);
      r.addKut(kutById('dede_korkut'));
      for (final t in r.deck.tiles) {
        r.deck.replace(t.copyWith(enhancement: Enhancement.gold));
      }
      r.startRound();
      r.play([0]);
      r.finishRound();
      final lines = r.lastSummary!.lines;
      expect(lines.firstWhere((l) => l.kind == CashoutKind.kut).amount, 3 * 2);
      expect(
        lines.firstWhere((l) => l.kind == CashoutKind.goldTiles).amount,
        greaterThan(0),
      );
    });

    test('losing ends the run', () {
      final r = run(target: (f, s) => 1 << 30);
      r.startRound();
      playOut(r);
      r.finishRound();
      expect(r.phase, RunPhase.lost);
    });

    test('Zümrüdüanka saves a lost round once if 25% was reached', () {
      // Measure the score of a fixed sequence of plays first.
      final probe = run(seed: 'PHOENIX', target: (f, s) => 1 << 30);
      probe.startRound();
      playOut(probe);
      final score = probe.round!.score;

      final r = run(seed: 'PHOENIX', target: (f, s) => score * 2);
      r.addKut(kutById('zumruduanka'));
      r.startRound();
      playOut(r);
      expect(r.round!.phase, RoundPhase.lost);
      r.finishRound();
      expect(r.phase, RunPhase.cashout);
      expect(r.lastSummary!.savedBy, 'zumruduanka');
      expect(r.kuts, isEmpty, reason: 'it vanishes after saving');
    });

    test('beating the floor-8 boss wins; endless continues on floor 9', () {
      final r = run(target: (f, s) => 1, floors: 1);
      winRound(r);
      r.leaveShop();
      winRound(r);
      r.leaveShop();
      r.startRound();
      r.play([0]);
      r.finishRound();
      r.collectCashout();
      expect(r.phase, RunPhase.won);
      r.continueEndless();
      expect(r.endless, isTrue);
      expect(r.floor, 2);
      expect(r.phase, RunPhase.shop);
    });
  });

  group('shop', () {
    RunState inShop({int money = 100}) {
      final r = run(target: (f, s) => 1, money: money);
      winRound(r);
      return r;
    }

    test('has item, pack and voucher offers', () {
      final r = inShop();
      expect(r.shop!.items, hasLength(2));
      expect(r.shop!.packs, hasLength(2));
      expect(r.shop!.items.every((o) => o != null), isTrue);
    });

    test('buying an item costs money and sells it out', () {
      final r = inShop();
      final offer = r.shop!.items[0]!;
      final before = r.money;
      r.buyItem(0);
      expect(r.money, before - offer.price);
      expect(r.shop!.items[0], isNull);
      expect(() => r.buyItem(0), throwsA(isA<RunActionException>()));
      if (offer is KutOffer) expect(r.kuts.single.id, offer.kut.id);
      if (offer is ConsumableOffer) expect(r.consumables, hasLength(1));
    });

    test('not enough money', () {
      final r = run(target: (f, s) => 1, money: 0);
      winRound(r); // earns ~6
      r.money = 0;
      expect(() => r.buyItem(0), throwsA(isA<RunActionException>()));
      expect(() => r.reroll(), throwsA(isA<RunActionException>()));
    });

    test('reroll cost grows; Kervan makes the first one free', () {
      final r = inShop();
      expect(r.rerollCost, 5);
      r.reroll();
      expect(r.rerollCost, 6);

      final k = inShop();
      k.addKut(kutById('kervan'));
      expect(k.rerollCost, 0);
      final before = k.money;
      k.reroll();
      expect(k.money, before);
      expect(k.rerollCost, 5);
    });

    test('Kut slots are limited', () {
      final r = inShop();
      for (final k in allKuts.take(5)) {
        r.addKut(k);
      }
      expect(r.hasKutSlot, isFalse);
      expect(() => r.addKut(allKuts[6]), throwsA(isA<RunActionException>()));
    });

    test('selling a Kut returns half its price', () {
      final r = inShop(money: 0);
      r.addKut(kutById('asena'));
      final before = r.money;
      r.sellKut(0);
      expect(r.money, before + kutById('asena').sellValue);
      expect(r.kuts, isEmpty);
    });

    test('vouchers: extra hand applies to the next round', () {
      final r = inShop();
      // Force the voucher under test onto this floor.
      r.floorVoucher = defaultCatalog.vouchers.firstWhere(
        (v) => v.effect == VoucherEffect.extraHand,
      );
      r.buyVoucher();
      expect(r.floorVoucher, isNull);
      r.leaveShop();
      r.startRound();
      expect(r.round!.handsLeft, 5);
    });

    test('discount voucher lowers prices', () {
      final r = inShop();
      expect(r.priceOf(8), 8);
      r.vouchers.add(VoucherEffect.discount);
      expect(r.priceOf(8), 6);
      expect(r.priceOf(1), 1);
    });

    test('packs open, offer choices and return to the shop', () {
      final r = inShop();
      r.buyPack(0);
      expect(r.phase, RunPhase.packOpen);
      expect(r.pack!.choices, hasLength(3));
      final idx = [for (var i = 0; i < 3; i++) i].firstWhere(r.canChoose);
      r.choosePackOption(idx);
      expect(r.phase, RunPhase.shop);
      expect(r.shop!.packs[0], isNull);
    });

    test('same seed + same actions => same shop', () {
      List<String> offers(RunState r) => [
        for (final o in r.shop!.items)
          switch (o) {
            KutOffer(:final kut) => kut.id,
            ConsumableOffer(:final item) => item.id,
            _ => '-',
          },
      ];
      expect(offers(inShop()), offers(inShop()));
    });
  });

  group('consumables', () {
    RunState inRound() {
      final r = run(target: (f, s) => 1 << 30);
      r.startRound();
      return r;
    }

    ConsumableDefinition def(String id) =>
        defaultCatalog.consumables.firstWhere((c) => c.id == id);

    test('Destan levels up its hand and feeds Kayra Han', () {
      final r = run();
      r.addKut(kutById('kayra_han'));
      r.consumables.add(ConsumableInstance(def('manas_destani')));
      r.useConsumable(0);
      expect(r.levels.levelOf(HandType.run4), 2);
      expect(r.kuts.single.state['xMult'], 1.25);
      expect(r.consumables, isEmpty);
    });

    test('Demirci Tılsımı turns selected tiles into iron (rack + deck)', () {
      final r = inRound();
      r.consumables.add(ConsumableInstance(def('demirci_tilsimi')));
      expect(r.canUse(0), isFalse, reason: 'needs targets');
      expect(r.canUse(0, rackIndices: [0, 1, 2]), isFalse, reason: 'max 2');
      final ids = [r.round!.rack[0].id, r.round!.rack[1].id];
      r.useConsumable(0, rackIndices: [0, 1]);
      for (final id in ids) {
        expect(
          r.round!.rack.firstWhere((t) => t.id == id).enhancement,
          Enhancement.iron,
        );
        expect(r.deck.byId(id)!.enhancement, Enhancement.iron);
      }
    });

    test('Tılsım needing tiles can not be used outside a round', () {
      final r = run();
      r.consumables.add(ConsumableInstance(def('demirci_tilsimi')));
      expect(r.canUse(0, rackIndices: [0]), isFalse);
    });

    test('Renk Tılsımı paints with its own color', () {
      final r = inRound();
      r.consumables.add(
        ConsumableInstance(def('renk_tilsimi'), color: TileColor.blue),
      );
      final id = r.round!.rack[0].id;
      final wasFake = r.round!.rack[0].isFakeOkey;
      r.useConsumable(0, rackIndices: [0]);
      if (!wasFake) expect(r.deck.byId(id)!.color, TileColor.blue);
    });

    test('Yakma Tılsımı destroys tiles for good', () {
      final r = inRound();
      r.consumables.add(ConsumableInstance(def('yakma_tilsimi')));
      final id = r.round!.rack[0].id;
      r.useConsumable(0, rackIndices: [0]);
      expect(r.deck.byId(id), isNull);
      expect(r.deck.length, 105);
      expect(r.round!.rack.any((t) => t.id == id), isFalse);
      expect(r.round!.rack, hasLength(10), reason: 'rack refilled');
    });

    test('Ayna Tılsımı adds a copy to the deck', () {
      final r = inRound();
      r.consumables.add(ConsumableInstance(def('ayna_tilsimi')));
      r.useConsumable(0, rackIndices: [0]);
      expect(r.deck.length, 107);
    });

    test('Yükseltme Tılsımı: +1, 13 wraps to 1', () {
      final r = inRound();
      final t = r.round!.rack[0];
      r.consumables.add(ConsumableInstance(def('yukseltme_tilsimi')));
      r.useConsumable(0, rackIndices: [0]);
      if (!t.isFakeOkey) {
        expect(r.deck.byId(t.id)!.number, t.number == 13 ? 1 : t.number + 1);
      }
    });

    test('Tamga Tılsımı stamps a seal', () {
      final r = inRound();
      final id = r.round!.rack[0].id;
      r.consumables.add(ConsumableInstance(def('tamga_tilsimi')));
      r.useConsumable(0, rackIndices: [0]);
      expect(r.deck.byId(id)!.seal, isNot(Seal.none));
    });

    test('Kam Tılsımı creates a Kut (needs a slot)', () {
      final r = run();
      r.consumables.add(ConsumableInstance(def('kam_tilsimi')));
      r.useConsumable(0);
      expect(r.kuts, hasLength(1));
    });

    test('Mor Tamga: discarding creates a Tılsım', () {
      final r = run(target: (f, s) => 1 << 30);
      for (final t in r.deck.tiles) {
        r.deck.replace(t.copyWith(seal: Seal.purple));
      }
      r.startRound();
      r.discard([0]);
      expect(r.consumables, hasLength(1));
      expect(r.consumables.single.definition.kind, ConsumableKind.tilsim);
    });

    test('Gök Tamga: held tiles create the Destan of the last hand', () {
      final r = run(target: (f, s) => 1);
      for (final t in r.deck.tiles) {
        r.deck.replace(t.copyWith(seal: Seal.sky));
      }
      r.startRound();
      final out = r.play([0]);
      r.finishRound();
      expect(r.consumables, hasLength(2), reason: 'limited by slots');
      expect(r.consumables.first.definition.hand, out.hand.type);
    });
  });

  group('stats', () {
    test('hands, best hand and Kut triggers are recorded', () {
      final r = run(target: (f, s) => 1 << 30);
      r.addKut(kutById('kopuz'));
      r.startRound();
      r.play([0]);
      r.play([0, 1]);
      expect(r.stats.handsPlayed, 2);
      expect(r.stats.bestHand, greaterThan(0));
      expect(r.stats.kutTriggers['kopuz'], 2);
      expect(r.stats.mostUsedKut, 'kopuz');
    });
  });

  group('smoke', () {
    /// Greedy bot that also shops, opens packs and uses items.
    RunPhase botRun(String seed) {
      final r = run(seed: seed);
      const bot = AutoPlayer();
      var guard = 0;
      while (r.phase != RunPhase.won &&
          r.phase != RunPhase.lost &&
          guard++ < 400) {
        switch (r.phase) {
          case RunPhase.roundSelect:
            r.startRound();
          case RunPhase.round:
            final round = r.round!;
            if (round.phase != RoundPhase.playing) {
              r.finishRound();
              break;
            }
            for (var i = r.consumables.length - 1; i >= 0; i--) {
              if (r.canUse(i, rackIndices: const [0])) {
                r.useConsumable(i, rackIndices: const [0]);
              } else if (r.canUse(i)) {
                r.useConsumable(i);
              }
            }
            if (round.phase != RoundPhase.playing) break;
            final a = bot.decide(round);
            a.isDiscard ? r.discard(a.indices) : r.play(a.indices);
          case RunPhase.cashout:
            r.collectCashout();
          case RunPhase.shop:
            for (var i = 0; i < r.shop!.items.length; i++) {
              final o = r.shop!.items[i];
              if (o != null && o.price <= r.money) {
                try {
                  r.buyItem(i);
                } on RunActionException {
                  // no slot
                }
              }
            }
            if (r.shop!.packs[0] != null &&
                r.shop!.packs[0]!.price <= r.money) {
              r.buyPack(0);
              break;
            }
            r.leaveShop();
          case RunPhase.packOpen:
            final i = [for (var i = 0; i < r.pack!.choices.length; i++) i]
                .where(r.canChoose)
                .firstOrNull;
            i == null ? r.skipPack() : r.choosePackOption(i);
          case RunPhase.won:
          case RunPhase.lost:
            break;
        }
      }
      expect(guard, lessThan(400), reason: 'run must terminate');
      return r.phase;
    }

    test('bot plays whole runs without errors', () {
      final results = [
        for (final s in ['A1', 'B2', 'C3', 'D4']) botRun(s),
      ];
      expect(
        results.every((p) => p == RunPhase.won || p == RunPhase.lost),
        isTrue,
      );
    });
  });
}
