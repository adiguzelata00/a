import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/core/core.dart';

import '../game/game_controller.dart';
import '../l10n_ext.dart';
import '../theme/palette.dart';
import 'cards.dart';

/// Bottom sheet with a Kut's details; offers selling outside rounds.
Future<void> showKutSheet(BuildContext context, WidgetRef ref, int index) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Palette.night,
    showDragHandle: true,
    builder: (context) => Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(gameControllerProvider);
        final run = state.run;
        if (run == null || index >= run.kuts.length) {
          return const SizedBox(height: 120);
        }
        final kut = run.kuts[index];
        final l10n = context.l10n;
        final canSell = run.phase != RunPhase.round && !state.isAnimating;
        return _SheetBody(
          art: KutCard(definition: kut.definition, instance: kut, width: 72),
          title: l10n.kutName(kut.id),
          subtitle: l10n.rarityName(kut.definition.rarity),
          subtitleColor: rarityColor(kut.definition.rarity),
          description: l10n.kutDescription(kut.id),
          actions: [
            if (canSell)
              OutlinedButton(
                key: const Key('sell-kut'),
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(gameControllerProvider.notifier).sellKut(index);
                },
                child: Text(l10n.sell(kut.definition.sellValue)),
              ),
          ],
        );
      },
    ),
  );
}

/// Bottom sheet with a consumable's details; use and sell buttons.
Future<void> showConsumableSheet(
  BuildContext context,
  WidgetRef ref,
  int index,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Palette.night,
    showDragHandle: true,
    builder: (context) => Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(gameControllerProvider);
        final run = state.run;
        if (run == null || index >= run.consumables.length) {
          return const SizedBox(height: 120);
        }
        final item = run.consumables[index];
        final l10n = context.l10n;
        final controller = ref.read(gameControllerProvider.notifier);
        final canUse =
            !state.isAnimating &&
            run.canUse(index, rackIndices: state.selectedIndices);
        final def = item.definition;
        return _SheetBody(
          art: ConsumableCard(item: item, width: 72),
          title: l10n.consumableName(item),
          description: l10n.consumableDescription(item),
          hint: def.needsTiles ? l10n.tilsimTargetHint(def.maxTargets) : null,
          actions: [
            OutlinedButton(
              key: const Key('sell-consumable'),
              onPressed: state.isAnimating
                  ? null
                  : () {
                      Navigator.pop(context);
                      controller.sellConsumable(index);
                    },
              child: Text(l10n.sell(def.sellValue)),
            ),
            FilledButton(
              key: const Key('use-consumable'),
              onPressed: canUse
                  ? () {
                      Navigator.pop(context);
                      controller.useConsumable(index);
                    }
                  : null,
              child: Text(l10n.use),
            ),
          ],
        );
      },
    ),
  );
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({
    required this.art,
    required this.title,
    required this.description,
    required this.actions,
    this.subtitle,
    this.subtitleColor,
    this.hint,
  });

  final Widget art;
  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final String description;
  final String? hint;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                art,
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Palette.gold,
                        ),
                      ),
                      if (subtitle != null)
                        Text(subtitle!, style: TextStyle(color: subtitleColor)),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 15, height: 1.35),
                      ),
                      if (hint != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          hint!,
                          style: const TextStyle(color: Palette.textMuted),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (final a in actions) ...[const SizedBox(width: 8), a],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
