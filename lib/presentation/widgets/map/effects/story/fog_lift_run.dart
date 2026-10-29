import 'package:flutter/painting.dart';

import '../../../../../domain/unit/unit_type.dart';
import '../../../../extensions/unit_type_extensions.dart';
import '../../../../theme/abyss_colors.dart';
import '../../../../theme/abyss_motion.dart';
import '../../map_cell_visual.dart';
import '../../map_content_drawer.dart';
import '../../map_content_spot.dart';
import '../../map_painter.dart';
import '../../map_projection.dart';
import '../../map_standing_order.dart';
import '../../token/map_token_drawer.dart';
import '../../token/map_token_trip.dart';
import '../map_effect.dart';
import 'map_fog_lift.dart';

/// A [MapFogLift] placed on a map: each cell seen is first drawn as the
/// still map draws a cell in the fog (its floor tile on its diamond, the
/// cyan diamond of a scout's target, the fog over them, the scout waiting
/// on its edge), held a moment, then all of it fades out. A wreck seen
/// through the fog stands above it as the standing layer draws it, back
/// to front, fading with it as the one of the map below shows through.
///
/// Every box and path is made once, so a frame allocates next to nothing.
class FogLiftRun implements MapEffectRun {
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

  /// The wrecks seen through the fog, back to front.
  final List<(String, MapContentSpot)> _beacons;

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
            (tile, MapPainter.tileOf(cell)),
        ],
        _beacons = _beaconsOf(fog.beacons),
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

  static List<(String, MapContentSpot)> _beaconsOf(
      Map<(int, int), String> beacons) {
    final cells = beacons.keys.toList()
      ..sort((a, b) =>
          compareStandingRanks(standingRankOf(a), standingRankOf(b)));
    return [for (final c in cells) (beacons[c]!, MapContentSpot.at(c))];
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

  @override
  void paint(Canvas canvas, Duration elapsed) {
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
    _paintBeacons(canvas);
    final scout = stage.image(UnitType.scout.iconPath);
    for (var i = 0; i < _scouts.length; i++) {
      _token.draw(canvas, _scouts[i], scout, opacity: opacity);
    }
  }

  /// Draws the wrecks seen through the fog as the standing layer does:
  /// first their pools and shadows on the floor, then the wrecks.
  void _paintBeacons(Canvas canvas) {
    for (var i = 0; i < _beacons.length; i++) {
      final spot = _beacons[i].$2;
      _drawer
        ..drawOnFloor(canvas, stage.pool(MapGlow.wreck), spot.glow, _image)
        ..drawOnFloor(canvas, stage.shadow, spot.shadow, _image);
    }
    for (var i = 0; i < _beacons.length; i++) {
      final (sprite, spot) = _beacons[i];
      _drawer.drawSprite(canvas, stage.image(sprite), spot.area, _image);
    }
  }
}
