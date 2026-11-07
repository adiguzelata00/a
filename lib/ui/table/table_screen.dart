import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/palette.dart';
import '../widgets/effects.dart';
import 'table_controller.dart';
import 'widgets/action_bar.dart';
import 'widgets/hud.dart';
import 'widgets/kut_row.dart';
import 'widgets/play_area.dart';
import 'widgets/rack_view.dart';
import 'widgets/round_end_overlay.dart';

/// The game table ("Oyun Masası").
class TableScreen extends ConsumerWidget {
  const TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shake = ref.watch(
      tableControllerProvider.select((s) => s.shakeCount),
    );
    final showResult = ref.watch(
      tableControllerProvider.select((s) => s.showResult),
    );

    return Scaffold(
      body: DecoratedBox(
        // Floors 1-2: Yeraltı (underworld) colors.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Palette.underworldTop,
              Palette.night,
              Palette.underworldBottom,
            ],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
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
            if (showResult) const Positioned.fill(child: RoundEndOverlay()),
          ],
        ),
      ),
    );
  }
}
