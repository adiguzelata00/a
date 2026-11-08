import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/data/balance.dart';
import 'package:tengri_taslari/data/kuts.dart';

import '../game/game_controller.dart';
import '../game/profile_controller.dart';
import '../l10n_ext.dart';
import '../theme/app_theme.dart';
import '../theme/palette.dart';
import '../widgets/cards.dart';
import 'leaderboard_view.dart';

/// Formats a yyyy-MM-dd key as a localized date ("8 Kas 2026").
String formatDailyDate(BuildContext context, String date) =>
    MaterialLocalizations.of(context).formatFullDate(DateTime.parse(date));

/// Copies a daily result to the clipboard and confirms it.
Future<void> shareDailyResult(
  BuildContext context,
  String date,
  DailyResult result,
  String seed,
) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final text = l10n.dailyShareMessage(
    formatDailyDate(context, date),
    result,
    seed,
  );
  try {
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(SnackBar(content: Text(l10n.dailyCopied)));
  } catch (_) {
    // Some environments refuse clipboard access: show the text instead so
    // it can be selected and copied by hand.
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Palette.night,
        title: Text(l10n.dailyShare),
        content: SelectableText(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.back),
          ),
        ],
      ),
    );
  }
}

/// "Günlük Meydan Okuma": today's starting Kut and blessing, one attempt,
/// your result and recent days.
class DailyScreen extends ConsumerWidget {
  const DailyScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const DailyScreen());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    ref.watch(gameControllerProvider.select((s) => s.version));
    final profile = ref.watch(profileProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    final challenge = controller.todaysChallenge;
    final status = controller.dailyStatus();
    final result = profile.dailyResults[challenge.date];
    final kut = kutById(challenge.kutId);

    final history =
        profile.dailyResults.entries
            .where((e) => e.key != challenge.date)
            .toList()
          ..sort((a, b) => b.key.compareTo(a.key));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dailyTitle),
        backgroundColor: Palette.night,
        foregroundColor: Palette.gold,
      ),
      body: ListView(
        key: const Key('daily-screen'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            formatDailyDate(context, challenge.date),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Palette.gold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.dailyIntro,
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 16),
          _Panel(
            child: Row(
              children: [
                KutCard(definition: kut, width: 64),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dailyStartingKut.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: 1,
                          color: Palette.textMuted,
                        ),
                      ),
                      Text(
                        l10n.kutName(kut.id),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        l10n.kutDescription(kut.id),
                        style: const TextStyle(color: Palette.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _Panel(
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Palette.gold, size: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dailyBonusTitle.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: 1,
                          color: Palette.textMuted,
                        ),
                      ),
                      Text(
                        l10n.dailyBonusText(
                          challenge.bonus,
                          Balance.dailyBonusMoney,
                        ),
                        key: const Key('daily-bonus'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 54,
            child: FilledButton(
              key: const Key('daily-play'),
              onPressed: status == DailyStatus.done
                  ? null
                  : () {
                      controller.playDaily();
                      Navigator.of(context).pop();
                    },
              style: FilledButton.styleFrom(
                backgroundColor: Palette.gold,
                foregroundColor: Palette.night,
                textStyle: const TextStyle(
                  fontFamily: appFontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: Text(switch (status) {
                DailyStatus.available => l10n.dailyStart,
                DailyStatus.inProgress => l10n.dailyContinue,
                DailyStatus.done => l10n.dailyDoneButton,
              }),
            ),
          ),
          if (result != null) ...[
            const SizedBox(height: 16),
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dailyResultTitle,
                    style: const TextStyle(color: Palette.textMuted),
                  ),
                  Text(
                    l10n.dailyResultLine(result.floor, result.score),
                    key: const Key('daily-result'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (result.won)
                    Text(
                      l10n.dailyResultWon,
                      style: const TextStyle(color: Palette.gold),
                    )
                  else if (!result.finished)
                    Text(
                      l10n.dailyResultOngoing,
                      style: const TextStyle(color: Palette.textMuted),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    key: const Key('daily-share'),
                    onPressed: () => shareDailyResult(
                      context,
                      challenge.date,
                      result,
                      challenge.seedCode,
                    ),
                    icon: const Icon(Icons.ios_share),
                    label: Text(l10n.dailyShare),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          LeaderboardView(date: challenge.date),
          const SizedBox(height: 20),
          Text(
            l10n.dailyHistory.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1,
              color: Palette.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          if (history.isEmpty)
            Text(
              l10n.dailyNoHistory,
              style: const TextStyle(color: Palette.textMuted),
            )
          else
            for (final e in history.take(14))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Expanded(child: Text(formatDailyDate(context, e.key))),
                    if (e.value.won)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(Icons.star, size: 16, color: Palette.gold),
                      ),
                    Text(
                      l10n.dailyResultLine(e.value.floor, e.value.score),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Palette.nightLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Palette.goldDark.withValues(alpha: 0.6)),
    ),
    child: child,
  );
}
