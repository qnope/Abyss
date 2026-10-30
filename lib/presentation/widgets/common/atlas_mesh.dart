import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'sprite_atlas.dart';

/// Sprites of an [atlas] laid as one mesh of triangles, then drawn in a
/// single call, in the order laid: as cheap as one bitmap, however many.
///
/// Each sprite is textured as if drawn whole into its box, so it looks
/// the same as a bitmap drawn there; a shape drawn past the sprite's
/// edges only meets the atlas's transparent margin.
class AtlasMesh<K> {
  final SpriteAtlas<K> atlas;
  final _positions = <Offset>[];
  final _texels = <Offset>[];

  AtlasMesh(this.atlas);

  /// The corners of the triangles laid, three by three.
  @visibleForTesting
  List<Offset> get positions => List.unmodifiable(_positions);

  /// Where each corner of [positions] reads the atlas.
  @visibleForTesting
  List<Offset> get textureCoordinates => List.unmodifiable(_texels);

  /// Lays the sprite of [key] whole into [dst], as two triangles; nothing
  /// if it is not packed, then false.
  bool addRect(K key, Rect dst) => _add(key, dst, [
        dst.topLeft, dst.topRight, dst.bottomRight,
        dst.topLeft, dst.bottomRight, dst.bottomLeft,
      ]);

  /// Lays the diamond inscribed in [dst], [reach] times as large around
  /// its centre, of the sprite of [key] drawn into [dst]; nothing if it is
  /// not packed, then false.
  bool addDiamond(K key, Rect dst, {double reach = 1}) {
    final c = dst.center;
    final (w, h) = (reach * dst.width / 2, reach * dst.height / 2);
    final (top, bottom) = (c.translate(0, -h), c.translate(0, h));
    final (right, left) = (c.translate(w, 0), c.translate(-w, 0));
    return _add(key, dst, [top, right, bottom, top, bottom, left]);
  }

  bool _add(K key, Rect dst, List<Offset> corners) {
    final src = atlas.rectOf(key);
    if (src == null || dst.isEmpty) return false;
    final scale = Offset(src.width / dst.width, src.height / dst.height);
    for (final corner in corners) {
      final share = corner - dst.topLeft;
      _positions.add(corner);
      _texels.add(src.topLeft +
          Offset(share.dx * scale.dx, share.dy * scale.dy));
    }
    return true;
  }

  /// Draws the sprites laid, sampled with [filterQuality] (with mipmaps
  /// from medium), then forgets them.
  void flush(Canvas canvas,
      {FilterQuality filterQuality = FilterQuality.medium}) {
    if (_positions.isEmpty) return;
    final vertices = ui.Vertices.raw(ui.VertexMode.triangles,
        _flatten(_positions), textureCoordinates: _flatten(_texels));
    // Without colours in the vertices, the paint's shader alone shows.
    canvas.drawVertices(vertices, BlendMode.dst,
        Paint()..shader = atlas.shaderOf(filterQuality));
    vertices.dispose();
    _positions.clear();
    _texels.clear();
  }

  static Float32List _flatten(List<Offset> points) {
    final flat = Float32List(2 * points.length);
    for (var i = 0; i < points.length; i++) {
      flat[2 * i] = points[i].dx;
      flat[2 * i + 1] = points[i].dy;
    }
    return flat;
  }
}
