import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/core/core.dart';

import '../game/game_controller.dart';
import '../l10n_ext.dart';
import '../theme/palette.dart';
import '../widgets/particles.dart';
import 'daily_screen.dart';
import 'leaderboard_view.dart';
import '../widgets/world_background.dart';

/// "Koşu Sonu": won or lost, with run statistics.
class RunEndScreen extends ConsumerWidget {
  const RunEndScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(gameControllerProvider.select((s) => s.run!));
    ref.watch(gameControllerProvider.select((s) => s.version));
    final l10n = context.l10n;
    final controller = ref.read(gameControllerProvider.notifier);
    final won = run.phase == RunPhase.won;
    final stats = run.stats;
    final favKut = stats.mostUsedKut;
    final favHand = stats.mostPlayedHand;

    final rows = <(String, String)>[
      (l10n.statsFloor, '${run.floor}'),
      (l10n.statsRounds, '${stats.roundsWon}'),
      (l10n.statsHands, '${stats.handsPlayed}'),
      (
        l10n.statsBestHand,
        stats.bestHandType == null
            ? '-'
            : '${stats.bestHand} (${l10n.handName(stats.bestHandType!)})',
      ),
      (l10n.statsTotalScore, '${stats.totalScore}'),
      (l10n.statsFavoriteHand, favHand == null ? '-' : l10n.handName(favHand)),
      (l10n.statsFavoriteKut, favKut == null ? '-' : l10n.kutName(favKut)),
      (l10n.statsSeed, run.seedCode),
    ];

    return Scaffold(
      body: WorldBackground(
        world: won ? 2 : run.world,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                key: const Key('run-end'),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Palette.night.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: won ? Palette.gold : Palette.red,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ParticleBurst(
                      trigger: won ? run.seedCode : null,
                      burstOnStart: won,
                      count: 70,
                      spread: 220,
                      child: Text(
                        won ? l10n.runWonTitle : l10n.runLostTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: won ? Palette.gold : Palette.red,
                        ),
                      ),
                    ),
                    if (run.isDaily) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.dailyTitle} · '
                        '${formatDailyDate(context, run.dailyDate!)}',
                        style: const TextStyle(color: Palette.gold),
                      ),
                    ],
                    if (!won && run.lastSummary != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.finalScore(
                          run.lastSummary!.score,
                          run.lastSummary!.target,
                        ),
                        style: const TextStyle(color: Palette.textMuted),
                      ),
                    ],
                    const SizedBox(height: 16),
                    for (final (label, value) in rows)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                label,
                                style: const TextStyle(
                                  color: Palette.textMuted,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Text(
                                value,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    if (won)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: FilledButton(
                          key: const Key('continue-endless'),
                          onPressed: controller.continueEndless,
                          style: FilledButton.styleFrom(
                            backgroundColor: Palette.gold,
                            foregroundColor: Palette.night,
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: Text(l10n.continueEndless),
                        ),
                      ),
                    if (run.isDaily)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: LeaderboardView(
                          date: run.dailyDate!,
                          maxRows: 5,
                        ),
                      ),
                    if (run.isDaily)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: OutlinedButton.icon(
                          key: const Key('daily-share-end'),
                          onPressed: () => shareDailyResult(
                            context,
                            run.dailyDate!,
                            DailyResult.of(run),
                            run.seedCode,
                          ),
                          icon: const Icon(Icons.ios_share),
                          label: Text(l10n.dailyShare),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Palette.gold,
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ),
                    // A daily run ends here; a new normal run would replace
                    // the saved one, so it is only offered for normal runs.
                    if (!run.isDaily)
                      FilledButton(
                        key: const Key('new-run'),
                        onPressed: () => controller.newRun(),
                        style: FilledButton.styleFrom(
                          backgroundColor: won
                              ? Palette.nightLighter
                              : Palette.gold,
                          foregroundColor: won ? Palette.cream : Palette.night,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: Text(l10n.menuNewRun),
                      ),
                    const SizedBox(height: 10),
                    TextButton(
                      key: const Key('end-to-menu'),
                      onPressed: controller.toMenu,
                      child: Text(
                        l10n.mainMenu,
                        style: const TextStyle(color: Palette.gold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
