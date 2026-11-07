import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/core/core.dart';

import '../../l10n_ext.dart';
import '../../theme/palette.dart';
import '../../widgets/effects.dart';
import '../../widgets/kut_row.dart';
import '../../widgets/tile_view.dart';
import '../event_labels.dart';
import '../../game/game_controller.dart';
import '../../game/game_state.dart';

/// Center of the table: indicator/okey, hand preview and scoring playback.
class PlayArea extends ConsumerWidget {
  const PlayArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    final playback = state.playback;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: playback != null ? controller.skipPlayback : null,
      child: Column(
        children: [
          _OkeyInfoRow(round: state.round!),
          const SizedBox(height: 8),
          if (playback != null)
            _HandHeader(
              title: context.l10n.handName(playback.hand.type),
              chips: playback.chips,
              mult: playback.mult,
              chipsTrigger: playback.step,
            )
          else
            _PreviewHeader(controller: controller, state: state),
          Expanded(
            child: Center(
              child: playback != null
                  ? _PlayedTiles(playback: playback, okey: state.round!.okey)
                  : Text(
                      context.l10n.playAreaHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Palette.textMuted,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OkeyInfoRow extends StatelessWidget {
  const _OkeyInfoRow({required this.round});
  final Round round;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final okey = round.okey;
    final okeyTile = Tile(
      id: -1,
      color: okey.okeyFace.color,
      number: okey.okeyFace.number,
    );
    const labelStyle = TextStyle(fontSize: 10, color: Palette.textMuted);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Column(
            children: [
              Text(l10n.indicator, style: labelStyle),
              const SizedBox(height: 2),
              TileView(tile: okey.indicator, okey: null, width: 30),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward, size: 16, color: Palette.goldDark),
          ),
          Column(
            children: [
              Text(
                okey.okeyIsWild ? l10n.okey : l10n.okeyNotWild,
                style: labelStyle,
              ),
              const SizedBox(height: 2),
              TileView(tile: okeyTile, okey: okey, width: 30),
            ],
          ),
          if (round.countedColor != null) ...[
            const SizedBox(width: 16),
            Column(
              children: [
                Text(l10n.countedColorHint, style: labelStyle),
                const SizedBox(height: 2),
                TileView(
                  tile: Tile(id: -2, color: round.countedColor!, number: 1),
                  okey: null,
                  width: 30,
                ),
              ],
            ),
          ],
          const Spacer(),
          const ConsumableBar(cardWidth: 38),
        ],
      ),
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader({required this.controller, required this.state});
  final GameController controller;
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (state.selectedIds.length > state.round!.maxTilesPerPlay) {
      return _HandHeader(
        title: l10n.tooManyTiles(state.round!.maxTilesPerPlay),
        chips: 0,
        mult: 0,
      );
    }
    final preview = controller.preview();
    if (preview == null) {
      return _HandHeader(
        title: l10n.selectTiles,
        chips: 0,
        mult: 0,
        muted: true,
      );
    }
    final level = state.round!.levels.levelOf(preview.type);
    final name = l10n.handName(preview.type);
    return _HandHeader(
      key: const Key('hand-preview'),
      title: level > 1 ? l10n.handWithLevel(name, level) : name,
      chips: preview.chips.toDouble(),
      mult: preview.mult.toDouble(),
    );
  }
}

/// "Seri-4 — [45] × [4]"
class _HandHeader extends StatelessWidget {
  const _HandHeader({
    super.key,
    required this.title,
    required this.chips,
    required this.mult,
    this.chipsTrigger,
    this.muted = false,
  });

  final String title;
  final double chips;
  final double mult;
  final int? chipsTrigger;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: muted ? Palette.textMuted : Palette.cream,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _NumberBox(
              label: l10n.chips,
              value: chips,
              color: Palette.chipsBlue,
              alignRight: true,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '×',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Palette.cream,
                ),
              ),
            ),
            _NumberBox(label: l10n.mult, value: mult, color: Palette.multRed),
          ],
        ),
      ],
    );
  }
}

class _NumberBox extends StatelessWidget {
  const _NumberBox({
    required this.label,
    required this.value,
    required this.color,
    this.alignRight = false,
  });

  final String label;
  final double value;
  final Color color;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: alignRight
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            style: const TextStyle(fontSize: 9, color: Colors.white70),
          ),
          Bounce(
            trigger: value == 0 ? null : value,
            scale: 1.15,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: CountUpText(
                value: value,
                duration: const Duration(milliseconds: 220),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Played tiles during scoring: counted tiles bright, others dimmed.
class _PlayedTiles extends StatelessWidget {
  const _PlayedTiles({required this.playback, required this.okey});
  final Playback playback;
  final OkeyInfo okey;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final counted = playback.countedIndices;
    final event = playback.current;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reserved space for the hand total so nothing jumps.
        SizedBox(
          height: 48,
          child: playback.finished
              ? _HandTotal(score: playback.handScore)
              : null,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < playback.played.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _FlyIn(
                  index: i,
                  child: _ScoringTile(
                    tile: playback.played[i],
                    okey: okey,
                    dimmed: !counted.contains(i),
                    trigger:
                        event != null &&
                            event.source == ScoreSourceKind.playedTile &&
                            event.sourceIndex == i
                        ? playback.step
                        : null,
                    label:
                        event != null &&
                            event.source == ScoreSourceKind.playedTile &&
                            event.sourceIndex == i
                        ? labelForEvent(l10n, event)
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _HandTotal extends StatelessWidget {
  const _HandTotal({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.elasticOut,
      builder: (context, s, child) => Transform.scale(scale: s, child: child),
      child: Text(
        context.l10n.handScoreTotal(score),
        key: const Key('hand-total'),
        style: const TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          color: Palette.gold,
          shadows: [Shadow(color: Colors.black, blurRadius: 8)],
        ),
      ),
    );
  }
}

class _ScoringTile extends StatelessWidget {
  const _ScoringTile({
    required this.tile,
    required this.okey,
    required this.dimmed,
    required this.trigger,
    required this.label,
  });

  final Tile tile;
  final OkeyInfo okey;
  final bool dimmed;
  final int? trigger;
  final (String, Color)? label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Bounce(
          trigger: trigger,
          child: TileView(tile: tile, okey: okey, width: 44, dimmed: dimmed),
        ),
        if (label != null && trigger != null)
          Positioned(
            top: -14,
            child: FloatingLabel(
              trigger: trigger!,
              text: label!.$1,
              color: label!.$2,
            ),
          ),
      ],
    );
  }
}

/// Tiles fly up from the rack into the play area, staggered.
class _FlyIn extends StatelessWidget {
  const _FlyIn({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + 60 * index),
      curve: Curves.easeOutCubic,
      builder: (context, t, c) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, 160 * (1 - t)), child: c),
      ),
      child: child,
    );
  }
}
