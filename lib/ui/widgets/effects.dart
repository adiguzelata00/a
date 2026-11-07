import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Formats numbers for the UI: integers without decimals, else up to 2.
String formatNum(num n) {
  if (n == n.roundToDouble()) return n.toInt().toString();
  final s = n.toStringAsFixed(2);
  return s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

/// Animated count-up from the previous value to [value].
class CountUpText extends StatelessWidget {
  const CountUpText({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 350),
  });

  final double value;
  final TextStyle style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, v, _) => Text(
        formatNum(
          value == value.roundToDouble() ? v.round() : (v * 100).round() / 100,
        ),
        style: style,
        maxLines: 1,
      ),
    );
  }
}

/// Plays a short "bounce" every time [trigger] changes (and is not null).
class Bounce extends StatelessWidget {
  const Bounce({
    super.key,
    required this.trigger,
    required this.child,
    this.scale = 1.22,
  });

  final Object? trigger;
  final Widget child;
  final double scale;

  @override
  Widget build(BuildContext context) {
    if (trigger == null) return child;
    return TweenAnimationBuilder<double>(
      key: ValueKey(trigger),
      tween: Tween(begin: 1, end: 0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      builder: (context, t, c) {
        // Up quickly, settle back.
        final s = 1 + (scale - 1) * math.sin(t * math.pi).clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, -8 * math.sin(t * math.pi)),
          child: Transform.scale(scale: s, child: c),
        );
      },
      child: child,
    );
  }
}

/// Short horizontal wobble (Kut card trigger) every time [trigger] changes.
class Wobble extends StatelessWidget {
  const Wobble({super.key, required this.trigger, required this.child});

  final Object? trigger;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (trigger == null) return child;
    return TweenAnimationBuilder<double>(
      key: ValueKey(trigger),
      tween: Tween(begin: 1, end: 0),
      duration: const Duration(milliseconds: 420),
      builder: (context, t, c) => Transform.rotate(
        angle: math.sin(t * math.pi * 6) * 0.12 * t,
        child: Transform.scale(scale: 1 + 0.12 * t, child: c),
      ),
      child: child,
    );
  }
}

/// Floating label ("+15", "×2 Çarpan") rising and fading above its parent.
class FloatingLabel extends StatelessWidget {
  const FloatingLabel({
    super.key,
    required this.trigger,
    required this.text,
    required this.color,
  });

  final Object trigger;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        key: ValueKey(trigger),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOut,
        builder: (context, t, _) => Opacity(
          opacity: (t < 0.7 ? 1.0 : 1 - (t - 0.7) / 0.3).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -28 * t),
            child: Transform.scale(
              scale: 0.7 + 0.5 * math.min(1, t * 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, blurRadius: 4),
                  ],
                ),
                child: Text(
                  text,
                  maxLines: 1,
                  softWrap: false,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shakes its child whenever [trigger] changes.
class ScreenShake extends StatefulWidget {
  const ScreenShake({super.key, required this.trigger, required this.child});

  final int trigger;
  final Widget child;

  @override
  State<ScreenShake> createState() => _ScreenShakeState();
}

class _ScreenShakeState extends State<ScreenShake>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void didUpdateWidget(ScreenShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        final amp = 7 * (1 - t);
        return Transform.translate(
          offset: _c.isAnimating
              ? Offset(
                  math.sin(t * math.pi * 10) * amp,
                  math.cos(t * math.pi * 7) * amp * 0.5,
                )
              : Offset.zero,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Plays a one-time drop-in animation when first built (new rack tiles).
class DropIn extends StatelessWidget {
  const DropIn({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutBack,
      builder: (context, t, c) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, -24 * (1 - t)), child: c),
      ),
      child: child,
    );
  }
}
