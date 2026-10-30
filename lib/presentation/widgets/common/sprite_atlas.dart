import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// Bitmaps packed into one, each whole and pixel for pixel in a cell of
/// its own, a transparent margin of [padding] pixels around it: a single
/// draw call (see [AtlasMesh]) then lays any number of them, in order.
///
/// The owner disposes it, the bitmaps packed staying theirs.
class SpriteAtlas<K> {
  /// Pixels of transparent margin around each sprite: room for a shape
  /// reaching a little past it, and for its mipmaps not to bleed into a
  /// neighbour's.
  static const padding = 16;

  /// The bitmap every sprite is packed in.
  final ui.Image image;
  final Map<K, Rect> _rects;

  /// The shader reading [image], by how it samples it.
  final _shaders = <FilterQuality, ui.ImageShader>{};

  SpriteAtlas._(this.image, this._rects);

  /// Where the sprite of [key] lies in [image], if packed.
  Rect? rectOf(K key) => _rects[key];

  /// The shader reading [image] as it lies, sampled with [quality]: made
  /// once, kept until disposed.
  ui.ImageShader shaderOf(FilterQuality quality) =>
      _shaders.putIfAbsent(quality, () => ui.ImageShader(
          // A clone: on the web, disposing the shader disposes its image.
          image.clone(), TileMode.clamp, TileMode.clamp, _identity,
          filterQuality: quality));

  static final _identity = Float64List.fromList(
      [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]);

  /// Packs [sprites] in a square grid of cells as large as the largest.
  static Future<SpriteAtlas<K>> pack<K>(Map<K, ui.Image> sprites) {
    var side = 1;
    for (final image in sprites.values) {
      side = math.max(side, math.max(image.width, image.height));
    }
    final cell = side + 2 * padding;
    final columns = math.max(1, math.sqrt(sprites.length).ceil());
    final rows = math.max(1, (sprites.length / columns).ceil());
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final rects = <K, Rect>{};
    var i = 0;
    for (final MapEntry(:key, value: image) in sprites.entries) {
      final at = Offset((i % columns * cell + padding).toDouble(),
          (i ~/ columns * cell + padding).toDouble());
      canvas.drawImage(image, at, Paint());
      rects[key] = at &
          Size(image.width.toDouble(), image.height.toDouble());
      i++;
    }
    final picture = recorder.endRecording();
    return picture
        .toImage(columns * cell, rows * cell)
        .then((image) => SpriteAtlas._(image, rects))
        .whenComplete(picture.dispose);
  }

  /// Disposes the packed bitmap and its shaders.
  void dispose() {
    for (final shader in _shaders.values) {
      shader.dispose();
    }
    _shaders.clear();
    image.dispose();
  }
}
