import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/core/core.dart';

import '../game/game_controller.dart';
import '../l10n_ext.dart';
import '../theme/app_theme.dart';
import '../theme/palette.dart';
import '../widgets/kut_row.dart';
import '../widgets/world_background.dart';
import 'run_header.dart';

/// Floor overview: small trial, big trial and boss ("Kat / Tur Seçimi").
class RoundSelectScreen extends ConsumerWidget {
  const RoundSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final run = state.run!;
    final l10n = context.l10n;
    final controller = ref.read(gameControllerProvider.notifier);

    return Scaffold(
      body: WorldBackground(
        world: run.world,
        child: SafeArea(
          child: Column(
            children: [
              const RunHeader(),
              const SizedBox(height: 4),
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
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  children: [
                    for (var slot = 0; slot < 3; slot++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _RoundCard(
                          slot: slot,
                          run: run,
                          onStart: controller.startRound,
                          onSkip: controller.skipRound,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundCard extends StatelessWidget {
  const _RoundCard({
    required this.slot,
    required this.run,
    required this.onStart,
    required this.onSkip,
  });

  final int slot;
  final RunState run;
  final VoidCallback onStart;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = run.slots[slot];
    final current = status == RoundSlotStatus.current;
    final isBoss = slot == 2;
    final accent = isBoss ? Palette.multRed : Palette.gold;
    final statusText = switch (status) {
      RoundSlotStatus.done => l10n.statusDone,
      RoundSlotStatus.skipped => l10n.statusSkipped,
      RoundSlotStatus.upcoming => l10n.statusUpcoming,
      RoundSlotStatus.current => null,
    };

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: current || status == RoundSlotStatus.upcoming ? 1 : 0.55,
      child: Container(
        key: Key('round-card-$slot'),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Palette.night.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: current ? accent : Palette.goldDark.withValues(alpha: 0.5),
            width: current ? 2 : 1,
          ),
          boxShadow: current
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.35),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isBoss ? l10n.bossName(run.boss.id) : l10n.roundName(slot),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ),
                if (statusText != null)
                  Text(
                    statusText,
                    style: const TextStyle(color: Palette.textMuted),
                  ),
              ],
            ),
            if (isBoss) ...[
              const SizedBox(height: 2),
              Text(
                l10n.bossDescription(run.boss.id),
                style: const TextStyle(color: Palette.cream, fontSize: 14),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${l10n.target}: ',
                  style: const TextStyle(color: Palette.textMuted),
                ),
                Text(
                  '${run.targetOf(slot)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.rewardLabel(run.rules.roundRewards[slot]),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Palette.gold),
                  ),
                ),
              ],
            ),
            if (!isBoss && status != RoundSlotStatus.done) ...[
              const SizedBox(height: 4),
              Text(
                l10n.skipReward(
                  l10n.tagText(run.floorTags[slot], run.rules.skipMoney),
                ),
                style: const TextStyle(color: Palette.textMuted, fontSize: 13),
              ),
            ],
            if (current) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (!isBoss)
                    Expanded(
                      child: OutlinedButton(
                        key: const Key('skip-round'),
                        onPressed: onSkip,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Palette.cream,
                          side: const BorderSide(color: Palette.goldDark),
                          minimumSize: const Size.fromHeight(46),
                        ),
                        child: Text(l10n.skipRound),
                      ),
                    ),
                  if (!isBoss) const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      key: const Key('start-round'),
                      onPressed: onStart,
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: isBoss ? Palette.cream : Palette.night,
                        minimumSize: const Size.fromHeight(46),
                        textStyle: const TextStyle(
                          fontFamily: appFontFamily,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      child: Text(l10n.startRound),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
