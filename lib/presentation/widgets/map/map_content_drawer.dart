import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../ambience/ambient_motion.dart';
import '../ambience/sprite_motion.dart';
import 'map_cell_visual.dart';
import 'map_projection.dart';
import 'map_sprites.dart';

/// Side of a map cell, in logical pixels.
const cellSize = 48.0;

/// Draws the content of map cells (glow, faction ring, sprite, seal) the
/// same way for the static map and the ambience layer above it.
///
/// Its paints are made once and reused for every cell it draws.
class MapContentDrawer {
  final MapSprites? sprites;

  /// Side of a one-cell content sprite, centred in its cell.
  static const contentSize = 28.0;
  static const _contentInset = (cellSize - contentSize) / 2;

  static final spriteSrc = Rect.fromLTWH(
    0,
    0,
    MapSprites.spriteSize.toDouble(),
    MapSprites.spriteSize.toDouble(),
  );

  final _image = Paint()..filterQuality = FilterQuality.medium;
  final _dimmed = Paint()
    ..filterQuality = FilterQuality.medium
    ..color = const Color.fromRGBO(0, 0, 0, 0.3);
  final _glow = Paint()..filterQuality = FilterQuality.medium;
  final _seal = Paint()..filterQuality = FilterQuality.medium;
  final _ring = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  MapContentDrawer(this.sprites);

  /// The flat cell at [index] of a map [columns] cells wide.
  static Rect cellRect(int index, int columns) => Rect.fromLTWH(
        (index % columns) * cellSize,
        (index ~/ columns) * cellSize,
        cellSize,
        cellSize,
      );

  /// Where the content of [visual] at [index] stands on screen: on its
  /// cell, or on the block a wide content (the volcano) covers from there.
  static Rect areaOf(MapCellVisual visual, int index, int columns) =>
      MapProjection.standingOf((index % columns, index ~/ columns),
          span: visual.contentSpan);

  /// Where the sprite of [visual] lies in its [area]: inset from its
  /// glow, or over the whole area of a wide content.
  static Rect bodyOf(MapCellVisual visual, Rect area) =>
      visual.contentSpan == 1 ? area.deflate(_contentInset) : area;

  /// Draws [sprite] into [dst], or nothing while it is not loaded.
  void drawSprite(Canvas canvas, ui.Image? sprite, Rect dst, Paint paint) {
    if (sprite != null) canvas.drawImageRect(sprite, spriteSrc, dst, paint);
  }

  /// Draws the content of [visual] over [area] in [pose]: its glow stays
  /// put (a pulsing one at the pose's glow opacity), the rest moves.
  void drawContent(
    Canvas canvas,
    MapCellVisual visual,
    Rect area, {
    SpriteMotion pose = SpriteMotion.rest,
  }) {
    if (visual.glow != MapGlow.none) {
      final opacity =
          visual.motion == AmbientMotion.pulse ? pose.glow : 1.0;
      _glow.color = Color.fromRGBO(0, 0, 0, opacity);
      drawSprite(canvas, sprites?.glow(visual.glow), area, _glow);
    }
    final body = bodyOf(visual, area);
    pose.paint(canvas, body, () => _drawBody(canvas, visual, body));
  }

  void _drawBody(Canvas canvas, MapCellVisual visual, Rect body) {
    final ring = visual.factionColor;
    if (ring != null) {
      _ring.color = ring;
      canvas.drawCircle(body.center, body.shortestSide / 2 + 3, _ring);
    }
    final sprite = visual.contentSprite;
    if (sprite != null) {
      drawSprite(canvas, sprites?.svg(sprite), body,
          visual.dimmed ? _dimmed : _image);
    }
    final seal = visual.sealColor;
    if (seal != null) {
      _seal.colorFilter = ColorFilter.mode(seal, BlendMode.modulate);
      drawSprite(canvas, sprites?.svg(volcanoSealSvgPath), body, _seal);
    }
  }
}
