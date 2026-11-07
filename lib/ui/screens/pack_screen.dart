import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/core/core.dart';

import '../game/game_controller.dart';
import '../l10n_ext.dart';
import '../theme/palette.dart';
import '../widgets/cards.dart';
import '../widgets/kut_row.dart';
import '../widgets/tile_view.dart';
import '../widgets/world_background.dart';
import 'run_header.dart';

/// An opened pack ("Kese"): choose one option or skip.
class PackScreen extends ConsumerWidget {
  const PackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final run = state.run!;
    final pack = run.pack;
    final l10n = context.l10n;
    final controller = ref.read(gameControllerProvider.notifier);
    if (pack == null) return const Scaffold();

    return Scaffold(
      body: WorldBackground(
        world: run.world,
        child: SafeArea(
          child: Column(
            children: [
              RunHeader(title: l10n.packName(pack.kind)),
              const KutRow(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    SectionLabel(l10n.consumablesTitle),
                    const Spacer(),
                    const ConsumableBar(cardWidth: 40),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.packChoose,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Palette.gold,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (var i = 0; i < pack.choices.length; i++)
                      _ChoiceRow(
                        key: Key('pack-choice-$i'),
                        choice: pack.choices[i],
                        enabled: run.canChoose(i),
                        onChoose: () => controller.choosePackOption(i),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: OutlinedButton(
                  key: const Key('skip-pack'),
                  onPressed: controller.skipPack,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Palette.cream,
                    side: const BorderSide(color: Palette.goldDark),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: Text(l10n.skip),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    super.key,
    required this.choice,
    required this.enabled,
    required this.onChoose,
  });

  final PackChoice choice;
  final bool enabled;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const w = 60.0;
    final (Widget art, String title, String desc) = switch (choice) {
      KutChoice(:final kut) => (
        KutCard(definition: kut, width: w),
        '${l10n.kutName(kut.id)} · ${l10n.rarityName(kut.rarity)}',
        l10n.kutDescription(kut.id),
      ),
      ConsumableChoice(:final item) => (
        ConsumableCard(item: item, width: w),
        l10n.consumableName(item),
        l10n.consumableDescription(item),
      ),
      TileChoice(:final tile) => (
        TileView(tile: tile, okey: null, width: w * 0.8),
        l10n.tileAdded,
        l10n.tileDescription(tile),
      ),
    };
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Palette.night.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.gold.withValues(alpha: 0.7)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: w,
              child: Center(child: art),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Palette.textMuted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: enabled ? onChoose : null,
              style: FilledButton.styleFrom(
                backgroundColor: Palette.gold,
                foregroundColor: Palette.night,
              ),
              child: Text(l10n.buy),
            ),
          ],
        ),
      ),
    );
  }
}
