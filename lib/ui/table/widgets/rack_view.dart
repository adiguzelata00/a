import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tengri_taslari/core/core.dart';

import '../../art/tile_painter.dart';
import '../../l10n_ext.dart';
import '../../theme/palette.dart';
import '../../widgets/effects.dart';
import '../../widgets/tile_view.dart';
import '../event_labels.dart';
import '../table_controller.dart';

/// Wooden rack ("istaka"). Tap = select, drag = reorder.
/// During scoring it shows the held tiles and their effects (Demir ...).
class RackView extends ConsumerWidget {
  const RackView({super.key});

  /// Below this tile width the rack switches to two rows.
  static const double minSingleRowTileWidth = 40;
  static const double maxTileWidth = 56;
  static const double gap = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tableControllerProvider);
    final controller = ref.read(tableControllerProvider.notifier);
    final tiles = state.visibleRack;
    final round = state.round;
    final playback = state.playback;
    final event = playback?.current;
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        final inner = constraints.maxWidth - 28;
        // Layout is based on the full rack size (not the current tile count)
        // so the rack does not jump between one and two rows while scoring.
        final capacity = tiles.length > round.config.handSize
            ? tiles.length
            : round.config.handSize;
        final singleRowWidth = (inner - gap * (capacity - 1)) / capacity;
        final perRow = singleRowWidth >= minSingleRowTileWidth
            ? capacity
            : (capacity / 2).ceil();
        final rowCount = (capacity / perRow).ceil();
        final tileWidth = ((inner - gap * (perRow - 1)) / perRow).clamp(
          24.0,
          maxTileWidth,
        );
        final rows = <List<int>>[
          for (var start = 0; start < tiles.length; start += perRow)
            [
              for (var i = start; i < start + perRow && i < tiles.length; i++)
                i,
            ],
        ];

        Widget buildTile(int i) {
          final tile = tiles[i];
          if (playback != null) {
            final active =
                event != null &&
                event.source == ScoreSourceKind.heldTile &&
                event.sourceIndex == i;
            return _HeldTile(
              tile: tile,
              okey: round.okey,
              width: tileWidth,
              trigger: active ? playback.step : null,
              label: active ? labelForEvent(l10n, event) : null,
            );
          }
          final rackIndex = i;
          return _RackTile(
            key: ValueKey(tile.id),
            tile: tile,
            okey: round.okey,
            width: tileWidth,
            selected: state.selectedIds.contains(tile.id),
            faceDown: round.isFaceDown(rackIndex),
            onTap: () {
              if (round.isFaceDown(rackIndex)) {
                controller.reveal(rackIndex);
              } else {
                controller.toggleTile(tile.id);
              }
            },
            onDragOver: (draggedId) {
              final from = round.rack.indexWhere((t) => t.id == draggedId);
              if (from >= 0 && from != rackIndex) {
                controller.moveTile(from, rackIndex);
              }
            },
          );
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.fromLTRB(8, 18, 8, 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Palette.woodLight, Palette.woodDark],
            ),
            borderRadius: BorderRadius.circular(10),
            border: const Border(
              bottom: BorderSide(color: Palette.woodEdge, width: 6),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final row in rows)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: SizedBox(
                    height: tileWidth / TilePainter.aspect,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final i in row) ...[
                          if (i != row.first) const SizedBox(width: gap),
                          buildTile(i),
                        ],
                      ],
                    ),
                  ),
                ),
              // Keep the rack height stable when fewer tiles are shown.
              for (var r = rows.length; r < rowCount; r++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: SizedBox(height: tileWidth / TilePainter.aspect),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RackTile extends StatelessWidget {
  const _RackTile({
    super.key,
    required this.tile,
    required this.okey,
    required this.width,
    required this.selected,
    required this.faceDown,
    required this.onTap,
    required this.onDragOver,
  });

  final Tile tile;
  final OkeyInfo okey;
  final double width;
  final bool selected;
  final bool faceDown;
  final VoidCallback onTap;
  final void Function(int draggedTileId) onDragOver;

  @override
  Widget build(BuildContext context) {
    final view = TileView(
      tile: tile,
      okey: okey,
      width: width,
      faceDown: faceDown,
      highlight: selected,
    );
    return DropIn(
      child: DragTarget<int>(
        onWillAcceptWithDetails: (details) {
          if (details.data != tile.id) onDragOver(details.data);
          return true;
        },
        builder: (context, _, _) => Draggable<int>(
          data: tile.id,
          feedback: Material(
            color: Colors.transparent,
            child: Transform.scale(
              scale: 1.15,
              child: TileView(
                tile: tile,
                okey: okey,
                width: width,
                faceDown: faceDown,
              ),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.25, child: view),
          child: GestureDetector(
            key: Key('rack-tile-${tile.id}'),
            onTap: onTap,
            child: AnimatedSlide(
              offset: selected ? const Offset(0, -0.22) : Offset.zero,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: view,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeldTile extends StatelessWidget {
  const _HeldTile({
    required this.tile,
    required this.okey,
    required this.width,
    required this.trigger,
    required this.label,
  });

  final Tile tile;
  final OkeyInfo okey;
  final double width;
  final int? trigger;
  final (String, Color)? label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Bounce(
          trigger: trigger,
          child: TileView(tile: tile, okey: okey, width: width),
        ),
        if (label != null && trigger != null)
          Positioned(
            top: -14,
            child: FloatingLabel(
              trigger: trigger!,
              text: label!.$1,
              color: label!.$2,
            ),
          ),
      ],
    );
  }
}
