import 'dart:math' as math;
import 'dart:ui';

import 'package:tengri_taslari/core/core.dart';

/// Code-drawn placeholder symbols. Each function draws into the square
/// [rect]. Final art will replace these (see `GameArt`).

/// Color symbol used for color-blind support:
/// red = sun, yellow = star, blue = moon, black = mountain.
void drawColorSymbol(Canvas canvas, TileColor color, Rect rect, Paint paint) {
  switch (color) {
    case TileColor.red:
      _sun(canvas, rect, paint);
    case TileColor.yellow:
      _star(canvas, rect, paint);
    case TileColor.blue:
      _moon(canvas, rect, paint);
    case TileColor.black:
      _mountain(canvas, rect, paint);
  }
}

void _sun(Canvas canvas, Rect r, Paint paint) {
  final c = r.center;
  final radius = r.shortestSide * 0.24;
  canvas.drawCircle(c, radius, paint);
  final ray = Paint()
    ..color = paint.color
    ..strokeWidth = r.shortestSide * 0.09
    ..strokeCap = StrokeCap.round;
  for (var i = 0; i < 8; i++) {
    final a = i * math.pi / 4;
    final d = Offset(math.cos(a), math.sin(a));
    canvas.drawLine(c + d * radius * 1.45, c + d * r.shortestSide * 0.48, ray);
  }
}

void _star(Canvas canvas, Rect r, Paint paint) {
  final c = r.center;
  final outer = r.shortestSide * 0.5;
  final inner = outer * 0.45;
  final path = Path();
  for (var i = 0; i < 10; i++) {
    final a = -math.pi / 2 + i * math.pi / 5;
    final rad = i.isEven ? outer : inner;
    final p = c + Offset(math.cos(a), math.sin(a)) * rad;
    i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
  }
  canvas.drawPath(path..close(), paint);
}

void _moon(Canvas canvas, Rect r, Paint paint) {
  final c = r.center;
  final radius = r.shortestSide * 0.45;
  final outer = Path()..addOval(Rect.fromCircle(center: c, radius: radius));
  final cut = Path()
    ..addOval(
      Rect.fromCircle(
        center: c + Offset(radius * 0.5, -radius * 0.2),
        radius: radius * 0.85,
      ),
    );
  canvas.drawPath(Path.combine(PathOperation.difference, outer, cut), paint);
}

void _mountain(Canvas canvas, Rect r, Paint paint) {
  final path = Path()
    ..moveTo(r.left, r.bottom - r.height * 0.1)
    ..lineTo(r.left + r.width * 0.38, r.top + r.height * 0.15)
    ..lineTo(r.left + r.width * 0.55, r.top + r.height * 0.42)
    ..lineTo(r.left + r.width * 0.7, r.top + r.height * 0.28)
    ..lineTo(r.right, r.bottom - r.height * 0.1)
    ..close();
  canvas.drawPath(path, paint);
}

/// Tamga-like seal marks (original, simple geometric strokes).
void drawSealMark(Canvas canvas, Seal seal, Rect r, Color color) {
  if (seal == Seal.none) return;
  final bg = Paint()..color = color;
  final rr = RRect.fromRectAndRadius(r, Radius.circular(r.width * 0.25));
  canvas.drawRRect(rr, bg);
  final s = Paint()
    ..color = const Color(0xFFF7F0DE)
    ..strokeWidth = r.width * 0.12
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final inset = r.deflate(r.width * 0.24);
  final path = Path();
  switch (seal) {
    case Seal.crimson: // fork mark
      path
        ..moveTo(inset.center.dx, inset.bottom)
        ..lineTo(inset.center.dx, inset.center.dy)
        ..lineTo(inset.left, inset.top)
        ..moveTo(inset.center.dx, inset.center.dy)
        ..lineTo(inset.right, inset.top);
    case Seal.gold: // circle with a bar
      path
        ..addOval(inset.deflate(inset.width * 0.1))
        ..moveTo(inset.center.dx, inset.top)
        ..lineTo(inset.center.dx, inset.bottom);
    case Seal.sky: // arrow up
      path
        ..moveTo(inset.center.dx, inset.bottom)
        ..lineTo(inset.center.dx, inset.top)
        ..moveTo(inset.left, inset.center.dy)
        ..lineTo(inset.center.dx, inset.top)
        ..lineTo(inset.right, inset.center.dy);
    case Seal.purple: // double hook
      path
        ..moveTo(inset.left, inset.top)
        ..lineTo(inset.left, inset.bottom)
        ..lineTo(inset.right, inset.bottom)
        ..moveTo(inset.right, inset.top)
        ..lineTo(inset.center.dx, inset.center.dy);
    case Seal.none:
      break;
  }
  canvas.drawPath(path, s);
}

/// Göktürk-rune inspired fake okey emblem.
void drawFakeOkeyEmblem(Canvas canvas, Rect r, Color color) {
  final p = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = r.width * 0.1
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final path = Path()
    ..moveTo(r.center.dx, r.top)
    ..lineTo(r.center.dx, r.bottom)
    ..moveTo(r.left, r.top + r.height * 0.2)
    ..lineTo(r.center.dx, r.center.dy)
    ..lineTo(r.right, r.top + r.height * 0.2)
    ..moveTo(r.left + r.width * 0.15, r.bottom)
    ..lineTo(r.right - r.width * 0.15, r.bottom);
  canvas.drawPath(path, p);
  canvas.drawCircle(r.center, r.width * 0.11, Paint()..color = color);
}

/// Simple geometric emblem for Kut cards, chosen by index.
void drawKutEmblem(Canvas canvas, int variant, Rect r, Color color) {
  final stroke = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = r.width * 0.07
    ..strokeJoin = StrokeJoin.round;
  final fill = Paint()..color = color;
  final c = r.center;
  final rad = r.shortestSide / 2;
  switch (variant % 6) {
    case 0: // ring with dot
      canvas.drawCircle(c, rad * 0.8, stroke);
      canvas.drawCircle(c, rad * 0.25, fill);
    case 1: // triangle (mountain)
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy - rad * 0.8)
          ..lineTo(c.dx + rad * 0.8, c.dy + rad * 0.6)
          ..lineTo(c.dx - rad * 0.8, c.dy + rad * 0.6)
          ..close(),
        stroke,
      );
    case 2: // diamond
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy - rad * 0.85)
          ..lineTo(c.dx + rad * 0.6, c.dy)
          ..lineTo(c.dx, c.dy + rad * 0.85)
          ..lineTo(c.dx - rad * 0.6, c.dy)
          ..close(),
        stroke,
      );
      canvas.drawCircle(c, rad * 0.15, fill);
    case 3: // eight-ray sun
      _sun(canvas, Rect.fromCircle(center: c, radius: rad * 0.9), fill);
    case 4: // crescent
      _moon(canvas, Rect.fromCircle(center: c, radius: rad * 0.9), fill);
    default: // hexagon
      final path = Path();
      for (var i = 0; i < 6; i++) {
        final a = math.pi / 6 + i * math.pi / 3;
        final p = c + Offset(math.cos(a), math.sin(a)) * rad * 0.8;
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path..close(), stroke);
  }
}
