import 'dart:ui';

import '../map/map_cell_size.dart';
import '../map/map_projection.dart';
import 'base_slot.dart';

/// The projection point of the [ground] point of the base, counted in
/// cells: the base is laid on the map's isometric projection.
Offset baseGroundToProjection(Offset ground) =>
    MapProjection.toScreen(ground * cellSize);

/// The ground point of the base, in cells, under the projection [point].
Offset baseProjectionToGround(Offset point) =>
    MapProjection.toFlat(point) / cellSize;

/// Where a building of the base is drawn, in projection coordinates.
extension BaseSlotProjection on BaseSlot {
  /// Share of a footprint's width a plain building's sprite spans.
  static const spriteFill = 0.95;

  /// Width added to every sprite, as on the mockup (6 of its pixels).
  static const spriteMargin = MapProjection.tileWidth / 8;

  /// Height of a sprite's foot, from its top, as a share of its side:
  /// the cut-out buildings stand a little above their bottom edge.
  static const footRatio = 0.86;

  /// The projected centre of the footprint, where the building stands.
  Offset get foot => baseGroundToProjection(centre);

  /// The square box of the standing sprite, its foot on [foot].
  Rect get standingBox {
    final side =
        (footprint * MapProjection.tileWidth * spriteFill + spriteMargin) *
            scale;
    final foot = this.foot;
    return Rect.fromLTWH(
        foot.dx - side / 2, foot.dy - footRatio * side, side, side);
  }

  /// The box of the soft contact shadow laid flat under the building.
  Rect get shadowBox {
    final side = standingBox.width;
    final foot = this.foot;
    return Rect.fromCenter(
      center: foot.translate(0.05 * side, 0.02 * side),
      width: 0.84 * side,
      height: 0.34 * side,
    );
  }

  /// The box bounding the footprint's diamond on the screen.
  Rect get footprintBox => Rect.fromCenter(
        center: foot,
        width: footprint * MapProjection.tileWidth,
        height: footprint * MapProjection.tileHeight,
      );

  /// The footprint's diamond on the screen.
  Path get footprintDiamond {
    final box = footprintBox;
    return Path()
      ..moveTo(box.center.dx, box.top)
      ..lineTo(box.right, box.center.dy)
      ..lineTo(box.center.dx, box.bottom)
      ..lineTo(box.left, box.center.dy)
      ..close();
  }
}
