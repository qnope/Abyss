import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../theme/abyss_colors.dart';
import 'map_cell_visual.dart';
import 'map_sprites.dart';

const cellSize = 48.0;
const _contentSize = 28.0;
const _contentInset = (cellSize - _contentSize) / 2;

/// Paints the whole map in one pass: one bitmap per layer and cell, then a
/// single path for exploration markers and another for the fog.
class MapPainter extends CustomPainter {
  final List<MapCellVisual> visuals;
  final int columns;
  final MapSprites? sprites;

  const MapPainter({
    required this.visuals,
    required this.columns,
    this.sprites,
  });

  static final _spriteSrc = Rect.fromLTWH(
    0,
    0,
    MapSprites.spriteSize.toDouble(),
    MapSprites.spriteSize.toDouble(),
  );

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AbyssColors.abyssBlack);
    final image = Paint()..filterQuality = FilterQuality.medium;
    final dimmed = Paint()
      ..filterQuality = FilterQuality.medium
      ..color = const Color.fromRGBO(0, 0, 0, 0.3);
    final fallback = Paint()..color = AbyssColors.plainBlue;
    final pending = Path();
    final fog = Path();
    final wide = <int>[];
    for (var i = 0; i < visuals.length; i++) {
      final visual = visuals[i];
      final rect = _cellRect(i);
      _drawSprite(canvas, sprites?.svg(visual.terrainSprite), rect, image,
          fallback: fallback);
      if (!visual.aboveFog) {
        _drawContent(canvas, visual, rect, image,
            visual.dimmed ? dimmed : image);
      }
      if (visual.contentSpan > 1) wide.add(i);
      if (visual.pending) pending.addRect(rect.deflate(1));
      if (!visual.revealed) fog.addRect(rect);
    }
    // Over every terrain it covers, which the row-major loop draws later.
    for (final i in wide) {
      _drawWide(canvas, visuals[i], i, image);
    }
    canvas.drawPath(
      pending,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AbyssColors.biolumCyan,
    );
    canvas.drawPath(
      fog,
      Paint()..color = AbyssColors.abyssBlack.withValues(alpha: 0.7),
    );
    // A second pass over the few cells seen through the fog (a wreck).
    for (var i = 0; i < visuals.length; i++) {
      if (visuals[i].aboveFog) {
        _drawContent(canvas, visuals[i], _cellRect(i), image, image);
      }
    }
  }

  void _drawContent(Canvas canvas, MapCellVisual visual, Rect rect,
      Paint glow, Paint content) {
    if (visual.glow != MapGlow.none) {
      _drawSprite(canvas, sprites?.glow(visual.glow), rect, glow);
    }
    final ring = visual.factionColor;
    if (ring != null) {
      canvas.drawCircle(
        rect.center,
        _contentSize / 2 + 3,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = ring,
      );
    }
    final sprite = visual.contentSprite;
    if (sprite != null && visual.contentSpan == 1) {
      _drawSprite(
          canvas, sprites?.svg(sprite), rect.deflate(_contentInset), content);
    }
  }

  /// Content spanning several cells (the volcano), with its seal if held.
  void _drawWide(Canvas canvas, MapCellVisual visual, int index, Paint image) {
    final origin = _cellRect(index).topLeft;
    final side = cellSize * visual.contentSpan;
    final rect = Rect.fromLTWH(origin.dx, origin.dy, side, side);
    final sprite = visual.contentSprite;
    if (sprite != null) _drawSprite(canvas, sprites?.svg(sprite), rect, image);
    final seal = visual.sealColor;
    if (seal != null) {
      _drawSprite(
        canvas,
        sprites?.svg(volcanoSealSvgPath),
        rect,
        Paint()
          ..filterQuality = FilterQuality.medium
          ..colorFilter = ColorFilter.mode(seal, BlendMode.modulate),
      );
    }
  }

  Rect _cellRect(int index) => Rect.fromLTWH(
        (index % columns) * cellSize,
        (index ~/ columns) * cellSize,
        cellSize,
        cellSize,
      );

  void _drawSprite(Canvas canvas, ui.Image? sprite, Rect dst, Paint paint,
      {Paint? fallback}) {
    if (sprite != null) {
      canvas.drawImageRect(sprite, _spriteSrc, dst, paint);
    } else if (fallback != null) {
      canvas.drawRect(dst, fallback);
    }
  }

  @override
  bool shouldRepaint(MapPainter oldDelegate) =>
      oldDelegate.sprites != sprites ||
      oldDelegate.columns != columns ||
      !listEquals(oldDelegate.visuals, visuals);
}
