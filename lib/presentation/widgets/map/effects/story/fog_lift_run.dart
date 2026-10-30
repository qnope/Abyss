import 'package:flutter/painting.dart';

import '../../../../../domain/unit/unit_type.dart';
import '../../../../extensions/unit_type_extensions.dart';
import '../../../../theme/abyss_colors.dart';
import '../../../../theme/abyss_motion.dart';
import '../../map_content_drawer.dart';
import '../../map_floor_tiles.dart';
import '../../map_projection.dart';
import '../../token/map_token_drawer.dart';
import '../../token/map_token_trip.dart';
import '../map_effect.dart';
import 'map_fog_lift.dart';

/// A [MapFogLift] placed on a map: each cell seen is first drawn as the
/// map draws a cell in the fog, held a moment, then all of it fades out.
///
/// Its floor tile on its diamond, the cyan diamond of a scout's target
/// and the fog over them lie on the floor, under the contents standing
/// on the map: those of the cells seen stay hidden meanwhile, then fade
/// in as the fog lifts ([fadedCells]), all but the wrecks seen through
/// the fog, which stand above it all along. The scouts waiting on their
/// edge are drawn over the map.
///
/// Every box and path is made once, so a frame allocates next to nothing.
class FogLiftRun extends MapEffectRun {
  /// How long the fog holds before lifting.
  static const hold = AbyssMotion.storyPause;

  /// How long the fog takes to lift.
  static const lift = AbyssMotion.fade;

  final MapFogLift fog;
  final MapStage stage;

  /// The floor tile of each cell seen, with the box it is drawn in.
  final List<(String, Rect)> _tiles;

  /// The diamonds of the cells seen, and those of the scouts' targets.
  final Path _floor = Path(), _marks = Path();

  @override
  final Set<(int, int)> fadedCells;

  /// The scouts waiting on their targets.
  final List<Rect> _scouts;

  final _drawer = MapContentDrawer(null);
  final _token = MapTokenDrawer();
  final _image = Paint()..filterQuality = FilterQuality.medium;
  final _fallback = Paint();
  final _fog = Paint();
  final _mark = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  FogLiftRun(this.fog, {required this.stage})
      : _tiles = [
          for (final MapEntry(key: cell, value: tile) in fog.cells.entries)
            (tile, MapFloorTiles.tileOf(cell)),
        ],
        fadedCells = fog.cells.keys.toSet().difference(fog.beacons),
        _scouts = [
          for (final cell in fog.scouts)
            MapProjection.upright(MapTokenTrip.restingRect(cell)),
        ] {
    for (final cell in fog.cells.keys) {
      _floor.addPath(MapProjection.diamondOf(cell, inset: -0.5), Offset.zero);
      if (fog.scouts.contains(cell)) {
        _marks.addPath(MapProjection.diamondOf(cell, inset: 1), Offset.zero);
      }
    }
  }

  @override
  Duration get duration => hold + lift;

  @override
  Offset shakeAt(Duration elapsed) => Offset.zero;

  /// How much of the fog is left [elapsed] into the lift: 1, then 0.
  double opacityAt(Duration elapsed) {
    if (elapsed <= hold) return 1;
    final share = (elapsed - hold).inMicroseconds / lift.inMicroseconds;
    return 1 - AbyssMotion.exit.transform(share.clamp(0.0, 1.0));
  }

  /// The contents of the cells seen show as the fog leaves them.
  @override
  double contentOpacityAt(Duration elapsed) => 1 - opacityAt(elapsed);

  @override
  void paintFloor(Canvas canvas, Duration elapsed) {
    final opacity = opacityAt(elapsed);
    if (opacity <= 0) return;
    _image.color = Color.fromRGBO(0, 0, 0, opacity);
    _fallback.color = AbyssColors.plainBlue
        .withValues(alpha: AbyssColors.plainBlue.a * opacity);
    _fog.color = AbyssColors.abyssBlack
        .withValues(alpha: AbyssColors.fogOpacity * opacity);
    _mark.color = AbyssColors.biolumCyan.withValues(alpha: opacity);
    // Under the tiles, in place of any not loaded yet.
    canvas.drawPath(_floor, _fallback);
    // Indexed loops: no iterator is made for a frame.
    for (var i = 0; i < _tiles.length; i++) {
      final (tile, box) = _tiles[i];
      _drawer.drawSprite(canvas, stage.image(tile), box, _image);
    }
    canvas
      ..drawPath(_marks, _mark)
      ..drawPath(_floor, _fog);
  }

  @override
  void paint(Canvas canvas, Duration elapsed) {
    final opacity = opacityAt(elapsed);
    if (opacity <= 0) return;
    final scout = stage.image(UnitType.scout.iconPath);
    for (var i = 0; i < _scouts.length; i++) {
      _token.draw(canvas, _scouts[i], scout, opacity: opacity);
    }
  }
}
