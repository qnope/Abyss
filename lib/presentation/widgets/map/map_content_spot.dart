import 'dart:ui';

import 'map_cell_visual.dart';
import 'map_projection.dart';

/// Where the content of one cell is drawn, in projection coordinates:
/// standing in its [area], its glow, shadow and ring lying on the floor.
///
/// Every box is computed once, so a painter keeping its spots draws
/// frame after frame without allocating any.
class MapContentSpot {
  /// Width of the pool of light a glow casts, as a share of the floor's.
  static const glowRatio = 1.5;

  /// Width of a faction's ring around its base, as a share of the
  /// floor's.
  static const ringRatio = 0.8;

  /// Width of the contact shadow, as a share of the floor's.
  static const shadowRatio = 0.8;

  /// How far the shadow falls to the lower right, away from the light
  /// coming from the upper left, as a share of the floor's height.
  static const shadowDrop = 0.2;

  /// Margin kept around everything drawn for the content to move in, as
  /// a share of its area's width.
  static const motionMargin = 0.1;

  /// Index of the cell in the map's visuals.
  final int index;

  /// The box the content stands in.
  final Rect area;

  /// The pool of light of its glow, flattened on the floor.
  final Rect glow;

  /// Its soft contact shadow, flattened on the floor.
  final Rect shadow;

  /// The faction ring around it, flattened on the floor.
  final Rect ring;

  /// Everything drawn for it, moving included: what culling tests.
  final Rect bounds;

  const MapContentSpot._(
      this.index, this.area, this.glow, this.shadow, this.ring, this.bounds);

  /// The spot of [visual] at [index] on a map [columns] cells wide: on
  /// its cell, or on the block a wide content (the volcano) covers.
  factory MapContentSpot.of(MapCellVisual visual, int index, int columns) {
    final cell = (index % columns, index ~/ columns);
    final span = visual.contentSpan;
    final area = MapProjection.standingOf(cell, span: span);
    final floor = MapProjection.floorOf(cell, span: span);
    final glow = _onFloor(floor.center, floor.width * glowRatio);
    final ring = _onFloor(floor.center, floor.width * ringRatio);
    final drop = shadowDrop * floor.height;
    final shadow = _onFloor(
        floor.center.translate(drop, drop), floor.width * shadowRatio);
    final bounds = area
        .inflate(motionMargin * area.width)
        .expandToInclude(glow)
        .expandToInclude(shadow)
        .expandToInclude(ring);
    return MapContentSpot._(index, area, glow, shadow, ring, bounds);
  }

  /// A flattened box of [width] lying on the floor around [centre].
  static Rect _onFloor(Offset centre, double width) =>
      Rect.fromCenter(center: centre, width: width, height: width / 2);
}
