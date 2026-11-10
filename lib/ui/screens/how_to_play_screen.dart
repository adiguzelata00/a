import 'package:flutter/material.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/data/balance.dart';

import '../l10n_ext.dart';
import '../theme/palette.dart';
import '../widgets/tile_view.dart';

/// "Nasıl Oynanır": rules overview with drawn example tiles. Hand values
/// come straight from `Balance`, so the guide follows balance changes.
class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const HowToPlayScreen());

  /// Example tiles per hand type: (color, number).
  static const Map<HandType, List<(TileColor, int)>> examples = {
    HandType.single: [(TileColor.black, 13)],
    HandType.pair: [(TileColor.red, 7), (TileColor.red, 7)],
    HandType.twoPair: [
      (TileColor.blue, 4),
      (TileColor.blue, 4),
      (TileColor.yellow, 9),
      (TileColor.yellow, 9),
    ],
    HandType.run3: [(TileColor.red, 5), (TileColor.red, 6), (TileColor.red, 7)],
    HandType.group3: [
      (TileColor.red, 8),
      (TileColor.yellow, 8),
      (TileColor.blue, 8),
    ],
    HandType.threePairs: [
      (TileColor.red, 2),
      (TileColor.red, 2),
      (TileColor.yellow, 5),
      (TileColor.yellow, 5),
      (TileColor.black, 11),
      (TileColor.black, 11),
    ],
    HandType.run4: [
      (TileColor.blue, 9),
      (TileColor.blue, 10),
      (TileColor.blue, 11),
      (TileColor.blue, 12),
    ],
    HandType.rainbowRun: [
      (TileColor.red, 3),
      (TileColor.yellow, 4),
      (TileColor.blue, 5),
      (TileColor.black, 6),
    ],
    HandType.run5: [
      (TileColor.yellow, 1),
      (TileColor.yellow, 2),
      (TileColor.yellow, 3),
      (TileColor.yellow, 4),
      (TileColor.yellow, 5),
    ],
    HandType.group4: [
      (TileColor.red, 10),
      (TileColor.yellow, 10),
      (TileColor.blue, 10),
      (TileColor.black, 10),
    ],
    HandType.run6: [
      (TileColor.black, 8),
      (TileColor.black, 9),
      (TileColor.black, 10),
      (TileColor.black, 11),
      (TileColor.black, 12),
      (TileColor.black, 13),
    ],
    HandType.skyMeld: [
      (TileColor.red, 7),
      (TileColor.yellow, 7),
      (TileColor.blue, 7),
      (TileColor.black, 3),
      (TileColor.black, 4),
      (TileColor.black, 5),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final indicator = const Tile(id: -1, color: TileColor.blue, number: 7);
    final okey = OkeyInfo(indicator: indicator);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.howToTitle),
        backgroundColor: Palette.night,
        foregroundColor: Palette.gold,
      ),
      body: ListView(
        key: const Key('how-to-play'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _Section(l10n.howToGoalTitle, l10n.howToGoalBody),
          _Section(l10n.howToTurnTitle, l10n.howToTurnBody),
          _Section(
            l10n.howToOkeyTitle,
            l10n.howToOkeyBody,
            extra: Row(
              children: [
                _Labeled(
                  l10n.indicator,
                  TileView(tile: indicator, okey: null, width: 34),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, color: Palette.goldDark),
                ),
                _Labeled(
                  l10n.okey,
                  TileView(
                    tile: const Tile(id: -2, color: TileColor.blue, number: 8),
                    okey: okey,
                    width: 34,
                  ),
                ),
                const SizedBox(width: 24),
                _Labeled(
                  '',
                  TileView(
                    tile: const Tile.fakeOkey(id: -3),
                    okey: okey,
                    width: 34,
                  ),
                ),
              ],
            ),
          ),
          _Section(l10n.howToScoreTitle, l10n.howToScoreBody),
          _Section(
            l10n.howToHandsTitle,
            l10n.howToHandsBody,
            extra: Column(
              children: [
                for (final type in HandType.values) _HandRow(type: type),
              ],
            ),
          ),
          _Section(l10n.howToKutTitle, l10n.howToKutBody),
          _Section(l10n.howToShopTitle, l10n.howToShopBody),
          _Section(l10n.howToBossTitle, l10n.howToBossBody),
          _Section(l10n.howToTipsTitle, l10n.howToTipsBody),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.body, {this.extra});

  final String title;
  final String body;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Palette.gold,
            ),
          ),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(fontSize: 15, height: 1.45)),
          if (extra != null) ...[const SizedBox(height: 12), extra!],
        ],
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled(this.label, this.child);
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: Palette.textMuted),
      ),
      const SizedBox(height: 2),
      child,
    ],
  );
}

class _HandRow extends StatelessWidget {
  const _HandRow({required this.type});
  final HandType type;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stats = Balance.hands[type]!;
    final tiles = HowToPlayScreen.examples[type]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Palette.nightLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Palette.goldDark.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.handName(type),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              _Pill('${stats.chips}', Palette.chipsBlue),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('×', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
              _Pill('${stats.mult}', Palette.multRed),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            children: [
              for (var i = 0; i < tiles.length; i++)
                TileView(
                  tile: Tile(
                    id: -100 - i,
                    color: tiles[i].$1,
                    number: tiles[i].$2,
                  ),
                  okey: null,
                  width: 30,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
    ),
  );
}
