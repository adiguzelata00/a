// ignore_for_file: avoid_print

// Simulates whole runs with the RunBot and prints where runs end.
//
//   dart run bin/run_sim.dart [--runs 200] [--seed-prefix SIM]
//
// Developer tool for balancing (texts are inline).

import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/core/sim/run_bot.dart';
import 'package:tengri_taslari/data/balance.dart';
import 'package:tengri_taslari/data/run_setup.dart';

void main(List<String> args) {
  var runs = 200;
  var prefix = 'SIM';
  for (var i = 0; i < args.length - 1; i++) {
    if (args[i] == '--runs') runs = int.parse(args[i + 1]);
    if (args[i] == '--seed-prefix') prefix = args[i + 1];
  }
  const bot = RunBot();
  final endFloor = <int, int>{};
  final kutCounts = <String, int>{};
  final deathSlot = <String, int>{};
  final kutFloorSum = <String, int>{};
  var floorSum = 0;
  var wins = 0;
  var bestSum = 0;
  final sw = Stopwatch()..start();
  for (var i = 0; i < runs; i++) {
    final r = bot.play(newRun('$prefix$i'));
    if (r.won) wins++;
    final f = r.won ? Balance.floorCount + 1 : r.floor;
    endFloor.update(f, (v) => v + 1, ifAbsent: () => 1);
    floorSum += f;
    for (final k in r.kuts) {
      kutCounts.update(k, (v) => v + 1, ifAbsent: () => 1);
      kutFloorSum.update(k, (v) => v + f, ifAbsent: () => f);
    }
    bestSum += r.bestHand;
    if (!r.won) {
      deathSlot.update(
        '${r.floor}.${r.roundInFloor}',
        (v) => v + 1,
        ifAbsent: () => 1,
      );
    }
  }
  print('Koşu: $runs  süre: ${sw.elapsed.inSeconds}s');
  print('Kazanma: %${(100 * wins / runs).toStringAsFixed(1)}');
  print('Ortalama en iyi el: ${bestSum ~/ runs}');
  print('Bittiği kat (9 = kazandı):');
  var cumulative = runs;
  for (var f = 1; f <= Balance.floorCount + 1; f++) {
    final n = endFloor[f] ?? 0;
    print(
      '  ${f.toString().padLeft(2)}: ${n.toString().padLeft(4)}  '
      '(bu kata ulaşan %${(100 * cumulative / runs).round()})',
    );
    cumulative -= n;
  }
  final slots = deathSlot.keys.toList()..sort();
  print(
    'Ölüm (kat.tur, 0=küçük 2=boss): '
    '${slots.map((k) => '$k:${deathSlot[k]}').join('  ')}',
  );
  print('Ortalama bitiş katı: ${(floorSum / runs).toStringAsFixed(2)}');
  print('Kut sahibi koşuların ortalama bitiş katı (adet):');
  final avg = {
    for (final k in kutCounts.keys) k: kutFloorSum[k]! / kutCounts[k]!,
  };
  final sorted = avg.keys.toList()..sort((a, b) => avg[b]!.compareTo(avg[a]!));
  for (final k in sorted) {
    print(
      '  ${k.padRight(16)} ${avg[k]!.toStringAsFixed(2)}  (${kutCounts[k]})',
    );
  }
}
