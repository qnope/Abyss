import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import 'creature_undulation.dart';

/// The frames of a living creature undulating, pre-rendered once from
/// its bitmap and packed row by row in one [atlas], so playing them
/// costs a single image draw per frame, like a still sprite.
///
/// Each frame leaves room around the creature for its [undulation] to
/// reach without being cut.
class CreatureSheet {
  /// Side of a frame, in pixels: enough for a sprite on the map.
  static const pixels = 128;

  /// Frames per row of the atlas.
  static const columns = 4;

  final ui.Image atlas;
  final CreatureUndulation undulation;

  const CreatureSheet(this.atlas, {required this.undulation});

  /// Where [frame] lies in the [atlas].
  Rect frameRect(int frame) => _frameAt(frame);

  static Rect _frameAt(int frame) => Rect.fromLTWH(
        (frame % columns) * pixels.toDouble(),
        (frame ~/ columns) * pixels.toDouble(),
        pixels.toDouble(),
        pixels.toDouble(),
      );

  /// Where to draw a frame so the creature covers [body], as its still
  /// sprite would.
  Rect frameDst(Rect body) => body.inflate(body.width * undulation.reach);

  /// Draws [frame] (wrapped around the loop) so the creature covers
  /// [body].
  void draw(Canvas canvas, int frame, Rect body, Paint paint) =>
      canvas.drawImageRect(atlas, frameRect(frame % undulation.frames),
          frameDst(body), paint);

  /// Renders the frames of [bitmap] (a square sprite) undulating, each
  /// by drawing it through the grid of [undulation] at that frame.
  static Future<CreatureSheet> build(
    ui.Image bitmap, {
    CreatureUndulation undulation = CreatureUndulation.standard,
  }) async {
    final rows = (undulation.frames / columns).ceil();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final source = bitmap.width.toDouble();
    final shader = ui.ImageShader(bitmap, TileMode.clamp, TileMode.clamp,
        Matrix4.identity().storage,
        filterQuality: FilterQuality.medium);
    final paint = Paint()..shader = shader;
    final texture = [
      for (final rest in undulation.restVertices()) rest * source,
    ];
    final triangles = undulation.triangles();
    final inset = undulation.reach / (1 + 2 * undulation.reach);
    for (var frame = 0; frame < undulation.frames; frame++) {
      final cell = _frameAt(frame);
      final body = cell.deflate(cell.width * inset);
      final vertices = ui.Vertices(
        VertexMode.triangles,
        [
          for (final at in undulation.verticesAt(frame))
            body.topLeft + at * body.width,
        ],
        textureCoordinates: texture,
        indices: triangles,
      );
      canvas.drawVertices(vertices, BlendMode.dst, paint);
      vertices.dispose();
    }
    shader.dispose();
    final picture = recorder.endRecording();
    final atlas = await picture
        .toImage(columns * pixels, rows * pixels)
        .whenComplete(picture.dispose);
    return CreatureSheet(atlas, undulation: undulation);
  }
}
