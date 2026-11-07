import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/core/core.dart';

import '../game/game_controller.dart';
import '../l10n_ext.dart';
import '../theme/app_theme.dart';
import '../theme/palette.dart';
import '../widgets/cards.dart';
import '../widgets/world_background.dart';
import 'run_header.dart';

/// "Tur Sonucu": round score and the Akçe breakdown.
class CashoutScreen extends ConsumerWidget {
  const CashoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(gameControllerProvider.select((s) => s.run!));
    ref.watch(gameControllerProvider.select((s) => s.version));
    final summary = run.lastSummary;
    final l10n = context.l10n;
    if (summary == null) return const Scaffold();

    String label(CashoutLine line) => switch (line.kind) {
      CashoutKind.roundReward => l10n.cashRoundReward,
      CashoutKind.handsLeft => l10n.cashHandsLeft,
      CashoutKind.interest => l10n.cashInterest,
      CashoutKind.kut => l10n.kutName(line.kutId ?? ''),
      CashoutKind.goldTiles => l10n.cashGoldTiles,
      CashoutKind.tileMoney => l10n.cashTileMoney,
    };

    return Scaffold(
      body: WorldBackground(
        world: run.world,
        child: SafeArea(
          child: Column(
            children: [
              const RunHeader(),
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Palette.night.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Palette.gold, width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.cashoutTitle,
                          key: const Key('cashout-title'),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Palette.gold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.finalScore(summary.score, summary.target),
                          style: const TextStyle(color: Palette.textMuted),
                        ),
                        if (summary.savedBy != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            l10n.savedBy(l10n.kutName(summary.savedBy!)),
                            style: const TextStyle(
                              color: Palette.sealPurple,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        for (var i = 0; i < summary.lines.length; i++)
                          _AppearLine(
                            index: i,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      label(summary.lines[i]),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Text(
                                    '+${summary.lines[i].amount}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Palette.gold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const Divider(color: Palette.goldDark, height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.cashTotal,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            MoneyText(summary.total, size: 22),
                          ],
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          key: const Key('collect'),
                          onPressed: ref
                              .read(gameControllerProvider.notifier)
                              .collectCashout,
                          style: FilledButton.styleFrom(
                            backgroundColor: Palette.gold,
                            foregroundColor: Palette.night,
                            minimumSize: const Size(200, 50),
                            textStyle: const TextStyle(
                              fontFamily: appFontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          child: Text(l10n.collect),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lines slide in one after another.
class _AppearLine extends StatelessWidget {
  const _AppearLine({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 250 + 150 * index),
      curve: Curves.easeOut,
      builder: (context, t, c) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(24 * (1 - t), 0), child: c),
      ),
      child: child,
    );
  }
}
