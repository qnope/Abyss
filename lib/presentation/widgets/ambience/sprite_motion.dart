import 'package:flutter/foundation.dart';

import 'package:flutter/rendering.dart';

/// The point a sprite turns and grows around.
enum SpritePivot {
  /// Its centre: a creature drifting in open water.
  center,

  /// The middle of its bottom edge: something anchored to the seabed.
  bottom,
}

/// The pose of a sprite at one instant of an ambient motion.
///
/// Only transforms and an opacity factor: painters apply it to bitmaps
/// already rasterized, never to their drawing.
@immutable
class SpriteMotion {
  /// Vertical offset as a fraction of the sprite's height, down positive.
  final double dy;

  /// Size factor, 1 being the sprite's own size.
  final double scale;

  /// Angle in radians, clockwise, around [pivot].
  final double rotation;

  /// Opacity of the sprite's glow, from 0 (none) to 1.
  final double glow;

  final SpritePivot pivot;

  /// The sprite at rest, without any glow.
  static const rest = SpriteMotion();

  const SpriteMotion({
    this.dy = 0,
    this.scale = 1,
    this.rotation = 0,
    this.glow = 0,
    this.pivot = SpritePivot.center,
  });

  /// Whether the sprite stands exactly as drawn.
  bool get isRest => dy == 0 && scale == 1 && rotation == 0;

  /// The transform that moves a sprite drawn in [rect] into this pose.
  Matrix4 matrixFor(Rect rect) {
    final origin = switch (pivot) {
      SpritePivot.center => rect.center,
      SpritePivot.bottom => rect.bottomCenter,
    };
    return Matrix4.translationValues(origin.dx, origin.dy + dy * rect.height, 0)
      ..rotateZ(rotation)
      ..scaleByDouble(scale, scale, 1, 1)
      ..translateByDouble(-origin.dx, -origin.dy, 0, 1);
  }

  /// Applies this pose to [canvas] around [rect], runs [draw], which
  /// paints the sprite at [rect], then restores the canvas.
  void paint(Canvas canvas, Rect rect, VoidCallback draw) {
    if (isRest) return draw();
    canvas
      ..save()
      ..transform(matrixFor(rect).storage);
    draw();
    canvas.restore();
  }

  @override
  bool operator ==(Object other) =>
      other is SpriteMotion &&
      other.dy == dy &&
      other.scale == scale &&
      other.rotation == rotation &&
      other.glow == glow &&
      other.pivot == pivot;

  @override
  int get hashCode => Object.hash(dy, scale, rotation, glow, pivot);

  @override
  String toString() =>
      'SpriteMotion(dy: $dy, scale: $scale, rotation: $rotation, '
      'glow: $glow, pivot: ${pivot.name})';
}
