import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../ambience/ambient_motion.dart';
import '../ambience/creature_sheet.dart';
import 'living_creatures.dart';
import 'map_ambience_cells.dart';
import 'map_cell_visual.dart';
import 'map_content_drawer.dart';
import 'map_creature_sheets.dart';
import 'map_sprites.dart';

export 'map_ambience_cells.dart';

/// Draws the moving contents of the map, laid over the static map that
/// leaves them out: creatures float, homes breathe, glows pulse.
///
/// Repaints when [clock] ticks or [transform] pans the map, never
/// rebuilding a widget, and only draws the cells inside [viewport] seen
/// through [transform]. The list of moving cells and the paints are made
/// once per painter, so a frame allocates next to nothing.
class MapAmbiencePainter extends CustomPainter {
  final List<MapCellVisual> visuals;
  final int columns;
  final MapSprites? sprites;

  /// Seconds of the shared ambience clock.
  final ValueListenable<double> clock;

  /// How the map is moved within [viewport], e.g. an InteractiveViewer's
  /// TransformationController.
  final ValueListenable<Matrix4> transform;

  /// Size of the screen area the map is seen through.
  final Size viewport;

  /// The undulating sheet of a living creature's sprite, if built.
  final CreatureSheet? Function(String sprite) creatureSheetOf;

  final MapContentDrawer _drawer;
  final _creature = Paint()..filterQuality = FilterQuality.medium;
  final List<int> _animated;

  MapAmbiencePainter({
    required this.visuals,
    required this.columns,
    required this.clock,
    required this.transform,
    required this.viewport,
    this.sprites,
    this.creatureSheetOf = MapCreatureSheets.peek,
  })  : _drawer = MapContentDrawer(sprites),
        _animated = animatedCells(visuals),
        super(repaint: Listenable.merge([clock, transform]));

  @override
  void paint(Canvas canvas, Size size) {
    if (sprites == null || _animated.isEmpty) return;
    final visible = visibleMapRect(transform.value, viewport);
    final seconds = clock.value;
    for (final i in _animated) {
      final visual = visuals[i];
      final area = MapContentDrawer.areaOf(visual, i, columns);
      if (!area.overlaps(visible)) continue;
      final phase = AmbientMotion.phaseOf(i % columns, i ~/ columns);
      final pose = visual.motion.at(seconds, phase: phase);
      final sheet = _sheetOf(visual);
      if (sheet == null) {
        _drawer.drawContent(canvas, visual, area, pose: pose);
        continue;
      }
      final body = MapContentDrawer.bodyOf(visual, area);
      final frame = sheet.undulation.frameAt(seconds, phase: phase);
      pose.paint(canvas, body,
          () => sheet.draw(canvas, frame, body, _creature));
    }
  }

  CreatureSheet? _sheetOf(MapCellVisual visual) {
    final sprite = visual.contentSprite;
    return isLivingCreature(sprite) ? creatureSheetOf(sprite!) : null;
  }

  @override
  bool shouldRepaint(MapAmbiencePainter oldDelegate) =>
      oldDelegate.sprites != sprites ||
      oldDelegate.columns != columns ||
      oldDelegate.clock != clock ||
      oldDelegate.transform != transform ||
      oldDelegate.viewport != viewport ||
      oldDelegate.creatureSheetOf != creatureSheetOf ||
      !listEquals(oldDelegate.visuals, visuals);

  @override
  bool? hitTest(Offset position) => false;
}
