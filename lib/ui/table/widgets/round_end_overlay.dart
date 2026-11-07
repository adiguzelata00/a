import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/core/core.dart';

import '../../l10n_ext.dart';
import '../../theme/palette.dart';
import '../table_controller.dart';

/// Shown when the round is over (Phase 2: single round, then restart).
class RoundEndOverlay extends ConsumerWidget {
  const RoundEndOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final round = ref.watch(tableControllerProvider.select((s) => s.round));
    final l10n = context.l10n;
    final won = round.phase == RoundPhase.won;

    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          builder: (context, s, child) =>
              Transform.scale(scale: s, child: child),
          child: Container(
            key: const Key('round-end'),
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Palette.night,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: won ? Palette.gold : Palette.red,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  won ? l10n.roundWon : l10n.roundLost,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: won ? Palette.gold : Palette.red,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.finalScore(round.score, round.target),
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  l10n.bestHand(round.bestHandScore),
                  style: const TextStyle(color: Palette.textMuted),
                ),
                if (won)
                  Text(
                    l10n.handsLeftBonus(round.handsLeft),
                    style: const TextStyle(color: Palette.textMuted),
                  ),
                const SizedBox(height: 20),
                FilledButton(
                  key: const Key('new-round-button'),
                  onPressed: () =>
                      ref.read(tableControllerProvider.notifier).newRound(),
                  style: FilledButton.styleFrom(
                    backgroundColor: Palette.gold,
                    foregroundColor: Palette.night,
                    minimumSize: const Size(180, 48),
                  ),
                  child: Text(
                    won ? l10n.newRound : l10n.tryAgain,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
