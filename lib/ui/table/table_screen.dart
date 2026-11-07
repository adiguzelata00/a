import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/game_controller.dart';
import '../widgets/effects.dart';
import '../widgets/kut_row.dart';
import '../widgets/world_background.dart';
import 'widgets/action_bar.dart';
import 'widgets/hud.dart';
import 'widgets/play_area.dart';
import 'widgets/rack_view.dart';

/// The game table ("Oyun Masası").
class TableScreen extends ConsumerWidget {
  const TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shake = ref.watch(gameControllerProvider.select((s) => s.shakeCount));
    final world = ref.watch(
      gameControllerProvider.select((s) => s.run?.world ?? 0),
    );

    return Scaffold(
      body: WorldBackground(
        world: world,
        child: SafeArea(
          child: ScreenShake(
            trigger: shake,
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
      ),
    );
  }
}
