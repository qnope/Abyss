import 'dart:ui';

import '../map/map_projection.dart';
import 'base_pad_geometry.dart';
import 'base_pad_tier.dart';
import 'base_slot.dart';
import 'base_slot_projection.dart';

/// Where the marks of a building float over the base, in projection
/// coordinates, as on the mockup.
extension BaseBadgeGeometry on BaseSlot {
  /// How far outside the footprint the guide's ring lies, in cells.
  static const ringOutset = 0.12;

  /// How far above the ground the « À bâtir » pill of a plot sits.
  static const pillRise = 4 * basePadUnit;

  /// The centre of the level plaque of a building at [level]: on the
  /// lower left of its sprite, on its ground; the « À bâtir » pill of a
  /// plot (level 0) at the centre of its ground.
  Offset plaqueAt(int level) {
    if (level <= 0) return foot.translate(0, -pillRise);
    final box = standingBoxOn(BasePadTier.ofLevel(level));
    return Offset(box.center.dx - 0.3 * box.width, foot.dy - 0.1 * box.width);
  }

  /// The centre of the chevron or the triangle floating over a building
  /// at [level]: on the upper right of its sprite.
  Offset badgeAt(int level) {
    final box = standingBoxOn(BasePadTier.ofLevel(level));
    return Offset(box.center.dx + 0.3 * box.width, box.top + 0.2 * box.width);
  }

  /// The box bounding the diamond of the guide's ring on the ground.
  Rect get ringBox {
    final side = footprint + 2 * ringOutset;
    return Rect.fromCenter(
      center: foot,
      width: side * MapProjection.tileWidth,
      height: side * MapProjection.tileHeight,
    );
  }

  /// The tips of the ring's diamond: top, right, bottom, left.
  List<Offset> get ringCorners => diamondCorners(ringBox);
}

/// The tips of the diamond drawn in [box]: top, right, bottom, left.
List<Offset> diamondCorners(Rect box) =>
    [box.topCenter, box.centerRight, box.bottomCenter, box.centerLeft];
