import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'map_decor.dart';

/// Draws decor standing on the floor, each over a small soft contact
/// shadow, as the contents stand over theirs: every shadow first, so
/// none falls on a decor, then every decor in the order given (back to
/// front, as [scatterDecor] lists them).
///
/// Knows nothing of the map: it takes the bitmap of each sprite from
/// [imageOf] and the shadow's from [shadow], drawn whole into their boxes.
/// Its paints are made once and reused for every decor it draws.
class MapDecorDrawer {
  /// Width of the shadow, as a share of the decor's box.
  static const shadowRatio = 0.7;

  /// How far the shadow falls to the lower right, away from the light
  /// coming from the upper left, as a share of the decor's box.
  static const shadowDrop = 0.06;

  /// The bitmap of a decor's sprite, or `null` while it is not loaded.
  final ui.Image? Function(String sprite) imageOf;

  /// The soft contact shadow, a disc drawn flattened on the floor.
  final ui.Image? shadow;

  final _image = Paint()..filterQuality = FilterQuality.medium;
  final _shadow = Paint()..filterQuality = FilterQuality.low;

  MapDecorDrawer({required this.imageOf, this.shadow});

  /// Draws [decor] on [canvas], in projection coordinates.
  void draw(Canvas canvas, Iterable<MapDecor> decor) {
    final shadow = this.shadow;
    if (shadow != null) {
      for (final item in decor) {
        _drawWhole(canvas, shadow, shadowOf(item), _shadow);
      }
    }
    for (final item in decor) {
      final image = imageOf(item.sprite);
      if (image != null) _drawWhole(canvas, image, item.box, _image);
    }
  }

  /// The box of the shadow of [decor], flattened on the floor at its foot.
  static Rect shadowOf(MapDecor decor) {
    final width = shadowRatio * decor.size;
    final drop = shadowDrop * decor.size;
    return Rect.fromCenter(
      center: decor.foot.translate(drop, drop / 2),
      width: width,
      height: width / 2,
    );
  }

  static void _drawWhole(Canvas canvas, ui.Image image, Rect dst, Paint p) {
    final src = Rect.fromLTWH(
        0, 0, image.width.toDouble(), image.height.toDouble());
    canvas.drawImageRect(image, src, dst, p);
  }
}
