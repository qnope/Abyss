import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../../domain/building/building_type.dart';
import '../../extensions/building_type_extensions.dart';
import 'base_badge_geometry.dart';
import 'base_fit.dart';
import 'base_layout.dart';
import 'base_marker_drawer.dart';
import 'base_plaque_drawer.dart';
import 'base_snapshot.dart';

/// Paints the marks floating over the base's buildings, back to front:
/// the level plaque of each built one, in its colour, the « À bâtir »
/// pill of each plot, locked while a prerequisite is missing, the name of
/// the plot the guide points at, then the chevron of each building to
/// raise and the triangle of each degraded one.
///
/// Cheap and apart from the still island: repainted only when a level,
/// a mark or the guide changes.
class BaseBadgesPainter extends CustomPainter {
  final BaseLayout layout;
  final BaseFit fit;
  final BaseSnapshot snapshot;

  /// What a plot's pill says, « À bâtir ».
  final String toBuild;

  /// The building the guide points at, if any, and its [guidedName],
  /// written under its pill while it is still to build.
  final BuildingType? guided;
  final String? guidedName;

  static const _plaques = BasePlaqueDrawer();
  static const _markers = BaseMarkerDrawer();

  BaseBadgesPainter({
    required this.layout,
    required this.fit,
    required this.snapshot,
    required this.toBuild,
    this.guided,
    this.guidedName,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final base = snapshot;
    canvas.save();
    fit.apply(canvas);
    final order = [
      for (final type in layout.drawOrder)
        if (base.levels.containsKey(type)) type,
    ];
    for (final type in order) {
      final level = base.levels[type]!;
      final at = layout.slotOf(type).plaqueAt(level);
      if (level > 0) {
        _plaques.level(canvas, at, level, type.color);
        continue;
      }
      _plaques.toBuild(canvas, at, toBuild,
          locked: base.locked.contains(type));
      if (type == guided && guidedName != null) {
        _plaques.name(canvas, at, guidedName!);
      }
    }
    for (final type in order) {
      final badge = base.badgeOf(type);
      if (badge == null) continue;
      final at = layout.slotOf(type).badgeAt(base.levels[type]!);
      _markers.draw(canvas, at, badge);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(BaseBadgesPainter oldDelegate) {
    final was = oldDelegate.snapshot, now = snapshot;
    return oldDelegate.layout != layout ||
        oldDelegate.fit != fit ||
        oldDelegate.toBuild != toBuild ||
        oldDelegate.guided != guided ||
        oldDelegate.guidedName != guidedName ||
        !mapEquals(was.levels, now.levels) ||
        !setEquals(was.degraded, now.degraded) ||
        !setEquals(was.upgradable, now.upgradable) ||
        !setEquals(was.locked, now.locked);
  }

  @override
  bool? hitTest(Offset position) => false;
}
