import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../theme/abyss_base_badge_theme.dart';
import 'base_badge.dart';
import 'base_drawing.dart';
import 'base_label_text.dart';
import 'base_pad_tier.dart';

/// Draws the [BaseBadge] floating over a building of the base, in
/// projection units, as on the mockup: a glowing green chevron in a disc
/// for a building to raise, an orange triangle for a degraded one.
class BaseMarkerDrawer {
  static const _u = basePadUnit;

  /// Radius of the soft glow around a badge.
  static const glowRadius = 15 * _u;

  const BaseMarkerDrawer();

  /// The [badge] centred on [at].
  void draw(Canvas canvas, Offset at, BaseBadge badge) => switch (badge) {
        BaseBadge.upgrade => _upgrade(canvas, at),
        BaseBadge.warning => _warning(canvas, at),
      };

  void _upgrade(Canvas canvas, Offset at) {
    const green = AbyssBaseBadgeTheme.upgrade;
    _glow(canvas, at, green);
    canvas
      ..drawCircle(at, 8.5 * _u, Paint()..color = AbyssBaseBadgeTheme.upgradeFill)
      ..drawCircle(at, 8.5 * _u, _stroke(green, 1.6 * _u))
      ..drawPath(_chevron(at, 4, 2, -2.5), _stroke(green, 2.2 * _u))
      ..drawPath(_chevron(at, 3, 5, 2),
          _stroke(green.withValues(alpha: 0.5), 1.6 * _u));
  }

  void _warning(Canvas canvas, Offset at) {
    const orange = AbyssBaseBadgeTheme.warning;
    _glow(canvas, at, orange);
    final triangle = polygonOf([
      at.translate(0, -8.5 * _u),
      at.translate(9 * _u, 7 * _u),
      at.translate(-9 * _u, 7 * _u),
    ]);
    canvas
      ..drawPath(triangle, Paint()..color = AbyssBaseBadgeTheme.warningFill)
      ..drawPath(triangle, _stroke(orange, 1.6 * _u));
    paintCentredLabel(
        canvas,
        baseLabelOf('!', AbyssBaseBadgeTheme.warningMark, 11 * _u),
        at.translate(0, 1.5 * _u));
  }

  /// A chevron pointing up, [half] wide on each side, its arms at [arms]
  /// and its tip at [tip] below [at], in mockup units.
  static Path _chevron(Offset at, double half, double arms, double tip) =>
      Path()
        ..moveTo(at.dx - half * _u, at.dy + arms * _u)
        ..lineTo(at.dx, at.dy + tip * _u)
        ..lineTo(at.dx + half * _u, at.dy + arms * _u);

  static void _glow(Canvas canvas, Offset at, Color color) => canvas.drawCircle(
        at,
        glowRadius,
        Paint()
          ..shader = ui.Gradient.radial(at, glowRadius, [
            color.withValues(alpha: 0.7),
            color.withValues(alpha: 0),
          ]),
      );

  static Paint _stroke(Color color, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = color;
}
