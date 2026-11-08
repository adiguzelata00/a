import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tengri_taslari/core/core.dart';

import '../game/game_controller.dart';
import '../l10n_ext.dart';
import '../theme/app_theme.dart';
import '../theme/palette.dart';
import 'collection_screen.dart';
import 'settings_screen.dart';

/// Main menu: slowly turning starry sky and a Göktürk-style motif ring.
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // A run that is not over can be continued (also after an app restart).
    final saved = ref.watch(
      gameControllerProvider.select((s) {
        final r = s.run;
        if (r == null || r.phase == RunPhase.lost) return null;
        return (floor: r.floor, money: r.money);
      }),
    );
    final hasRun = saved != null;
    final controller = ref.read(gameControllerProvider.notifier);

    Future<void> startNew() async {
      if (hasRun) {
        final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Palette.night,
            title: Text(l10n.newRunConfirmTitle),
            content: Text(l10n.newRunConfirmBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                key: const Key('confirm-new-run'),
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.confirmNewRun),
              ),
            ],
          ),
        );
        if (ok != true) return;
      }
      controller.newRun();
    }

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _TurningSky()),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: Palette.gold,
                        height: 1.05,
                        shadows: [Shadow(color: Colors.black, blurRadius: 12)],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.menuSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Palette.cream,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (hasRun) ...[
                      _MenuButton(
                        key: const Key('menu-continue'),
                        label: l10n.menuContinue,
                        primary: true,
                        onPressed: controller.resume,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.savedRunInfo(saved.floor, saved.money),
                        style: const TextStyle(color: Palette.textMuted),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _MenuButton(
                      key: const Key('menu-new-run'),
                      label: l10n.menuNewRun,
                      primary: !hasRun,
                      onPressed: startNew,
                    ),
                    const SizedBox(height: 12),
                    _MenuButton(
                      key: const Key('menu-collection'),
                      label: l10n.menuCollection,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CollectionScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MenuButton(
                      key: const Key('menu-settings'),
                      label: l10n.menuSettings,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: primary ? Palette.gold : Palette.nightLighter,
          foregroundColor: primary ? Palette.night : Palette.cream,
          disabledBackgroundColor: Palette.nightLight.withValues(alpha: 0.6),
          disabledForegroundColor: Palette.textMuted,
          side: const BorderSide(color: Palette.goldDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: appFontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, maxLines: 1),
        ),
      ),
    );
  }
}

class _TurningSky extends StatefulWidget {
  const _TurningSky();

  @override
  State<_TurningSky> createState() => _TurningSkyState();
}

class _TurningSkyState extends State<_TurningSky>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 120),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect the system "reduce motion" setting.
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(painter: _SkyPainter(_c.value)),
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  _SkyPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -0.2),
          radius: 1.1,
          colors: [Palette.skyTop, Palette.night],
        ).createShader(rect),
    );
    final center = Offset(size.width / 2, size.height * 0.42);
    final maxR = size.longestSide * 0.75;

    // Stars turning around the pole star.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(t * 2 * math.pi);
    final rnd = math.Random(42);
    final star = Paint();
    for (var i = 0; i < 160; i++) {
      final r = math.sqrt(rnd.nextDouble()) * maxR;
      final a = rnd.nextDouble() * 2 * math.pi;
      star.color = Palette.cream.withValues(
        alpha: 0.2 + rnd.nextDouble() * 0.6,
      );
      canvas.drawCircle(
        Offset(math.cos(a) * r, math.sin(a) * r),
        0.5 + rnd.nextDouble() * 1.3,
        star,
      );
    }
    canvas.restore();

    // Motif ring: rune-like ticks turning the other way.
    final ringR = size.shortestSide * 0.42;
    final ring = Paint()
      ..color = Palette.gold.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, ringR, ring);
    canvas.drawCircle(center, ringR * 0.86, ring);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-t * 2 * math.pi * 2);
    final tick = Paint()
      ..color = Palette.gold.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 24; i++) {
      final a = i * math.pi / 12;
      final dir = Offset(math.cos(a), math.sin(a));
      final inner = dir * ringR * 0.88;
      final outer = dir * ringR * 0.98;
      canvas.drawLine(inner, outer, tick);
      if (i.isEven) {
        // Small fork mark (tamga-like) between the circles.
        final side = Offset(-dir.dy, dir.dx) * ringR * 0.03;
        canvas.drawLine(outer, inner + side, tick);
        canvas.drawLine(outer, inner - side, tick);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SkyPainter old) => old.t != t;
}
