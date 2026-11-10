import 'package:flutter/material.dart';
import 'package:tengri_taslari/core/core.dart';

import '../art/symbols.dart';
import '../l10n_ext.dart';
import '../theme/palette.dart';
import 'effects.dart';

Color rarityColor(Rarity r) => switch (r) {
  Rarity.common => Palette.gold,
  Rarity.rare => Palette.sealSky,
  Rarity.legendary => Palette.sealPurple,
};

/// Dark card with gold border, geometric emblem and name (placeholder art).
class KutCard extends StatelessWidget {
  const KutCard({
    super.key,
    required this.definition,
    required this.width,
    this.instance,
  });

  final KutDefinition definition;
  final KutInstance? instance;
  final double width;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final glow = rarityColor(definition.rarity);
    final badge = _stateBadge(instance);
    return Container(
      width: width,
      height: width * 1.3,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Palette.nightLighter, Palette.night],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Palette.gold, width: 1.5),
        boxShadow: [
          BoxShadow(color: glow.withValues(alpha: 0.4), blurRadius: 6),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _EmblemPainter(
                      fnv1a32(definition.id),
                      Palette.gold,
                    ),
                  ),
                ),
                if (badge != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Palette.multRed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            l10n.kutName(definition.id),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: width < 60 ? 8.5 : 10,
              height: 1.1,
              color: Palette.cream,
            ),
          ),
        ],
      ),
    );
  }

  /// Shows growing Kut state (Gök Börü ×2, Yada Taşı +3 ...).
  static String? _stateBadge(KutInstance? k) {
    if (k == null) return null;
    final x = k.state['xMult'];
    if (x != null && x != 1) return '×${formatNum(x)}';
    final m = k.state['mult'];
    if (m != null && m != 0) return '+${formatNum(m)}';
    return null;
  }
}

class _EmblemPainter extends CustomPainter {
  _EmblemPainter(this.variant, this.color);
  final int variant;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide * 0.8;
    drawKutEmblem(
      canvas,
      variant,
      Rect.fromCenter(
        center: size.center(Offset.zero),
        width: side,
        height: side,
      ),
      color,
    );
  }

  @override
  bool shouldRepaint(_EmblemPainter old) =>
      old.variant != variant || old.color != color;
}

/// Destan (parchment scroll) or Tılsım (charm) card.
class ConsumableCard extends StatelessWidget {
  const ConsumableCard({
    super.key,
    required this.item,
    required this.width,
    this.selected = false,
  });

  final ConsumableInstance item;
  final double width;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final isDestan = item.definition.kind == ConsumableKind.destan;
    final bg = isDestan
        ? const [Color(0xFFE9D8AE), Color(0xFFC9AE73)]
        : const [Color(0xFF1F5C5A), Color(0xFF0F2F33)];
    final fg = isDestan ? Palette.charcoal : Palette.cream;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: width,
      height: width * 1.3,
      transform: Matrix4.translationValues(0, selected ? -6 : 0, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: bg,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? Palette.cream : Palette.goldDark,
          width: selected ? 2.5 : 1.5,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _ItemPainter(
                isDestan: isDestan,
                color: isDestan ? Palette.goldDark : Palette.gold,
                tint: item.color == null
                    ? null
                    : Palette.tileColor(item.color!),
              ),
              child: const SizedBox.expand(),
            ),
          ),
          Text(
            context.l10n.consumableName(item),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: width < 60 ? 8 : 9.5,
              height: 1.1,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemPainter extends CustomPainter {
  _ItemPainter({required this.isDestan, required this.color, this.tint});
  final bool isDestan;
  final Color color;
  final Color? tint;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final s = size.shortestSide * 0.42;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.14
      ..strokeCap = StrokeCap.round;
    if (isDestan) {
      // Rolled scroll: body + two rods + text lines.
      final body = Rect.fromCenter(center: c, width: s * 1.5, height: s * 1.6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(body, Radius.circular(s * 0.1)),
        stroke,
      );
      canvas.drawLine(
        body.topLeft - Offset(s * 0.15, 0),
        body.topRight + Offset(s * 0.15, 0),
        stroke,
      );
      canvas.drawLine(
        body.bottomLeft - Offset(s * 0.15, 0),
        body.bottomRight + Offset(s * 0.15, 0),
        stroke,
      );
      final thin = Paint()
        ..color = color
        ..strokeWidth = s * 0.07;
      for (var i = 1; i <= 3; i++) {
        final y = body.top + body.height * i / 4;
        canvas.drawLine(
          Offset(body.left + s * 0.25, y),
          Offset(body.right - s * 0.25, y),
          thin,
        );
      }
    } else {
      // Charm: circle, inner eye, hanging cord.
      canvas.drawCircle(c, s * 0.8, stroke);
      canvas.drawCircle(c, s * 0.35, Paint()..color = tint ?? color);
      canvas.drawLine(c - Offset(0, s * 0.8), c - Offset(0, s * 1.15), stroke);
    }
  }

  @override
  bool shouldRepaint(_ItemPainter old) =>
      old.isDestan != isDestan || old.color != color || old.tint != tint;
}

/// Empty slot placeholder.
class EmptySlot extends StatelessWidget {
  const EmptySlot({super.key, required this.width, required this.label});
  final double width;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: width * 1.3,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Palette.goldDark.withValues(alpha: 0.5)),
      color: Colors.black.withValues(alpha: 0.15),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 10, color: Palette.textMuted),
    ),
  );
}

/// Akçe amount with a coin.
class MoneyText extends StatelessWidget {
  const MoneyText(this.amount, {super.key, this.size = 16});
  final int amount;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: size * 0.9,
        height: size * 0.9,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Palette.gold,
          border: Border.all(color: Palette.goldDark, width: 1.5),
        ),
      ),
      const SizedBox(width: 4),
      CountUpText(
        value: amount.toDouble(),
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w800,
          color: Palette.gold,
        ),
      ),
    ],
  );
}
