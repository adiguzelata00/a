import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/data/balance.dart';

import '../../art/symbols.dart';
import '../../l10n_ext.dart';
import '../../theme/palette.dart';
import '../../widgets/effects.dart';
import '../event_labels.dart';
import '../table_controller.dart';

/// Row of Kut slots. Cards wobble and show a label when they trigger.
class KutRow extends ConsumerWidget {
  const KutRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(
      tableControllerProvider.select((s) {
        final p = s.playback;
        final e = p?.current;
        return (
          kuts: p?.kuts ?? s.round.kuts,
          event: e != null && e.source == ScoreSourceKind.kut ? e : null,
          step: p?.step ?? -1,
        );
      }),
    );
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        const slots = Balance.kutSlots;
        const gap = 6.0;
        final w = ((constraints.maxWidth - 24 - gap * (slots - 1)) / slots)
            .clamp(40.0, 76.0);
        return SizedBox(
          height: w * 1.3 + 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < slots; i++) ...[
                if (i > 0) const SizedBox(width: gap),
                if (i < data.kuts.length)
                  _KutCard(
                    kut: data.kuts[i],
                    index: i,
                    width: w,
                    trigger: data.event?.sourceIndex == i ? data.step : null,
                    label: data.event?.sourceIndex == i
                        ? labelForEvent(l10n, data.event!)
                        : null,
                  )
                else
                  _EmptySlot(width: w, label: l10n.emptyKutSlot),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _KutCard extends StatelessWidget {
  const _KutCard({
    required this.kut,
    required this.index,
    required this.width,
    required this.trigger,
    required this.label,
  });

  final KutInstance kut;
  final int index;
  final double width;
  final int? trigger;
  final (String, Color)? label;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rarityColor = switch (kut.definition.rarity) {
      Rarity.common => Palette.gold,
      Rarity.rare => Palette.sealSky,
      Rarity.legendary => Palette.sealPurple,
    };
    final card = Container(
      width: width,
      height: width * 1.3,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Palette.nightLighter, Palette.night],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Palette.gold, width: 1.5),
        boxShadow: [
          BoxShadow(color: rarityColor.withValues(alpha: 0.35), blurRadius: 6),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _EmblemPainter(fnv1a32(kut.id), Palette.gold),
              child: const SizedBox.expand(),
            ),
          ),
          Text(
            l10n.kutName(kut.id),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: width < 60 ? 8.5 : 10,
              height: 1.1,
              color: Palette.cream,
            ),
          ),
        ],
      ),
    );

    return Tooltip(
      message: '${l10n.kutName(kut.id)}\n${l10n.kutDescription(kut.id)}',
      triggerMode: TooltipTriggerMode.longPress,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Wobble(trigger: trigger, child: card),
          if (label != null && trigger != null)
            Positioned(
              top: -10,
              child: FloatingLabel(
                trigger: trigger!,
                text: label!.$1,
                color: label!.$2,
              ),
            ),
        ],
      ),
    );
  }
}

class _EmblemPainter extends CustomPainter {
  _EmblemPainter(this.variant, this.color);
  final int variant;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide * 0.8;
    drawKutEmblem(
      canvas,
      variant,
      Rect.fromCenter(
        center: size.center(Offset.zero),
        width: side,
        height: side,
      ),
      color,
    );
  }

  @override
  bool shouldRepaint(_EmblemPainter old) =>
      old.variant != variant || old.color != color;
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.width, required this.label});
  final double width;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: width * 1.3,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Palette.goldDark.withValues(alpha: 0.5)),
      color: Colors.black.withValues(alpha: 0.15),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 10, color: Palette.textMuted),
    ),
  );
}
