// Console simulation of a single round (Phase 1 developer tool).
//
//   dart run bin/simulate.dart                       # interactive, random seed
//   dart run bin/simulate.dart --seed TENGRI42
//   dart run bin/simulate.dart --seed TENGRI42 --auto
//   dart run bin/simulate.dart --kuts umay_ana,bozkurt --boss kara_kus
//   dart run bin/simulate.dart --target 450 --no-color
//
// NOTE: This is a developer tool, so its texts are written inline (Turkish).
// Player-facing texts of the real app live in ARB files.

import 'dart:io';

import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/data/balance.dart';
import 'package:tengri_taslari/data/bosses.dart';
import 'package:tengri_taslari/data/kuts.dart';

const _handNames = {
  HandType.single: 'Tek Taş',
  HandType.pair: 'Çift',
  HandType.twoPair: 'İki Çift',
  HandType.run3: 'Seri-3',
  HandType.group3: 'Grup-3',
  HandType.threePairs: 'Üç Çift',
  HandType.run4: 'Seri-4',
  HandType.rainbowRun: 'Alaca Seri',
  HandType.run5: 'Seri-5',
  HandType.group4: 'Grup-4',
  HandType.run6: 'Seri-6',
  HandType.skyMeld: 'Gök Per',
};

const _colorSymbols = {
  TileColor.red: '☼', // güneş
  TileColor.yellow: '★', // yıldız
  TileColor.blue: '☾', // ay
  TileColor.black: '▲', // dağ
};

const _ansi = {
  TileColor.red: '\x1B[31m',
  TileColor.yellow: '\x1B[33m',
  TileColor.blue: '\x1B[34m',
  TileColor.black: '\x1B[37m',
};

var _useColor = true;

void main(List<String> args) {
  final opts = _parseArgs(args);
  if (opts.containsKey('help')) {
    stdout.writeln(_usage);
    return;
  }
  _useColor = !opts.containsKey('no-color') && stdout.supportsAnsiEscapes;

  final seedCode = opts['seed'] ??
      generateSeedCode(SeededRng(DateTime.now().microsecondsSinceEpoch));
  final runRng = SeededRng.fromCode(seedCode);
  final target = int.tryParse(opts['target'] ?? '') ?? Balance.targetFor(1, 0);
  final kuts = [
    for (final id in (opts['kuts'] ?? '').split(',').where((s) => s.isNotEmpty))
      KutInstance(kutById(id.trim())),
  ];
  final boss = opts['boss'] == null ? null : bossesById[opts['boss']];
  if (opts['boss'] != null && boss == null) {
    stderr.writeln('Bilinmeyen boss: ${opts['boss']}. '
        'Seçenekler: ${bossesById.keys.join(', ')}');
    exit(64);
  }

  final round = Round(
    deckTiles: RunDeck.standard().tiles,
    target: target,
    rng: runRng.fork('floor1-round0'),
    levels: Balance.newHandLevels(),
    config: Balance.round,
    rules: boss?.rules ?? RoundRules.normal,
    isBossRound: boss != null,
    kuts: kuts,
    tuning: Balance.tileEffects,
  );

  stdout.writeln('══ Tengri\'nin Taşları — Faz 1 konsol simülasyonu ══');
  stdout.writeln('Seed: $seedCode   Hedef: $target'
      '${boss != null ? '   Boss: ${boss.id}' : ''}'
      '${kuts.isNotEmpty ? '   Kut: ${kuts.map((k) => k.id).join(', ')}' : ''}');

  final auto = opts.containsKey('auto');
  const bot = AutoPlayer();
  while (round.phase == RoundPhase.playing) {
    _printState(round);
    if (auto) {
      final action = bot.decide(round);
      stdout.writeln('> ${action.isDiscard ? 'd' : 'p'} ${action.indices.join(' ')}');
      _apply(round, action.isDiscard ? 'd' : 'p', action.indices);
      continue;
    }
    stdout.write('> ');
    final line = stdin.readLineSync();
    if (line == null) break;
    final parts = line.trim().split(RegExp(r'\s+'));
    final cmd = parts.first.toLowerCase();
    final nums = [for (final p in parts.skip(1)) int.tryParse(p)];
    if (nums.contains(null)) {
      stdout.writeln('Sayı bekleniyordu.');
      continue;
    }
    final indices = nums.cast<int>();
    switch (cmd) {
      case 'q':
        return;
      case 'h' || '?':
        stdout.writeln(_commands);
      case 's':
        round.sortRackByNumber();
      case 'c':
        round.sortRackByColor();
      case 'r':
        for (final i in indices) {
          if (i >= 0 && i < round.rack.length) round.reveal(i);
        }
      case 'm' when indices.length == 2:
        _guard(() => round.moveTile(indices[0], indices[1]));
      case 'v':
        _guard(() {
          final p = round.preview(indices);
          if (p != null) {
            stdout.writeln('Önizleme: ${_handNames[p.type]} — ${p.chips} × ${p.mult}'
                '   (taşlar: ${p.hand.tileChips}, tahmini: ${round.simulate(indices).score})');
          }
        });
      case 'p' || 'd':
        _apply(round, cmd, indices);
      default:
        stdout.writeln(_commands);
    }
  }

  stdout.writeln();
  if (round.phase == RoundPhase.won) {
    stdout.writeln('★ TUR KAZANILDI! Skor ${round.score} / ${round.target} '
        '— kalan El: ${round.handsLeft}, en iyi el: ${round.bestHandScore}');
  } else {
    stdout.writeln('✖ Koşu bitti. Skor ${round.score} / ${round.target}');
  }
}

void _apply(Round round, String cmd, List<int> indices) {
  _guard(() {
    if (cmd == 'd') {
      final out = round.discard(indices);
      stdout.writeln('Atılan: ${out.discarded.map(_tile).join(' ')}  '
          'Çekilen: ${out.drawn.map(_tile).join(' ')}');
      return;
    }
    final out = round.play(indices);
    final s = out.scoring;
    stdout.writeln('\n${_handNames[s.handType]}  '
        '[${out.hand.counted.map(_counted).join(' ')}]');
    for (final e in s.events) {
      stdout.writeln('   ${_describe(e, round)}');
    }
    stdout.writeln('   = ${s.chips.toStringAsFixed(0)} × ${_num(s.mult)} '
        '→ +${s.score}   (toplam ${out.scoreAfter})');
    if (out.stolen != null) {
      stdout.writeln('   Al Karısı bir taş çaldı: ${_tile(out.stolen!)}');
    }
  });
}

String _describe(ScoreEvent e, Round round) {
  final src = switch (e.source) {
    ScoreSourceKind.hand => 'El',
    ScoreSourceKind.playedTile => 'Taş#${e.sourceIndex}',
    ScoreSourceKind.heldTile => 'Elde#${e.sourceIndex}',
    ScoreSourceKind.kut => 'Kut:${round.kuts[e.sourceIndex].id}',
    ScoreSourceKind.boss => 'Boss',
  };
  final what = switch (e.kind) {
    ScoreEventKind.handBase => 'taban ${_num(e.chipsAfter)} × ${_num(e.multAfter)}',
    ScoreEventKind.chips => '+${_num(e.amount)} Puan',
    ScoreEventKind.mult => '+${_num(e.amount)} Çarpan',
    ScoreEventKind.xMult => '×${_num(e.amount)} Çarpan',
    ScoreEventKind.money => '+${e.amount} Akçe',
    ScoreEventKind.retrigger => 'tekrar tetiklendi',
    ScoreEventKind.tileDebuffed => 'sayılmadı',
    ScoreEventKind.tileBroken => 'kırıldı!',
    ScoreEventKind.bossPenalty => 'skor ×${_num(e.amount)}',
  };
  return '$src: $what';
}

String _counted(CountedTile c) => c.usedAsWild
    ? '✦→${_face(TileFace(c.color, c.number))}'
    : _tile(c.tile);

String _num(num n) =>
    n == n.roundToDouble() ? n.toInt().toString() : n.toStringAsFixed(2);

void _guard(void Function() f) {
  try {
    f();
  } on RoundActionException catch (e) {
    stdout.writeln('Geçersiz hamle: ${e.error.name}');
  }
}

void _printState(Round round) {
  final okey = round.okey;
  stdout.writeln();
  stdout.writeln('Skor ${round.score}/${round.target}   '
      'El ${round.handsLeft}   Değiştir ${round.discardsLeft}   '
      'Deste ${round.drawPileCount}   '
      'Gösterge ${_tile(okey.indicator)} → Okey ${_face(okey.okeyFace)}'
      '${okey.okeyIsWild ? '' : ' (joker değil!)'}'
      '${round.countedColor != null ? '   Sayılan renk: ${_colorSymbols[round.countedColor]}' : ''}');
  final rack = round.rack;
  final cells = <String>[];
  final idx = <String>[];
  for (var i = 0; i < rack.length; i++) {
    final label = round.isFaceDown(i) ? '??' : _tile(rack[i], okey: okey);
    cells.add(label);
    idx.add(i.toString().padLeft(_visibleLength(label)));
  }
  stdout.writeln('İstaka: ${cells.join('  ')}');
  stdout.writeln('        ${idx.join('  ')}');
}

int _visibleLength(String s) => s.replaceAll(RegExp(r'\x1B\[[0-9;]*m'), '').runes.length;

String _face(TileFace f) => _paint(f.color, '${_colorSymbols[f.color]}${f.number}');

String _tile(Tile t, {OkeyInfo? okey}) {
  final extras = StringBuffer();
  if (t.enhancement != Enhancement.none) extras.write('+${t.enhancement.name}');
  if (t.seal != Seal.none) extras.write('*${t.seal.name}');
  if (t.isFakeOkey) {
    final base = okey == null ? 'SO' : 'SO(${_face(okey.okeyFace)})';
    return '$base$extras';
  }
  final star = okey != null && okey.isWild(t) ? '✦' : '';
  return '$star${_paint(t.color, '${_colorSymbols[t.color]}${t.number}')}$extras';
}

String _paint(TileColor c, String s) => _useColor ? '${_ansi[c]}$s\x1B[0m' : s;

Map<String, String?> _parseArgs(List<String> args) {
  final map = <String, String?>{};
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (!a.startsWith('--')) continue;
    final key = a.substring(2);
    if (i + 1 < args.length && !args[i + 1].startsWith('--')) {
      map[key] = args[++i];
    } else {
      map[key] = null;
    }
  }
  return map;
}

const _commands = '''
Komutlar (indeksler istakadaki sıradır):
  p 0 3 5   seçili taşları Oyna
  d 1 2     seçili taşları Değiştir
  v 0 3 5   önizleme (el türü, puan × çarpan)
  m 7 0     7. taşı 0. konuma taşı
  s / c     sayıya / renge göre diz
  r 2       kapalı taşı aç (Yel Ana)
  q         çıkış''';

const _usage = '''
Kullanım: dart run bin/simulate.dart [--seed KOD] [--target N] [--auto]
                                     [--kuts id1,id2] [--boss id] [--no-color]
$_commands''';
