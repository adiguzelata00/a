import 'package:flutter/material.dart';

import '../../l10n_ext.dart';
import '../../theme/palette.dart';

/// Full-screen boss announcement at the start of a boss round: name scales
/// in, restriction shown, then fades out (tap to dismiss early).
class BossIntro extends StatefulWidget {
  const BossIntro({super.key, required this.bossId});

  final String bossId;

  @override
  State<BossIntro> createState() => _BossIntroState();
}

class _BossIntroState extends State<BossIntro>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void initState() {
    super.initState();
    _c.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) _c.value = 1;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        if (t >= 1) return const SizedBox.shrink();
        // 0-15% in, 15-75% hold, 75-100% out.
        final opacity = t < 0.15
            ? t / 0.15
            : (t > 0.75 ? (1 - (t - 0.75) / 0.25) : 1.0);
        final scale = t < 0.15
            ? 0.6 + 0.4 * Curves.easeOutBack.transform(t / 0.15)
            : 1.0 + 0.04 * (t - 0.15);
        return GestureDetector(
          key: const Key('boss-intro'),
          behavior: HitTestBehavior.opaque,
          onTap: () => _c.value = 1,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.72),
              child: Center(
                child: Transform.scale(
                  scale: scale,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.roundBoss.toUpperCase(),
                          style: const TextStyle(
                            letterSpacing: 4,
                            color: Palette.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.bossName(widget.bossId),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: Palette.multRed,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 16),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.bossDescription(widget.bossId),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Palette.cream,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
