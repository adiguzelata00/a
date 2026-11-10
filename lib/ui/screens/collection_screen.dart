import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/core/core.dart';
import 'package:tengri_taslari/data/bosses.dart';
import 'package:tengri_taslari/data/kuts.dart';

import '../game/profile_controller.dart';
import '../l10n_ext.dart';
import '../theme/palette.dart';
import '../widgets/cards.dart';
import '../widgets/kut_row.dart';

/// "Koleksiyon": discovered Kuts and bosses, plus profile records.
class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(profileProvider);
    final found = allKuts
        .where((k) => profile.discoveredKuts.contains(k.id))
        .length;
    final bosses = allBosses
        .where((b) => profile.seenBosses.contains(b.id))
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.collectionTitle),
        backgroundColor: Palette.night,
        foregroundColor: Palette.gold,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Record(l10n.profileRuns, '${profile.runsStarted}'),
                  _Record(l10n.profileWins, '${profile.runsWon}'),
                  _Record(l10n.profileBestHand, '${profile.bestHand}'),
                  _Record(l10n.profileHighestFloor, '${profile.highestFloor}'),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionLabel(l10n.collectionKuts(found, allKuts.length)),
                  const SizedBox(height: 2),
                  Text(
                    l10n.collectionHint,
                    style: const TextStyle(
                      color: Palette.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 90,
                childAspectRatio: 0.56,
                mainAxisSpacing: 12,
                crossAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate(childCount: allKuts.length, (
                context,
                i,
              ) {
                final k = allKuts[i];
                final open = profile.discoveredKuts.contains(k.id);
                return _KutTile(definition: k, discovered: open);
              }),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            sliver: SliverToBoxAdapter(
              child: SectionLabel(
                l10n.collectionBosses(bosses, allBosses.length),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList.list(
              children: [
                for (final b in allBosses)
                  _BossRow(id: b.id, seen: profile.seenBosses.contains(b.id)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Record extends StatelessWidget {
  const _Record(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    width: 160,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Palette.nightLight,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Palette.goldDark.withValues(alpha: 0.6)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Palette.textMuted, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Palette.gold,
          ),
        ),
      ],
    ),
  );
}

class _KutTile extends StatelessWidget {
  const _KutTile({required this.definition, required this.discovered});
  final KutDefinition definition;
  final bool discovered;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final card = discovered
        ? KutCard(definition: definition, width: 70)
        : Container(
            width: 70,
            height: 91,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Palette.nightLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Palette.goldDark.withValues(alpha: 0.4),
              ),
            ),
            child: const Text(
              '?',
              style: TextStyle(fontSize: 28, color: Palette.textMuted),
            ),
          );
    return GestureDetector(
      onTap: discovered
          ? () => showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Palette.night,
                title: Text(
                  l10n.kutName(definition.id),
                  style: const TextStyle(color: Palette.gold),
                ),
                content: Text(
                  '${l10n.rarityName(definition.rarity)}\n\n'
                  '${l10n.kutDescription(definition.id)}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.back),
                  ),
                ],
              ),
            )
          : null,
      child: Column(
        children: [
          card,
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              discovered
                  ? l10n.rarityName(definition.rarity)
                  : l10n.collectionLocked,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: discovered
                    ? rarityColor(definition.rarity)
                    : Palette.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BossRow extends StatelessWidget {
  const _BossRow({required this.id, required this.seen});
  final String id;
  final bool seen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            seen ? Icons.visibility : Icons.help_outline,
            size: 18,
            color: seen ? Palette.multRed : Palette.textMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: seen
                ? Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${l10n.bossName(id)}  ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Palette.multRed,
                          ),
                        ),
                        TextSpan(text: l10n.bossDescription(id)),
                      ],
                    ),
                  )
                : Text(
                    l10n.collectionLocked,
                    style: const TextStyle(color: Palette.textMuted),
                  ),
          ),
        ],
      ),
    );
  }
}
