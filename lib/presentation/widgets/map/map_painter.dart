import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../theme/abyss_colors.dart';
import 'map_cell_visual.dart';
import 'map_content_drawer.dart';
import 'map_flat_contents.dart';
import 'map_projection.dart';
import 'map_sprites.dart';

export 'map_content_drawer.dart' show cellSize;

/// Paints the still floor of the map in one pass, in projection
/// coordinates: the diamond tile of every cell, the holes lying flat on
/// them, then a single path for exploration markers and another for the
/// fog.
///
/// Whatever stands (still or moving, through the fog or not) and every
/// glow, shadow and ring are left to the standing layer above, which
/// draws them back to front: panning never repaints this map.
class MapPainter extends CustomPainter {
  /// How far a floor tile is drawn past its box, so that neighbours
  /// overlap and no seam shows between them.
  static const tileBleed = 1.5;

  /// Blur of the fog's edge, paid only when the map repaints.
  static const fogBlur = 4.0;

  final List<MapCellVisual> visuals;
  final int columns;
  final MapSprites? sprites;

  const MapPainter({
    required this.visuals,
    required this.columns,
    this.sprites,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final drawer = MapContentDrawer(sprites);
    final terrain = Paint()..filterQuality = FilterQuality.medium;
    final fallback = Paint()..color = AbyssColors.plainBlue;
    final pending = Path();
    final fog = Path();
    final flat = <int>[];
    for (var i = 0; i < visuals.length; i++) {
      final visual = visuals[i];
      final cell = (i % columns, i ~/ columns);
      final image = sprites?.svg(visual.terrainSprite);
      image == null
          ? canvas.drawPath(MapProjection.diamondOf(cell), fallback)
          : drawer.drawSprite(canvas, image, tileOf(cell), terrain);
      if (visual.liesFlat) flat.add(i);
      if (visual.pending) {
        pending.addPath(MapProjection.diamondOf(cell, inset: 1), Offset.zero);
      }
      if (!visual.revealed) {
        fog.addPath(MapProjection.diamondOf(cell, inset: -0.5), Offset.zero);
      }
    }
    // Over every tile, as a hole reaches a little past its diamond.
    for (final i in flat) {
      drawer.drawFlat(canvas, visuals[i], (i % columns, i ~/ columns));
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
      Paint()
        ..color = AbyssColors.abyssBlack
            .withValues(alpha: AbyssColors.fogOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, fogBlur),
    );
  }

  /// The box the floor tile of [cell] is drawn in: its tile box, a hair
  /// larger.
  static Rect tileOf((int, int) cell) => Rect.fromCenter(
        center: MapProjection.centreOf(cell),
        width: MapProjection.tileWidth + 2 * tileBleed,
        height: MapProjection.tileHeight + tileBleed,
      );

  @override
  bool shouldRepaint(MapPainter oldDelegate) =>
      oldDelegate.sprites != sprites ||
      oldDelegate.columns != columns ||
      !listEquals(oldDelegate.visuals, visuals);
}
