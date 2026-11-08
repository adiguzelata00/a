import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Burst of sparks drawn over [child] every time [trigger] changes
/// (or once on first build when [burstOnStart] is set).
///
/// Cheap: one CustomPainter, no widgets per particle, so it stays at 60 FPS
/// on low-end phones. Respects the system "reduce motion" setting.
class ParticleBurst extends StatefulWidget {
  const ParticleBurst({
    super.key,
    required this.trigger,
    required this.child,
    this.count = 28,
    this.colors = const [Palette.gold, Palette.cream, Palette.mustard],
    this.burstOnStart = false,
    this.spread = 160,
  });

  final Object? trigger;
  final Widget child;
  final int count;
  final List<Color> colors;
  final bool burstOnStart;

  /// Roughly how far sparks fly (logical pixels).
  final double spread;

  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _Particle {
  _Particle(this.velocity, this.size, this.color, this.spin);
  final Offset velocity;
  final double size;
  final Color color;
  final double spin;
}

class _ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  List<_Particle> _particles = const [];

  @override
  void initState() {
    super.initState();
    if (widget.burstOnStart && widget.trigger != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _burst();
      });
    }
  }

  @override
  void didUpdateWidget(ParticleBurst old) {
    super.didUpdateWidget(old);
    if (widget.trigger != null && widget.trigger != old.trigger) _burst();
  }

  void _burst() {
    if (MediaQuery.disableAnimationsOf(context)) return;
    final rnd = math.Random(widget.trigger.hashCode);
    _particles = [
      for (var i = 0; i < widget.count; i++)
        _Particle(
          Offset.fromDirection(
            -math.pi / 2 + (rnd.nextDouble() - 0.5) * math.pi * 1.6,
            widget.spread * (0.4 + rnd.nextDouble() * 0.8),
          ),
          2 + rnd.nextDouble() * 3.5,
          widget.colors[rnd.nextInt(widget.colors.length)],
          rnd.nextDouble() * 6,
        ),
    ];
    _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) => _c.isAnimating
                  ? CustomPaint(painter: _SparkPainter(_particles, _c.value))
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.particles, this.t);
  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = size.center(Offset.zero);
    final ease = Curves.easeOutCubic.transform(t);
    final gravity = Offset(0, 140 * t * t);
    final alpha = (1 - t).clamp(0.0, 1.0);
    final paint = Paint();
    for (final p in particles) {
      final pos = origin + p.velocity * ease + gravity;
      paint.color = p.color.withValues(alpha: alpha);
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin * t);
      // Diamond-shaped spark.
      final s = p.size * (1 - 0.4 * t);
      canvas.drawPath(
        Path()
          ..moveTo(0, -s * 1.4)
          ..lineTo(s * 0.7, 0)
          ..lineTo(0, s * 1.4)
          ..lineTo(-s * 0.7, 0)
          ..close(),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.t != t;
}
