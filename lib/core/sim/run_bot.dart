import '../hands/hand_type.dart';
import '../round/round.dart';
import '../run/items.dart';
import '../run/run_state.dart';
import '../run/shop.dart';
import 'auto_player.dart';

/// Result of a simulated run.
class RunBotResult {
  const RunBotResult({
    required this.won,
    required this.floor,
    required this.roundInFloor,
    required this.kuts,
    required this.bestHand,
  });

  final bool won;

  /// Floor on which the run ended (or 8 when won).
  final int floor;
  final int roundInFloor;
  final List<String> kuts;
  final int bestHand;
}

/// Plays whole runs: greedy hands ([AutoPlayer]) plus a simple shopping
/// strategy. It is a deliberately average player, used to tune the target
/// curve, prices and Kut values (see `bin/run_sim.dart`).
class RunBot {
  const RunBot({this.player = const AutoPlayer(), this.moneyReserve = 0});

  final AutoPlayer player;

  /// Akçe the bot tries to keep (for interest).
  final int moneyReserve;

  RunBotResult play(RunState run, {int maxSteps = 5000}) {
    var steps = 0;
    while (run.phase != RunPhase.won &&
        run.phase != RunPhase.lost &&
        steps++ < maxSteps) {
      step(run);
    }
    return RunBotResult(
      won: run.phase == RunPhase.won,
      floor: run.floor,
      roundInFloor: run.roundInFloor,
      kuts: [for (final k in run.kuts) k.id],
      bestHand: run.stats.bestHand,
    );
  }

  /// Performs one decision (used by tests to interleave runs).
  void step(RunState run) {
    switch (run.phase) {
      case RunPhase.roundSelect:
        _useItems(run);
        run.startRound();
      case RunPhase.round:
        final round = run.round!;
        if (round.phase != RoundPhase.playing) {
          run.finishRound();
          return;
        }
        final a = player.decide(round);
        a.isDiscard ? run.discard(a.indices) : run.play(a.indices);
      case RunPhase.cashout:
        run.collectCashout();
      case RunPhase.shop:
        _shop(run);
      case RunPhase.packOpen:
        _choosePack(run);
      case RunPhase.won:
      case RunPhase.lost:
        break;
    }
  }

  HandType _favoriteHand(RunState run) =>
      run.stats.mostPlayedHand ?? HandType.pair;

  /// Destans and Kam Tılsımı are used right away; other Tılsıms are sold
  /// (the bot does not plan tile upgrades).
  void _useItems(RunState run) {
    for (var i = run.consumables.length - 1; i >= 0; i--) {
      final def = run.consumables[i].definition;
      if (def.kind == ConsumableKind.destan ||
          (def.effect == TilsimEffect.createKut && run.hasKutSlot)) {
        run.useConsumable(i);
      } else {
        run.sellConsumable(i);
      }
    }
  }

  bool _affordable(RunState run, int price) =>
      run.money - price >= moneyReserve;

  void _shop(RunState run) {
    final shop = run.shop!;
    // Kuts first, then Destans for the favourite hand.
    for (var i = 0; i < shop.items.length; i++) {
      final o = shop.items[i];
      if (o == null || !_affordable(run, o.price)) continue;
      switch (o) {
        case KutOffer():
          if (run.hasKutSlot) run.buyItem(i);
        case ConsumableOffer(:final item):
          final def = item.definition;
          if (def.kind == ConsumableKind.destan &&
              def.hand == _favoriteHand(run) &&
              run.hasConsumableSlot) {
            run.buyItem(i);
          }
        default:
          break;
      }
    }
    _useItems(run);
    final v = run.floorVoucher;
    if (v != null && _affordable(run, run.priceOf(v.price) + 5)) {
      run.buyVoucher();
    }
    for (var i = 0; i < shop.packs.length; i++) {
      final p = shop.packs[i];
      if (p == null || !_affordable(run, p.price)) continue;
      final useful = switch (p.kind) {
        PackKind.kut => run.hasKutSlot,
        PackKind.destan => true,
        _ => false,
      };
      if (useful) {
        run.buyPack(i);
        return; // continue after the pack is resolved
      }
    }
    if (run.hasKutSlot &&
        shop.rerolls == 0 &&
        _affordable(run, run.rerollCost + 8)) {
      run.reroll();
      return;
    }
    run.leaveShop();
  }

  void _choosePack(RunState run) {
    final choices = run.pack!.choices;
    final fav = _favoriteHand(run);
    int? pick;
    for (var i = 0; i < choices.length; i++) {
      if (!run.canChoose(i)) continue;
      final c = choices[i];
      if (c is ConsumableChoice && c.item.definition.hand == fav) {
        pick = i;
        break;
      }
      pick ??= i;
    }
    pick == null ? run.skipPack() : run.choosePackOption(pick);
  }
}
