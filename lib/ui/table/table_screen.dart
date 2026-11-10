import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/game_controller.dart';
import '../widgets/effects.dart';
import '../widgets/kut_row.dart';
import '../widgets/world_background.dart';
import 'widgets/action_bar.dart';
import 'widgets/boss_intro.dart';
import 'widgets/hud.dart';
import 'widgets/play_area.dart';
import 'widgets/rack_view.dart';

/// The game table ("Oyun Masası").
class TableScreen extends ConsumerWidget {
  const TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shake = ref.watch(gameControllerProvider.select((s) => s.shakeCount));
    final strength = ref.watch(
      gameControllerProvider.select((s) => s.shakeStrength),
    );
    final world = ref.watch(
      gameControllerProvider.select((s) => s.run?.world ?? 0),
    );
    // Boss announcement before the first hand of a boss round.
    final intro = ref.watch(
      gameControllerProvider.select((s) {
        final r = s.round;
        if (r == null || !r.isBossRound || r.handsPlayed > 0) return null;
        return (round: identityHashCode(r), boss: s.run!.boss.id);
      }),
    );

    return Scaffold(
      body: WorldBackground(
        world: world,
        child: Stack(
          children: [
            SafeArea(
              child: ScreenShake(
                trigger: shake,
                strength: strength,
                child: const Column(
                  children: [
                    Hud(),
                    SizedBox(height: 6),
                    KutRow(),
                    SizedBox(height: 8),
                    Expanded(child: PlayArea()),
                    RackView(),
                    ActionBar(),
                  ],
                ),
              ),
            ),
            if (intro != null)
              Positioned.fill(
                child: BossIntro(
                  key: ValueKey(intro.round),
                  bossId: intro.boss,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
