import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/game_controller.dart';
import '../l10n_ext.dart';
import '../theme/palette.dart';
import '../widgets/cards.dart';
import 'how_to_play_screen.dart';

/// Top bar for between-round screens: menu button, floor/world, money.
class RunHeader extends ConsumerWidget {
  const RunHeader({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.watch(
      gameControllerProvider.select(
        (s) => (
          floor: s.run!.floor,
          world: s.run!.world,
          endless: s.run!.endless,
          daily: s.run!.isDaily,
          money: s.run!.money,
        ),
      ),
    );
    final world = s.endless ? l10n.endlessLabel : l10n.worldName(s.world);
    final worldText = s.daily ? '${l10n.dailyTag} · $world' : world;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
      child: Row(
        children: [
          IconButton(
            key: const Key('to-menu'),
            onPressed: ref.read(gameControllerProvider.notifier).toMenu,
            icon: const Icon(Icons.menu, color: Palette.gold),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? l10n.floorLabel(s.floor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Palette.gold,
                  ),
                ),
                Text(
                  title == null
                      ? worldText
                      : '${l10n.floorLabel(s.floor)} · $worldText',
                  style: const TextStyle(
                    color: Palette.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('header-help'),
            tooltip: l10n.howToHelpTooltip,
            onPressed: () =>
                Navigator.of(context).push(HowToPlayScreen.route()),
            icon: const Icon(Icons.help_outline, color: Palette.gold),
          ),
          MoneyText(s.money, size: 20),
        ],
      ),
    );
  }
}
