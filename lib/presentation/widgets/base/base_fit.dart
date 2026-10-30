import 'dart:math';
import 'dart:ui';

import '../map/map_projection.dart';
import 'base_layout.dart';
import 'base_slot_projection.dart';

/// How the projected base fits a view, with no pan nor zoom: every
/// footprint across its width (the plateau's corners may be cropped), the
/// tallest building under the badges at the top and the slab above its
/// bottom. A view = [origin] + projection point × [zoom].
class BaseFit {
  /// Height kept at the top of the view for the badges.
  static const badgeSpace = 52.0;

  /// Thickness of the plateau's slab under its front edges, in
  /// projection units.
  static const slabDepth = 1.05 * MapProjection.tileWidth;

  /// Share of the room left over that goes above the base, the rest
  /// showing the spire below it.
  static const headroomShare = 0.25;

  /// The smallest zoom, so that a view too small still converts points.
  static const minZoom = 0.01;

  /// Screen pixels per projection unit.
  final double zoom;

  /// Where the projection's origin lies in the view.
  final Offset origin;

  const BaseFit({required this.zoom, required this.origin});

  /// The fit of [layout] in a [view].
  factory BaseFit.of(Size view, BaseLayout layout) {
    final half = layout.size / 2;
    final centre = baseGroundToProjection(Offset(half, half));
    var reach = 0.0, top = 0.0;
    for (final slot in layout.slots.values) {
      final box = slot.footprintBox;
      reach = max(reach, max(centre.dx - box.left, box.right - centre.dx));
      top = min(top, slot.standingBox.top);
    }
    final edge = layout.size.toDouble();
    // An island with no slot (yet) fits its whole plateau.
    if (reach == 0) reach = edge * MapProjection.tileWidth / 2;
    final bottom = baseGroundToProjection(Offset(edge, edge)).dy + slabDepth;
    final height = bottom - top;
    final room = view.height - badgeSpace;
    final zoom = max(minZoom, min(view.width / 2 / reach, room / height));
    final free = max(0.0, room - height * zoom);
    return BaseFit(
      zoom: zoom,
      origin: Offset(
        view.width / 2 - centre.dx * zoom,
        badgeSpace + free * headroomShare - top * zoom,
      ),
    );
  }

  /// Width of a cell's diamond on the screen.
  double get tileWidth => MapProjection.tileWidth * zoom;

  /// The view point of the projection [point].
  Offset toView(Offset point) => origin + point * zoom;

  /// The projection point under the view [point].
  Offset toProjection(Offset point) => (point - origin) / zoom;

  /// Moves a canvas painted in view coordinates to projection ones.
  void apply(Canvas canvas) => canvas
    ..translate(origin.dx, origin.dy)
    ..scale(zoom);

  @override
  bool operator ==(Object other) =>
      other is BaseFit && other.zoom == zoom && other.origin == origin;

  @override
  int get hashCode => Object.hash(zoom, origin);
}
