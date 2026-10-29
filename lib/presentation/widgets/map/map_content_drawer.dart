import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../ambience/ambient_motion.dart';
import '../ambience/sprite_motion.dart';
import 'map_cell_size.dart';
import 'map_cell_visual.dart';
import 'map_content_spot.dart';
import 'map_flat_contents.dart';
import 'map_projection.dart';
import 'map_floor_sprites.dart';
import 'map_sprites.dart';

export 'map_cell_size.dart';

/// Draws the content of map cells: a hole lying flat on its diamond, or
/// a content standing up over its glow, shadow and ring on the floor.
///
/// Its paints are made once and reused for every cell it draws.
class MapContentDrawer {
  final MapSprites? sprites;

  /// How far a hole lying flat reaches past each side of its cell, as a
  /// share of the cell.
  static const flatBleed = 0.08;

  static final spriteSrc = Rect.fromLTWH(
    0,
    0,
    MapSprites.spriteSize.toDouble(),
    MapSprites.spriteSize.toDouble(),
  );

  static final _floorSrc = Rect.fromLTWH(
      0, 0, floorSpriteSize.toDouble(), floorSpriteSize.toDouble());

  final _image = Paint()..filterQuality = FilterQuality.medium;
  final _dimmed = Paint()
    ..filterQuality = FilterQuality.medium
    ..color = const Color.fromRGBO(0, 0, 0, 0.3);
  final _glow = Paint()..filterQuality = FilterQuality.medium;
  final _shadow = Paint()..filterQuality = FilterQuality.low;
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

  /// Where a hole lying flat on [cell] is drawn on the flat map, before
  /// [MapProjection.isometric] lays it on its diamond.
  static Rect flatOf((int, int) cell) => Rect.fromLTWH(
        cell.$1 * cellSize,
        cell.$2 * cellSize,
        cellSize,
        cellSize,
      ).inflate(flatBleed * cellSize);

  /// Draws [sprite] into [dst], or nothing while it is not loaded.
  void drawSprite(Canvas canvas, ui.Image? sprite, Rect dst, Paint paint) {
    if (sprite != null) canvas.drawImageRect(sprite, spriteSrc, dst, paint);
  }

  /// Draws [image], a floor sprite (a pool, a shadow), flattened in [dst].
  void drawOnFloor(Canvas canvas, ui.Image? image, Rect dst, Paint paint) {
    if (image != null) canvas.drawImageRect(image, _floorSrc, dst, paint);
  }

  /// Draws what [visual] lays on the floor at [spot]: the pool of its
  /// glow (a pulsing one at the [pose]'s glow), the shadow of a standing
  /// content, then the ring of a faction's base.
  void drawFloor(
    Canvas canvas,
    MapCellVisual visual,
    MapContentSpot spot, {
    SpriteMotion pose = SpriteMotion.rest,
  }) {
    if (visual.glow != MapGlow.none) {
      final opacity =
          visual.motion == AmbientMotion.pulse ? pose.glow : 1.0;
      _glow.color = Color.fromRGBO(0, 0, 0, opacity);
      drawOnFloor(canvas, sprites?.pool(visual.glow), spot.glow, _glow);
    }
    if (visual.standsUp) {
      drawOnFloor(canvas, sprites?.shadow, spot.shadow, _shadow);
    }
    final ring = visual.factionColor;
    if (ring != null) {
      _ring.color = ring;
      canvas.drawOval(spot.ring, _ring);
    }
  }

  /// Draws [visual] standing in [area] in [pose]: its sprite, dimmed once
  /// collected, under the seal of a held volcano.
  void drawStanding(
    Canvas canvas,
    MapCellVisual visual,
    Rect area, {
    SpriteMotion pose = SpriteMotion.rest,
  }) {
    if (pose.isRest) return _drawBody(canvas, visual, area);
    pose.paint(canvas, area, () => _drawBody(canvas, visual, area));
  }

  /// Draws the hole of [visual] lying flat on the diamond of [cell].
  void drawFlat(Canvas canvas, MapCellVisual visual, (int, int) cell) {
    final sprite = sprites?.svg(visual.contentSprite!);
    if (sprite == null) return;
    canvas
      ..save()
      ..transform(MapProjection.isometric);
    drawSprite(canvas, sprite, flatOf(cell), visual.dimmed ? _dimmed : _image);
    canvas.restore();
  }

  void _drawBody(Canvas canvas, MapCellVisual visual, Rect body) {
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
