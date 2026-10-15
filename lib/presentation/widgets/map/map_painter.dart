import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../../theme/abyss_colors.dart';
import '../ambience/ambient_motion.dart';
import 'map_cell_visual.dart';
import 'map_content_drawer.dart';
import 'map_sprites.dart';

export 'map_content_drawer.dart' show cellSize;

/// Paints the still map in one pass: one bitmap per layer and cell, then a
/// single path for exploration markers and another for the fog.
///
/// Contents that move are left out: the ambience layer above draws them,
/// so nothing is drawn twice and panning never repaints this map.
class MapPainter extends CustomPainter {
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
    canvas.drawRect(Offset.zero & size, Paint()..color = AbyssColors.abyssBlack);
    final drawer = MapContentDrawer(sprites);
    final terrain = Paint()..filterQuality = FilterQuality.medium;
    final fallback = Paint()..color = AbyssColors.plainBlue;
    final pending = Path();
    final fog = Path();
    final wide = <int>[];
    final beacons = <int>[];
    for (var i = 0; i < visuals.length; i++) {
      final visual = visuals[i];
      final rect = MapContentDrawer.cellRect(i, columns);
      final image = sprites?.svg(visual.terrainSprite);
      image == null
          ? canvas.drawRect(rect, fallback)
          : drawer.drawSprite(canvas, image, rect, terrain);
      if (visual.motion == AmbientMotion.still) {
        if (visual.aboveFog) {
          beacons.add(i);
        } else if (visual.contentSpan > 1) {
          wide.add(i);
        } else {
          drawer.drawContent(canvas, visual, rect);
        }
      }
      if (visual.pending) pending.addRect(rect.deflate(1));
      if (!visual.revealed) fog.addRect(rect);
    }
    // Over every terrain it covers, which the row-major loop draws later.
    for (final i in wide) {
      drawer.drawContent(
          canvas, visuals[i], MapContentDrawer.areaOf(visuals[i], i, columns));
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
    // The few cells seen through the fog (a wreck), over it.
    for (final i in beacons) {
      drawer.drawContent(
          canvas, visuals[i], MapContentDrawer.cellRect(i, columns));
    }
  }

  @override
  bool shouldRepaint(MapPainter oldDelegate) =>
      oldDelegate.sprites != sprites ||
      oldDelegate.columns != columns ||
      !listEquals(oldDelegate.visuals, visuals);
}
