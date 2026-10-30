import 'dart:math';

import 'package:flutter/painting.dart';

import '../../theme/abyss_base_badge_theme.dart';
import '../../theme/abyss_colors.dart';
import '../base/base_badge.dart';
import '../base/base_drawing.dart';
import '../base/base_label_text.dart';
import '../base/base_marker_drawer.dart';
import '../base/base_pad_tier.dart';
import '../base/base_plaque_drawer.dart';
import 'army_plaque.dart';

const _u = basePadUnit;

/// Draws, in projection units, the [ArmyPlaque] of a squad as on the
/// mockup: a pill « × 22 » edged in the squad's colour (dimmed while it
/// is empty), the base's dashed pill with a lock while it is locked, its
/// name below as under a building of the base, and the green « + » right
/// of the count when it can recruit. Moved along the width when needed,
/// so that a plaque never leaves the view (see [placed]).
class ArmyPlaqueDrawer {
  static const _plaques = BasePlaqueDrawer();
  static const _markers = BaseMarkerDrawer();
  static const _fill = [
    AbyssBaseBadgeTheme.plaqueTop,
    AbyssBaseBadgeTheme.plaqueBottom,
  ];

  /// Height of the count's pill.
  static const pillHeight = 18 * _u;

  /// Radius of the recruit badge's disc, and how far right of the count's
  /// pill its centre lies.
  static const badgeRadius = BaseMarkerDrawer.discRadius;
  static const badgeGap = 11 * _u;

  /// Room kept between a plaque and the side of the view.
  static const margin = 4 * _u;

  const ArmyPlaqueDrawer();

  /// How far [plaque] reaches left and right of its centre: its pill, its
  /// name and its recruit badge.
  (double, double) reach(ArmyPlaque plaque) {
    final pill = _pillWidth(plaque) / 2;
    final side = max(pill, _plaques.nameWidth(plaque.name) / 2);
    final badge = plaque.recruitable ? pill + badgeGap + badgeRadius : 0.0;
    return (side, max(side, badge));
  }

  /// The centre of [plaque] at [at], moved along the width the least for
  /// it to lie between [left] and [right], its left side first.
  Offset placed(
    Offset at,
    ArmyPlaque plaque, {
    required double left,
    required double right,
  }) {
    final (before, after) = reach(plaque);
    final low = left + margin + before;
    final high = max(low, right - margin - after);
    return Offset(at.dx.clamp(low, high), at.dy);
  }

  /// The centre of the recruit badge of [plaque] centred on [at].
  Offset badgeAt(Offset at, ArmyPlaque plaque) =>
      at.translate(_pillWidth(plaque) / 2 + badgeGap, 0);

  /// Draws [plaque] centred on [at].
  void paint(Canvas canvas, Offset at, ArmyPlaque plaque) {
    final lock = plaque.lock;
    if (lock != null) {
      _plaques.lockedPill(canvas, at, lock);
    } else {
      _count(canvas, at, plaque);
    }
    _plaques.name(
      canvas,
      at,
      plaque.name,
      colour: lock == null ? plaque.colour : AbyssBaseBadgeTheme.nameText,
    );
    if (plaque.recruitable) {
      _markers.draw(canvas, badgeAt(at, plaque), BaseBadge.recruit);
    }
  }

  void _count(Canvas canvas, Offset at, ArmyPlaque plaque) {
    final (times, number) = _countTexts(plaque);
    final width = _countWidth(times, number);
    final pill = RRect.fromRectAndRadius(
      Rect.fromCenter(center: at, width: width, height: pillHeight),
      const Radius.circular(pillHeight / 2),
    );
    final edge = plaque.colour.withValues(alpha: plaque.isEmpty ? .45 : 1);
    canvas
      ..drawRRect(pill, verticalGradient(pill.outerRect, _fill, const [0, 1]))
      ..drawRRect(
        pill,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * _u
          ..color = edge,
      );
    final left = at.dx - width / 2 + 8 * _u;
    final numberLeft = left + times.width + 2 * _u;
    paintLabel(canvas, times, left: left, middle: at.dy);
    paintLabel(canvas, number, left: numberLeft, middle: at.dy);
  }

  /// The « × » in the squad's colour and the count in white, both dimmed
  /// while the squad is empty; the caller disposes of them.
  static (TextPainter, TextPainter) _countTexts(ArmyPlaque plaque) {
    const style = AbyssBaseBadgeTheme.level;
    final empty = plaque.isEmpty;
    return (
      baseLabelOf(
        '×',
        style.copyWith(color: plaque.colour.withValues(alpha: empty ? .6 : 1)),
        11 * _u,
      ),
      baseLabelOf(
        plaque.count ?? '',
        style.copyWith(color: empty ? AbyssColors.onSurfaceDim : null),
        14 * _u,
      ),
    );
  }

  static double _countWidth(TextPainter times, TextPainter number) =>
      times.width + 2 * _u + number.width + 16 * _u;

  /// Width of the pill of [plaque], its count's or its lock's.
  static double _pillWidth(ArmyPlaque plaque) {
    final lock = plaque.lock;
    if (lock != null) return _plaques.lockedPillWidth(lock);
    final (times, number) = _countTexts(plaque);
    final width = _countWidth(times, number);
    times.dispose();
    number.dispose();
    return width;
  }
}
