import 'dart:ui';

/// The fixed place of a building on the base, in ground coordinates
/// counted in cells: the centre ([u], [v]) of its square [footprint]
/// and the [scale] of its illustration.
class BaseSlot {
  final double u;
  final double v;

  /// The side of the square footprint, in cells.
  final int footprint;

  /// The size of the illustration relative to a plain building.
  final double scale;

  const BaseSlot({
    required this.u,
    required this.v,
    required this.footprint,
    required this.scale,
  });

  /// The centre of the footprint on the ground.
  Offset get centre => Offset(u, v);

  /// The footprint on the ground, in cells.
  Rect get bounds => Rect.fromCenter(
      center: centre, width: footprint.toDouble(), height: footprint.toDouble());

  /// Whether the ground [point] lies inside the footprint, its far edges
  /// excluded, so a point on an edge two slots share belongs to only one.
  bool contains(Offset point) => bounds.contains(point);

  /// The sort key from the back (low) to the front (high) of the base.
  double get depth => u + v + footprint / 2;

  @override
  bool operator ==(Object other) =>
      other is BaseSlot &&
      other.u == u &&
      other.v == v &&
      other.footprint == footprint &&
      other.scale == scale;

  @override
  int get hashCode => Object.hash(u, v, footprint, scale);

  @override
  String toString() => 'BaseSlot($u, $v, $footprint, $scale)';
}
