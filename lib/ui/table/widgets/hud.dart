import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n_ext.dart';

import 'package:tengri_taslari/services/settings_service.dart';

import '../../screens/how_to_play_screen.dart';
import '../../theme/palette.dart';
import '../../widgets/effects.dart';
import '../../game/game_controller.dart';

/// Top bar: floor, target, score, hands, discards, money, speed.
class Hud extends ConsumerWidget {
  const Hud({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = ref.watch(
      gameControllerProvider.select(
        (s) => (
          score: s.displayedScore,
          target: s.round!.target,
          hands: s.round!.handsLeft,
          discards: s.round!.discardsLeft,
          money: s.run!.money,
          floor: s.run!.floor,
          roundInFloor: s.run!.roundInFloor,
          seed: s.run!.seedCode,
          deck: s.round!.drawPileCount,
          bossId: s.round!.isBossRound ? s.run!.boss.id : null,
          endless: s.run!.endless,
        ),
      ),
    );
    final speed = ref.watch(settingsProvider.select((s) => s.gameSpeed));
    final roundName = s.bossId != null
        ? l10n.bossName(s.bossId!)
        : l10n.roundName(s.roundInFloor);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${l10n.floorLabel(s.floor)} · $roundName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  l10n.seedLabel(s.seed),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                key: const Key('hud-help'),
                tooltip: l10n.howToHelpTooltip,
                visualDensity: VisualDensity.compact,
                onPressed: () =>
                    Navigator.of(context).push(HowToPlayScreen.route()),
                icon: const Icon(Icons.help_outline, color: Palette.gold),
              ),
              _SpeedChip(
                label: l10n.speedLabel(speed),
                onTap: () => ref.read(settingsProvider.notifier).cycleSpeed(),
              ),
            ],
          ),
          if (s.bossId != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                l10n.bossDescription(s.bossId!),
                key: const Key('boss-banner'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Palette.multRed, fontSize: 12),
              ),
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: _Panel(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Stat(
                        label: l10n.target,
                        value: s.target.toDouble(),
                        color: Palette.cream,
                      ),
                      _Stat(
                        key: const Key('hud-score'),
                        label: l10n.score,
                        value: s.score.toDouble(),
                        color: s.score >= s.target
                            ? Palette.success
                            : Palette.gold,
                        big: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 4,
                child: _Panel(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Stat(
                        label: l10n.hands,
                        value: s.hands.toDouble(),
                        color: Palette.chipsBlue,
                      ),
                      _Stat(
                        label: l10n.discards,
                        value: s.discards.toDouble(),
                        color: Palette.multRed,
                      ),
                      _Stat(
                        label: l10n.money,
                        value: s.money.toDouble(),
                        color: Palette.gold,
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
    decoration: BoxDecoration(
      color: Palette.night.withValues(alpha: 0.75),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Palette.goldDark, width: 1),
    ),
    child: child,
  );
}

class _Stat extends StatelessWidget {
  const _Stat({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.big = false,
  });

  final String label;
  final double value;
  final Color color;
  final bool big;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Palette.textMuted),
            ),
            CountUpText(
              value: value,
              duration: Duration(milliseconds: big ? 600 : 250),
              style: TextStyle(
                fontSize: big ? 22 : 17,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeedChip extends StatelessWidget {
  const _SpeedChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.gold),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Palette.gold,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
