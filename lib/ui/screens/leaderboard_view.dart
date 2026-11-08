import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/services/leaderboard/leaderboard_service.dart';

import '../l10n_ext.dart';
import '../theme/palette.dart';

/// "Günün sıralaması": ranked daily results of everyone who can open the
/// shared page (browser version), or a note where there is no backend.
class LeaderboardView extends ConsumerWidget {
  const LeaderboardView({super.key, required this.date, this.maxRows = 50});

  final String date;
  final int maxRows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final rows = ref.watch(dailyLeaderboardProvider(date));

    Widget note(String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: const TextStyle(color: Palette.textMuted)),
    );

    return Column(
      key: const Key('leaderboard'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.leaderboardTitle.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 1,
                  color: Palette.textMuted,
                ),
              ),
            ),
            IconButton(
              key: const Key('leaderboard-refresh'),
              tooltip: l10n.leaderboardRefresh,
              visualDensity: VisualDensity.compact,
              onPressed: () => ref.invalidate(dailyLeaderboardProvider(date)),
              icon: const Icon(Icons.refresh, color: Palette.gold, size: 20),
            ),
          ],
        ),
        rows.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(12),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (_, _) => note(l10n.leaderboardError),
          data: (list) {
            if (list == null) return note(l10n.leaderboardUnavailable);
            if (list.isEmpty) return note(l10n.leaderboardEmpty);
            final myIndex = list.indexWhere((e) => e.isMe);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (myIndex >= 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      l10n.leaderboardYourRank(myIndex + 1, list.length),
                      key: const Key('leaderboard-my-rank'),
                      style: const TextStyle(
                        color: Palette.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                for (var i = 0; i < list.length && i < maxRows; i++)
                  _Row(rank: i + 1, entry: list[i]),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.rank, required this.entry});
  final int rank;
  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final medal = switch (rank) {
      1 => Palette.gold,
      2 => const Color(0xFFC0C6CC),
      3 => const Color(0xFFCD7F32),
      _ => Palette.textMuted,
    };
    final name = entry.isMe
        ? l10n.leaderboardYou
        : (entry.name.isEmpty ? l10n.leaderboardSomeone : entry.name);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: entry.isMe
            ? Palette.goldDark.withValues(alpha: 0.25)
            : Palette.nightLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: entry.isMe
              ? Palette.gold
              : Palette.goldDark.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '$rank',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: medal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: entry.isMe ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
          if (entry.won)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.star, size: 16, color: Palette.gold),
            ),
          if (!entry.finished && !entry.won)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                l10n.leaderboardOngoing,
                style: const TextStyle(color: Palette.textMuted, fontSize: 11),
              ),
            ),
          Text(
            l10n.leaderboardRow(entry.floor, entry.score),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
