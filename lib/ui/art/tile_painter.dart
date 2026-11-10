import 'package:flutter/material.dart';
import 'package:tengri_taslari/core/core.dart';

import '../theme/app_theme.dart';
import '../theme/palette.dart';
import 'symbols.dart';

/// Visual description of a tile for painting.
class TileLook {
  const TileLook({
    required this.tile,
    this.face,
    this.isWild = false,
    this.faceDown = false,
    this.highlight = false,
    this.dimmed = false,
    this.colorBlind = false,
  });

  final Tile tile;

  /// Face to show (fake okey -> okey face). Null = tile's own face.
  final TileFace? face;
  final bool isWild;
  final bool faceDown;
  final bool highlight;
  final bool dimmed;

  /// High-contrast colors and larger color symbols.
  final bool colorBlind;

  @override
  bool operator ==(Object other) =>
      other is TileLook &&
      other.tile == tile &&
      other.face == face &&
      other.isWild == isWild &&
      other.faceDown == faceDown &&
      other.highlight == highlight &&
      other.dimmed == dimmed &&
      other.colorBlind == colorBlind;

  @override
  int get hashCode =>
      Object.hash(tile, face, isWild, faceDown, highlight, dimmed, colorBlind);
}

/// Bakelite-style okey tile placeholder drawn with Canvas.
/// Aspect ratio ~ 0.72 (width / height).
class TilePainter extends CustomPainter {
  TilePainter(this.look);

  final TileLook look;

  static const double aspect = 0.72;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final radius = Radius.circular(w * 0.14);
    final depth = h * 0.06;
    final body = Rect.fromLTWH(0, 0, w, h - depth);

    // Drop shadow + side thickness.
    canvas.drawRRect(
      RRect.fromRectAndRadius(body.shift(Offset(0, depth + h * 0.02)), radius),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(body.shift(Offset(0, depth)), radius),
      Paint()..color = Palette.creamEdge,
    );

    if (look.faceDown) {
      _paintBack(canvas, body, radius);
      return;
    }

    final base = _bodyColor(look.tile.enhancement);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, radius),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(base, Colors.white, 0.25)!, base],
        ).createShader(body),
    );
    _paintEnhancementDetail(canvas, body, radius);

    if (look.isWild || look.highlight) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(body.deflate(w * 0.03), radius),
        Paint()
          ..color = look.isWild ? Palette.gold : Palette.cream
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.07,
      );
    }

    final face = look.face ?? TileFace(look.tile.color, look.tile.number);
    if (look.tile.isFakeOkey) {
      _paintFakeOkey(canvas, body, face);
    } else {
      _paintFace(canvas, body, face);
    }

    if (look.isWild) {
      final starRect = Rect.fromLTWH(w * 0.66, h * 0.04, w * 0.28, w * 0.28);
      drawColorSymbol(
        canvas,
        TileColor.yellow,
        starRect,
        Paint()..color = Palette.gold,
      );
    }
    if (look.tile.seal != Seal.none) {
      drawSealMark(
        canvas,
        look.tile.seal,
        Rect.fromLTWH(w * 0.07, h * 0.05, w * 0.28, w * 0.28),
        Palette.sealColor(look.tile.seal),
      );
    }

    if (look.dimmed) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(body, radius),
        Paint()..color = Palette.night.withValues(alpha: 0.45),
      );
    }
  }

  void _paintFace(Canvas canvas, Rect body, TileFace face) {
    final w = body.width;
    final color = Palette.tileColorFor(face.color, colorBlind: look.colorBlind);
    final onDark = look.tile.enhancement == Enhancement.skyStone;
    if (onDark) {
      canvas.drawCircle(
        Offset(body.center.dx, body.height * 0.42),
        w * 0.36,
        Paint()..color = Palette.cream,
      );
    }
    final tp = TextPainter(
      text: TextSpan(
        text: '${face.number}',
        style: TextStyle(
          fontFamily: appFontFamily,
          color: color,
          fontSize: w * (face.number >= 10 ? 0.5 : 0.6),
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(body.center.dx - tp.width / 2, body.height * 0.42 - tp.height / 2),
    );

    final symbolSize = w * (look.colorBlind ? 0.4 : 0.3);
    if (look.colorBlind && look.tile.seal == Seal.none) {
      // Second symbol in the corner, so the color reads at a glance.
      final s = w * 0.17;
      drawColorSymbol(
        canvas,
        face.color,
        Rect.fromLTWH(w * 0.08, body.height * 0.05, s, s),
        Paint()..color = color,
      );
    }
    drawColorSymbol(
      canvas,
      face.color,
      Rect.fromCenter(
        center: Offset(body.center.dx, body.height * 0.8),
        width: symbolSize,
        height: symbolSize,
      ),
      Paint()..color = onDark ? Palette.cream : color,
    );
  }

  void _paintFakeOkey(Canvas canvas, Rect body, TileFace okeyFace) {
    final w = body.width;
    drawFakeOkeyEmblem(
      canvas,
      Rect.fromCenter(
        center: Offset(body.center.dx, body.height * 0.38),
        width: w * 0.5,
        height: w * 0.55,
      ),
      Palette.goldDark,
    );
    // Small okey face it represents.
    final color = Palette.tileColorFor(
      okeyFace.color,
      colorBlind: look.colorBlind,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: '${okeyFace.number}',
        style: TextStyle(
          fontFamily: appFontFamily,
          color: color,
          fontSize: w * 0.26,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final y = body.height * 0.78;
    final symbol = w * 0.2;
    final total = tp.width + symbol + w * 0.04;
    final x = body.center.dx - total / 2;
    tp.paint(canvas, Offset(x, y - tp.height / 2));
    drawColorSymbol(
      canvas,
      okeyFace.color,
      Rect.fromLTWH(x + tp.width + w * 0.04, y - symbol / 2, symbol, symbol),
      Paint()..color = color,
    );
  }

  void _paintBack(Canvas canvas, Rect body, Radius radius) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, radius),
      Paint()..color = Palette.nightLighter,
    );
    canvas.drawCircle(
      body.center,
      body.width * 0.28,
      Paint()
        ..color = Palette.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = body.width * 0.06,
    );
    canvas.drawCircle(
      body.center,
      body.width * 0.08,
      Paint()..color = Palette.gold,
    );
  }

  void _paintEnhancementDetail(Canvas canvas, Rect body, Radius radius) {
    switch (look.tile.enhancement) {
      case Enhancement.iron:
        final p = Paint()..color = Colors.black.withValues(alpha: 0.18);
        for (final dx in [0.18, 0.82]) {
          for (final dy in [0.12, 0.66]) {
            canvas.drawCircle(
              Offset(body.width * dx, body.height * dy),
              body.width * 0.04,
              p,
            );
          }
        }
      case Enhancement.crystal:
        final p = Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
          ..strokeWidth = body.width * 0.04;
        canvas.drawLine(
          Offset(body.width * 0.15, body.height * 0.3),
          Offset(body.width * 0.35, body.height * 0.1),
          p,
        );
      case Enhancement.skyStone:
        final p = Paint()..color = Palette.cream.withValues(alpha: 0.8);
        for (final o in const [
          Offset(0.15, 0.1),
          Offset(0.85, 0.2),
          Offset(0.12, 0.65),
          Offset(0.88, 0.7),
        ]) {
          canvas.drawCircle(
            Offset(body.width * o.dx, body.height * o.dy),
            body.width * 0.025,
            p,
          );
        }
      case Enhancement.bone:
        final p = Paint()
          ..color = Palette.creamEdge.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = body.width * 0.025;
        canvas.drawRRect(
          RRect.fromRectAndRadius(body.deflate(body.width * 0.1), radius),
          p,
        );
      case Enhancement.gold:
      case Enhancement.none:
        break;
    }
  }

  Color _bodyColor(Enhancement e) => switch (e) {
    Enhancement.none => Palette.cream,
    Enhancement.bone => Palette.bone,
    Enhancement.iron => Palette.iron,
    Enhancement.gold => Palette.goldTile,
    Enhancement.crystal => Palette.crystal,
    Enhancement.skyStone => Palette.skyStone,
  };

  @override
  bool shouldRepaint(TilePainter oldDelegate) => oldDelegate.look != look;
}
