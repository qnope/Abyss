import 'dart:math';

import 'package:flutter/painting.dart';

import '../../theme/abyss_base_badge_theme.dart';
import 'base_drawing.dart';
import 'base_label_text.dart';
import 'base_pad_tier.dart';

/// Draws what lies at the foot of a building of the base (or a squad of
/// the army), in projection units, as on the mockup: the hexagonal plaque
/// of its level, the dashed « À bâtir » pill of a plot, locked while it
/// cannot be built, and the name of the building the guide points at.
class BasePlaqueDrawer {
  static const _u = basePadUnit;

  /// Radius of the level's hexagon.
  static const plaqueRadius = 9 * _u;

  /// Height of the « À bâtir » pill, and its smallest width.
  static const pillHeight = 15 * _u;
  static const pillMinWidth = 52 * _u;

  /// How far under the pill's centre the guided name sits.
  static const nameDrop = 16 * _u;

  const BasePlaqueDrawer();

  /// The hexagon of [level] centred on [at], edged in [color].
  void level(Canvas canvas, Offset at, int level, Color color) {
    final outline = _hexagon(at, plaqueRadius);
    final box = Rect.fromCircle(center: at, radius: plaqueRadius);
    canvas
      ..drawPath(
          outline,
          verticalGradient(box, const [
            AbyssBaseBadgeTheme.plaqueTop,
            AbyssBaseBadgeTheme.plaqueBottom,
          ], const [0, 1]))
      ..drawPath(outline, _stroke(color, 1.6 * _u))
      ..drawPath(_hexagon(at, 0.78 * plaqueRadius),
          _stroke(AbyssBaseBadgeTheme.plaqueSheen, 0.6 * _u));
    paintCentredLabel(canvas,
        baseLabelOf('$level', AbyssBaseBadgeTheme.level, 13 * _u), at);
  }

  /// The pill saying [label] centred on [at], a lock before it while
  /// [locked].
  void toBuild(Canvas canvas, Offset at, String label,
          {required bool locked}) =>
      _dashedPill(canvas, at, _pillText(label.toUpperCase()), locked: locked);

  /// The pill of a locked place saying [label] as is, centred on [at].
  void lockedPill(Canvas canvas, Offset at, String label) =>
      _dashedPill(canvas, at, _pillText(label), locked: true);

  /// The dashed pill holding [text] centred on [at], [locked] or not.
  void _dashedPill(Canvas canvas, Offset at, TextPainter text,
      {required bool locked}) {
    final lock = locked ? 9 * _u : 0.0;
    final content = lock + text.width;
    final pill = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: at,
        width: max(pillMinWidth, content + 16 * _u),
        height: pillHeight,
      ),
      const Radius.circular(pillHeight / 2),
    );
    canvas
      ..drawRRect(pill, Paint()..color = AbyssBaseBadgeTheme.pillFill)
      ..drawPath(dashedPathOf(Path()..addRRect(pill), 3 * _u, 2 * _u),
          _stroke(AbyssBaseBadgeTheme.pillEdge, 0.9 * _u));
    final left = at.dx - content / 2;
    if (locked) _lock(canvas, Offset(left + 3 * _u, at.dy));
    paintLabel(canvas, text, left: left + lock, middle: at.dy);
  }

  /// Width of the pill [lockedPill] draws saying [label].
  double lockedPillWidth(String label) =>
      max(pillMinWidth, _widthOf(_pillText(label)) + 25 * _u);

  /// Width of the band [name] draws under a pill, saying [name].
  double nameWidth(String name) =>
      _widthOf(baseLabelOf(name, AbyssBaseBadgeTheme.name, 10 * _u)) + 12 * _u;

  static TextPainter _pillText(String label) =>
      baseLabelOf(label, AbyssBaseBadgeTheme.toBuild, 10 * _u);

  /// The width of [text], disposed of.
  static double _widthOf(TextPainter text) {
    final width = text.width;
    text.dispose();
    return width;
  }

  /// The [name] of the building under its pill centred on [at], in
  /// [colour].
  void name(Canvas canvas, Offset at, String name,
      {Color colour = AbyssBaseBadgeTheme.nameText}) {
    final text = baseLabelOf(
        name, AbyssBaseBadgeTheme.name.copyWith(color: colour), 10 * _u);
    final centre = at.translate(0, nameDrop);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: centre, width: text.width + 12 * _u, height: 13 * _u),
        const Radius.circular(4 * _u),
      ),
      Paint()..color = AbyssBaseBadgeTheme.nameFill,
    );
    paintCentredLabel(canvas, text, centre);
  }

  /// A small padlock centred on [at].
  static void _lock(Canvas canvas, Offset at) {
    const colour = AbyssBaseBadgeTheme.lock;
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(at.dx - 3 * _u, at.dy - 1 * _u, at.dx + 3 * _u,
              at.dy + 4 * _u),
          const Radius.circular(0.8 * _u),
        ),
        Paint()..color = colour,
      )
      ..drawPath(
        Path()
          ..moveTo(at.dx - 2 * _u, at.dy - 0.5 * _u)
          ..lineTo(at.dx - 2 * _u, at.dy - 2 * _u)
          ..arcToPoint(Offset(at.dx + 2 * _u, at.dy - 2 * _u),
              radius: const Radius.circular(2 * _u))
          ..lineTo(at.dx + 2 * _u, at.dy - 0.5 * _u),
        _stroke(colour, 1.2 * _u),
      );
  }

  /// A hexagon standing on a tip, of [radius] around [centre].
  static Path _hexagon(Offset centre, double radius) => polygonOf([
        for (var k = 0; k < 6; k++)
          centre +
              Offset.fromDirection(-pi / 2 + k * pi / 3, radius),
      ]);

  static Paint _stroke(Color color, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeJoin = StrokeJoin.round
    ..color = color;
}
