import 'package:flutter/painting.dart';

import '../../../../theme/abyss_colors.dart';
import '../../../../theme/abyss_motion.dart';
import '../../../../theme/abyss_text_theme.dart';

/// Draws the marks of an attack on the map: the "×N" badge on the army's
/// token and the damage floating up from the lair.
class StrikeMarks {
  /// Radius of the badge.
  static const badgeRadius = 8.0;

  /// How far a damage number rises, in logical pixels.
  static const rise = 18.0;

  final _badge = Paint();
  final _badgeRing = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  /// Draws "×[count]" on the top right of [token], at [opacity].
  void badge(Canvas canvas, Rect token, int count, double opacity) {
    if (opacity <= 0) return;
    final center = token.topRight;
    _badge.color = AbyssColors.deepNavy.withValues(alpha: opacity);
    _badgeRing.color = AbyssColors.biolumCyan.withValues(alpha: opacity);
    canvas
      ..drawCircle(center, badgeRadius, _badge)
      ..drawCircle(center, badgeRadius, _badgeRing);
    _text(canvas, '×$count', center, 8,
        AbyssColors.pearlWhite.withValues(alpha: opacity));
  }

  /// Draws [damage] floating up from [from], [progress] of its way (0 to
  /// 1): it rises all along and fades over its second half.
  void damage(Canvas canvas, Offset from, int damage, double progress) {
    final rising = AbyssMotion.enter.transform(progress);
    final opacity = progress < 0.5 ? 1.0 : 2 - 2 * progress;
    _text(canvas, '−$damage', from - Offset(0, rise * rising), 13,
        AbyssColors.error.withValues(alpha: opacity));
  }

  static void _text(
      Canvas canvas, String text, Offset center, double size, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: AbyssTextTheme.mapMark.copyWith(fontSize: size, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, center - Offset(painter.width, painter.height) / 2);
    painter.dispose();
  }
}
