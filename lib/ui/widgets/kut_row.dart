import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/core/core.dart';

import '../game/game_controller.dart';
import '../l10n_ext.dart';
import '../table/event_labels.dart';
import '../theme/palette.dart';
import 'cards.dart';
import 'effects.dart';
import 'item_sheet.dart';

/// Row of Kut slots. Drag a card onto another to reorder (order = trigger
/// order); tap for details (and selling outside rounds). While scoring,
/// cards wobble and show what they added.
class KutRow extends ConsumerWidget {
  const KutRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(
      gameControllerProvider.select((s) {
        final p = s.playback;
        final e = p?.current;
        return (
          kuts: s.kuts,
          slots: s.run?.kutSlots ?? 5,
          busy: s.isAnimating,
          event: e != null && e.source == ScoreSourceKind.kut ? e : null,
          step: p?.step ?? -1,
          version: s.version,
        );
      }),
    );
    final l10n = context.l10n;
    final controller = ref.read(gameControllerProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final slots = data.slots;
        const gap = 6.0;
        final w = ((constraints.maxWidth - 24 - gap * (slots - 1)) / slots)
            .clamp(40.0, 72.0);
        return SizedBox(
          height: w * 1.3 + 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < slots; i++) ...[
                if (i > 0) const SizedBox(width: gap),
                if (i < data.kuts.length)
                  _KutSlot(
                    key: ValueKey('kut-${data.kuts[i].id}'),
                    kut: data.kuts[i],
                    index: i,
                    width: w,
                    draggable: !data.busy,
                    trigger: data.event?.sourceIndex == i ? data.step : null,
                    label: data.event?.sourceIndex == i
                        ? labelForEvent(l10n, data.event!)
                        : null,
                    onMove: controller.moveKut,
                    onTap: () => showKutSheet(context, ref, i),
                  )
                else
                  EmptySlot(width: w, label: l10n.emptyKutSlot),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _KutSlot extends StatelessWidget {
  const _KutSlot({
    super.key,
    required this.kut,
    required this.index,
    required this.width,
    required this.draggable,
    required this.trigger,
    required this.label,
    required this.onMove,
    required this.onTap,
  });

  final KutInstance kut;
  final int index;
  final double width;
  final bool draggable;
  final int? trigger;
  final (String, Color)? label;
  final void Function(int from, int to) onMove;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final card = KutCard(
      definition: kut.definition,
      instance: kut,
      width: width,
    );
    final body = Stack(
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
    );
    final tappable = GestureDetector(
      key: Key('kut-card-$index'),
      onTap: onTap,
      child: body,
    );
    if (!draggable) return tappable;
    return DragTarget<int>(
      onWillAcceptWithDetails: (d) => d.data != index,
      onAcceptWithDetails: (d) => onMove(d.data, index),
      builder: (context, candidates, _) => Draggable<int>(
        data: index,
        feedback: Material(
          color: Colors.transparent,
          child: Transform.scale(scale: 1.1, child: card),
        ),
        childWhenDragging: Opacity(opacity: 0.3, child: card),
        child: AnimatedScale(
          scale: candidates.isNotEmpty ? 1.08 : 1,
          duration: const Duration(milliseconds: 120),
          child: tappable,
        ),
      ),
    );
  }
}

/// Row of consumable slots (Destan / Tılsım). Tap for details, use, sell.
class ConsumableBar extends ConsumerWidget {
  const ConsumableBar({super.key, this.cardWidth = 48});

  final double cardWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(
      gameControllerProvider.select(
        (s) => (
          items: List.of(s.run?.consumables ?? const <ConsumableInstance>[]),
          slots: s.run?.consumableSlots ?? 2,
          version: s.version,
        ),
      ),
    );
    final l10n = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < data.slots; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          if (i < data.items.length)
            GestureDetector(
              key: Key('consumable-$i'),
              onTap: () => showConsumableSheet(context, ref, i),
              child: ConsumableCard(item: data.items[i], width: cardWidth),
            )
          else
            EmptySlot(width: cardWidth, label: l10n.emptyKutSlot),
        ],
      ],
    );
  }
}

/// Section label used above rows.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      fontSize: 10,
      letterSpacing: 1.2,
      color: Palette.textMuted,
      fontWeight: FontWeight.w700,
    ),
  );
}
