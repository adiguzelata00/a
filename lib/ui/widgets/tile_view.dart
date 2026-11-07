import 'package:flutter/material.dart';
import 'package:tengri_taslari/core/core.dart';

import '../art/tile_painter.dart';

/// A single okey tile, painted with [TilePainter].
class TileView extends StatelessWidget {
  const TileView({
    super.key,
    required this.tile,
    required this.okey,
    required this.width,
    this.faceDown = false,
    this.highlight = false,
    this.dimmed = false,
  });

  final Tile tile;
  final OkeyInfo? okey;
  final double width;
  final bool faceDown;
  final bool highlight;
  final bool dimmed;

  double get height => width / TilePainter.aspect;

  @override
  Widget build(BuildContext context) {
    final o = okey;
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(width, height),
        painter: TilePainter(
          TileLook(
            tile: tile,
            face: o?.faceOf(tile),
            isWild: o?.isWild(tile) ?? false,
            faceDown: faceDown,
            highlight: highlight,
            dimmed: dimmed,
          ),
        ),
      ),
    );
  }
}
