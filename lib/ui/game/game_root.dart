import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n_ext.dart';
import '../screens/cashout_screen.dart';
import '../screens/menu_screen.dart';
import '../screens/pack_screen.dart';
import '../screens/round_select_screen.dart';
import '../screens/run_end_screen.dart';
import '../screens/shop_screen.dart';
import '../table/table_screen.dart';
import '../theme/palette.dart';
import 'game_controller.dart';
import 'game_state.dart';

/// Shows the screen for the current run phase and rejected-action messages.
class GameRoot extends ConsumerWidget {
  const GameRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = ref.watch(gameControllerProvider.select((s) => s.screen));

    ref.listen(gameControllerProvider.select((s) => (s.errorCount, s.error)), (
      prev,
      next,
    ) {
      final error = next.$2;
      if (prev?.$1 == next.$1 || error == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(context.l10n.errorText(error)),
            backgroundColor: Palette.red,
            duration: const Duration(seconds: 2),
          ),
        );
    });

    final child = switch (screen) {
      GameScreen.menu => const MenuScreen(),
      GameScreen.roundSelect => const RoundSelectScreen(),
      GameScreen.table => const TableScreen(),
      GameScreen.cashout => const CashoutScreen(),
      GameScreen.shop => const ShopScreen(),
      GameScreen.pack => const PackScreen(),
      GameScreen.runEnd => const RunEndScreen(),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      child: KeyedSubtree(key: ValueKey(screen), child: child),
    );
  }
}
