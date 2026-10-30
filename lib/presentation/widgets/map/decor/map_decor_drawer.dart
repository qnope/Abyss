import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../common/atlas_mesh.dart';
import '../../common/sprite_atlas.dart';
import 'map_decor.dart';

/// Draws decor standing on the floor, each over a small soft contact
/// shadow, as the contents stand over theirs: every shadow first, so
/// none falls on a decor, then every decor in the order given (back to
/// front, as [scatterDecor] lists them).
///
/// Knows nothing of the map: it takes the bitmap of each sprite from
/// [imageOf] and the shadow's from [shadow], drawn whole into their boxes;
/// or, those packed in an [atlas] (the shadow as [shadowSprite]), every
/// shadow in one mesh and every decor in another (see [AtlasMesh]).
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

  /// The sprites and the shadow packed, if any.
  final SpriteAtlas<String>? atlas;

  /// The key of the shadow in the [atlas].
  final String? shadowSprite;

  /// How the decor is sampled: smoothly, with mipmaps, by default.
  final FilterQuality filterQuality;
  final Paint _image;
  final _shadow = Paint()..filterQuality = FilterQuality.low;

  MapDecorDrawer({
    required this.imageOf,
    this.shadow,
    this.atlas,
    this.shadowSprite,
    this.filterQuality = FilterQuality.medium,
  }) : _image = Paint()..filterQuality = filterQuality;

  /// Draws [decor] on [canvas], in projection coordinates.
  void draw(Canvas canvas, Iterable<MapDecor> decor) {
    final atlas = this.atlas, key = shadowSprite;
    if (atlas != null && key != null && atlas.rectOf(key) != null) {
      return _drawPacked(canvas, decor, AtlasMesh(atlas), key);
    }
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

  void _drawPacked(Canvas canvas, Iterable<MapDecor> decor,
      AtlasMesh<String> mesh, String shadow) {
    for (final item in decor) {
      mesh.addRect(shadow, shadowOf(item));
    }
    mesh.flush(canvas, filterQuality: _shadow.filterQuality);
    for (final item in decor) {
      if (mesh.addRect(item.sprite, item.box)) continue;
      // Not packed: drawn in turn.
      mesh.flush(canvas, filterQuality: filterQuality);
      final image = imageOf(item.sprite);
      if (image != null) _drawWhole(canvas, image, item.box, _image);
    }
    mesh.flush(canvas, filterQuality: filterQuality);
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
