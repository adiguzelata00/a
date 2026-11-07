import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Background per world: Yeraltı (dark purple-crimson), Yeryüzü (steppe
/// green and earth), Gökyüzü (navy and gold, starry).
class WorldBackground extends StatelessWidget {
  const WorldBackground({super.key, required this.world, required this.child});

  /// 0 underworld, 1 middle world, 2 sky.
  final int world;
  final Widget child;

  static List<Color> colorsFor(int world) => switch (world) {
    0 => const [Palette.underworldTop, Palette.night, Palette.underworldBottom],
    1 => const [Palette.steppeTop, Palette.night, Palette.steppeBottom],
    _ => const [Palette.skyTop, Palette.night, Palette.skyBottom],
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colorsFor(world),
        ),
      ),
      child: Stack(
        children: [
          if (world == 2)
            const Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(painter: _StarsPainter(seed: 7)),
                ),
              ),
            ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

/// Static star field (deterministic).
class _StarsPainter extends CustomPainter {
  const _StarsPainter({required this.seed});
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    final p = Paint();
    for (var i = 0; i < 70; i++) {
      final o = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height * 0.7,
      );
      p.color = Palette.gold.withValues(alpha: 0.25 + rnd.nextDouble() * 0.5);
      canvas.drawCircle(o, 0.6 + rnd.nextDouble() * 1.2, p);
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.seed != seed;
}
