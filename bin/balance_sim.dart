// Batch simulation with the greedy AutoPlayer to sanity-check targets.
//
//   dart run bin/balance_sim.dart [--rounds 40] [--kuts umay_ana,bozkurt]
//
// For floors 1..8 it plays the small/big/boss *target* of that floor with a
// fresh deck and base hand levels (no shop upgrades), so later floors are
// expected to fail without Kuts. Developer tool: texts are inline.

import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/data/balance.dart';
import 'package:tengri_taslari/data/kuts.dart';

void main(List<String> args) {
  var rounds = 40;
  var kutIds = <String>[];
  for (var i = 0; i < args.length - 1; i++) {
    if (args[i] == '--rounds') rounds = int.parse(args[i + 1]);
    if (args[i] == '--kuts') kutIds = args[i + 1].split(',');
  }
  const bot = AutoPlayer();
  print('Kut: ${kutIds.isEmpty ? '-' : kutIds.join(', ')}   tur sayısı: $rounds');
  print('Kat  Küçük        Büyük        Boss         ort. skor (Küçük)');
  for (var floor = 1; floor <= Balance.floorCount; floor++) {
    final cells = <String>[];
    var avg = 0.0;
    for (var slot = 0; slot < 3; slot++) {
      final target = Balance.targetFor(floor, slot);
      var wins = 0;
      var total = 0;
      for (var seed = 0; seed < rounds; seed++) {
        final round = Round(
          deckTiles: RunDeck.standard().tiles,
          target: target,
          rng: SeededRng(seed * 7919 + floor * 31 + slot),
          levels: Balance.newHandLevels(),
          config: Balance.round,
          kuts: [for (final id in kutIds) KutInstance(kutById(id))],
          tuning: Balance.tileEffects,
        );
        while (round.phase == RoundPhase.playing) {
          final a = bot.decide(round);
          a.isDiscard ? round.discard(a.indices) : round.play(a.indices);
        }
        if (round.phase == RoundPhase.won) wins++;
        total += round.score;
      }
      if (slot == 0) avg = total / rounds;
      cells.add('${target.toString().padLeft(5)} %${(100 * wins / rounds).round().toString().padLeft(3)}');
    }
    print('${floor.toString().padLeft(3)}  ${cells.join('   ')}   ${avg.round()}');
  }
}
