import 'dart:ui';

/// One decor standing on the floor of an isometric map, in projection
/// coordinates: a [sprite] of [size] standing on its [foot].
///
/// Decor is presentation only: never saved, never tapped, scattered
/// again from the cells each time the map is painted.
class MapDecor {
  /// Where the foot lies down the box, as a share of its side: every
  /// decor sprite stands on (32, 56) of its 64 × 64 frame.
  static const footRatio = 56 / 64;

  /// Share of the box's width left out on each side of its [body].
  static const _sideMargin = 0.15;

  /// Share of the box's height left out above its [body].
  static const _topMargin = 0.12;

  final String sprite;

  /// The point of the floor it stands on.
  final Offset foot;

  /// Side of its square box.
  final double size;

  /// Whether it stands among hidden cells, under the fog.
  final bool hidden;

  const MapDecor({
    required this.sprite,
    required this.foot,
    required this.size,
    this.hidden = false,
  });

  /// The square its sprite is drawn in, standing on its [foot].
  Rect get box => Rect.fromLTWH(
      foot.dx - size / 2, foot.dy - footRatio * size, size, size);

  /// The part of its [box] its art fills, kept out of the contents' way.
  Rect get body {
    final box = this.box;
    return Rect.fromLTRB(box.left + _sideMargin * size,
        box.top + _topMargin * size, box.right - _sideMargin * size,
        box.bottom);
  }

  @override
  bool operator ==(Object other) =>
      other is MapDecor &&
      other.sprite == sprite &&
      other.foot == foot &&
      other.size == size &&
      other.hidden == hidden;

  @override
  int get hashCode => Object.hash(sprite, foot, size, hidden);

  @override
  String toString() => 'MapDecor($sprite at $foot, $size'
      '${hidden ? ', hidden' : ''})';
}
