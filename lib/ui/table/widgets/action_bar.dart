import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n_ext.dart';
import '../../theme/palette.dart';
import '../table_controller.dart';

/// Bottom buttons: Discard, sort by number / color, Play.
class ActionBar extends ConsumerWidget {
  const ActionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(
      tableControllerProvider.select(
        (s) =>
            (canPlay: s.canPlay, canDiscard: s.canDiscard, busy: s.isAnimating),
      ),
    );
    final controller = ref.read(tableControllerProvider.notifier);
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _BigButton(
              key: const Key('discard-button'),
              label: l10n.discard,
              color: Palette.red,
              onPressed: s.canDiscard ? controller.discard : null,
            ),
          ),
          const SizedBox(width: 8),
          _SortButton(
            key: const Key('sort-number'),
            label: l10n.sortByNumber,
            icon: Icons.format_list_numbered,
            onPressed: s.busy ? null : controller.sortByNumber,
          ),
          const SizedBox(width: 6),
          _SortButton(
            key: const Key('sort-color'),
            label: l10n.sortByColor,
            icon: Icons.palette_outlined,
            onPressed: s.busy ? null : controller.sortByColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: _BigButton(
              key: const Key('play-button'),
              label: l10n.play,
              color: Palette.blue,
              onPressed: s.canPlay ? controller.play : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Palette.cream,
        disabledBackgroundColor: color.withValues(alpha: 0.3),
        disabledForegroundColor: Palette.cream.withValues(alpha: 0.4),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Palette.gold, width: 1.5),
        ),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      child: FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1)),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: Palette.gold,
          side: const BorderSide(color: Palette.goldDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
