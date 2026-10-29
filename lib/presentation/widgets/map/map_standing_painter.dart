import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../ambience/ambient_motion.dart';
import '../ambience/creature_sheet.dart';
import '../ambience/sprite_motion.dart';
import 'map_cell_visual.dart';
import 'map_content_drawer.dart';
import 'map_content_fade.dart';
import 'map_content_spot.dart';
import 'map_creature_sheets.dart';
import 'map_flat_contents.dart';
import 'map_projection.dart';
import 'map_sprites.dart';
import 'map_standing_fade.dart';
import 'map_standing_order.dart';
import 'map_standing_sprite.dart';

export 'map_standing_order.dart';

/// Draws every content standing on the map, still or moving, over the
/// still map that only keeps the floor: creatures float, homes breathe,
/// glows pulse, each content casts its shadow.
///
/// A content overlaps the cells behind its own, so contents are drawn
/// back to front: first all that lies on the floor (glows, shadows,
/// rings), then the standing sprites. Contents seen through the fog are
/// drawn too, this layer lying over the fog, and those an effect playing
/// over their cells fades ([fade]) are drawn faded.
///
/// Paints in projection coordinates, as the still map does, the map's
/// box holding the projection's origin at [MapProjection.originOf].
///
/// Repaints when [clock] ticks (if anything moves), [transform] pans the
/// map or [fade] changes, never rebuilding a widget, and only draws the
/// contents inside [viewport] seen through [transform]. The order, the
/// spots and the paints are made once per painter, so a frame allocates
/// next to nothing.
class MapStandingPainter extends CustomPainter {
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

  /// The contents an effect fades, if any.
  final MapContentFade? fade;

  /// The undulating sheet of a living creature's sprite, if built.
  final CreatureSheet? Function(String sprite) creatureSheetOf;

  /// Draws each content, its floor and its sprite or creature.
  final MapStandingSprite _standing;

  /// Where each content is drawn, back to front.
  final List<MapContentSpot> _spots;

  /// The pose of each content of [_spots] at the frame being painted.
  final List<SpriteMotion> _poses;

  /// From the map's box to projection coordinates.
  final Offset _toProjection;

  late final _fades = MapStandingFade(fade, _spots, columns);

  MapStandingPainter({
    required this.visuals,
    required this.columns,
    required this.clock,
    required this.transform,
    required this.viewport,
    this.sprites,
    this.fade,
    this.creatureSheetOf = MapCreatureSheets.peek,
  })  : _standing =
            MapStandingSprite(MapContentDrawer(sprites), creatureSheetOf),
        _spots = [
          for (final i in standingCells(visuals, columns))
            MapContentSpot.of(visuals[i], i, columns),
        ],
        _poses = List.filled(visuals.length, SpriteMotion.rest),
        _toProjection = -MapProjection.originOf(
            columns == 0 ? 0 : visuals.length ~/ columns),
        super(repaint: _repaintOf(visuals, clock, transform, fade));

  /// The panning, the fade and the clock, unless nothing moves.
  static Listenable _repaintOf(List<MapCellVisual> visuals,
          Listenable clock, Listenable transform, Listenable? fade) =>
      Listenable.merge([
        transform,
        fade,
        if (visuals.any((v) => v.motion != AmbientMotion.still)) clock,
      ]);

  @override
  void paint(Canvas canvas, Size size) {
    if (sprites == null || _spots.isEmpty) return;
    final visible =
        visibleMapRect(transform.value, viewport).shift(_toProjection);
    final seconds = clock.value;
    // Indexed loops: no iterator is made for a frame.
    for (var k = 0; k < _spots.length; k++) {
      final spot = _spots[k];
      if (!spot.bounds.overlaps(visible) || !_fades.begin(canvas, k)) continue;
      final visual = visuals[spot.index];
      final pose = visual.motion == AmbientMotion.still
          ? SpriteMotion.rest
          : visual.motion.at(seconds, phase: _phaseOf(spot.index));
      _poses[k] = pose;
      _standing.drawer.drawFloor(canvas, visual, spot, pose: pose);
      _fades.end(canvas, k);
    }
    for (var k = 0; k < _spots.length; k++) {
      final spot = _spots[k];
      final visual = visuals[spot.index];
      if (!visual.standsUp || !spot.bounds.overlaps(visible)) continue;
      if (!_fades.begin(canvas, k)) continue;
      _standing.draw(canvas, visual, spot.area, _poses[k],
          seconds: seconds, phase: _phaseOf(spot.index));
      _fades.end(canvas, k);
    }
  }

  /// The phase of the motion of the content at [index], set by its cell.
  double _phaseOf(int index) =>
      AmbientMotion.phaseOf(index % columns, index ~/ columns);

  @override
  bool shouldRepaint(MapStandingPainter oldDelegate) =>
      oldDelegate.sprites != sprites ||
      oldDelegate.columns != columns ||
      oldDelegate.clock != clock ||
      oldDelegate.transform != transform ||
      oldDelegate.viewport != viewport ||
      oldDelegate.fade != fade ||
      oldDelegate.creatureSheetOf != creatureSheetOf ||
      !listEquals(oldDelegate.visuals, visuals);

  @override
  bool? hitTest(Offset position) => false;
}
