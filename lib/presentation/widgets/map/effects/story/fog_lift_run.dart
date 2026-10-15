import 'package:flutter/painting.dart';

import '../../../../../domain/unit/unit_type.dart';
import '../../../../extensions/unit_type_extensions.dart';
import '../../../../theme/abyss_colors.dart';
import '../../../../theme/abyss_motion.dart';
import '../../map_cell_visual.dart';
import '../../map_content_drawer.dart';
import '../../token/map_token_drawer.dart';
import '../../token/map_token_trip.dart';
import '../map_effect.dart';
import 'map_fog_lift.dart';

/// A [MapFogLift] placed on a map: each cell seen is first drawn as the
/// still map draws a cell in the fog (the dark sea, its terrain alone,
/// the cyan mark of a scout's target, the fog over them, the scout
/// waiting in its corner), held a moment, then all of it fades out. A
/// wreck seen through the fog stays drawn above it, fading with it as
/// the one of the map below shows through.
class FogLiftRun implements MapEffectRun {
  /// How long the fog holds before lifting.
  static const hold = AbyssMotion.storyPause;

  /// How long the fog takes to lift.
  static const lift = AbyssMotion.fade;

  final MapFogLift fog;
  final MapStage stage;

  final _token = MapTokenDrawer();
  final _terrain = Paint()..filterQuality = FilterQuality.medium;
  final _sea = Paint();
  final _fallback = Paint();
  final _fog = Paint();
  final _beacon = Paint()..filterQuality = FilterQuality.medium;
  final _mark = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  FogLiftRun(this.fog, {required this.stage});

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
    _terrain.color = Color.fromRGBO(0, 0, 0, opacity);
    _sea.color = AbyssColors.abyssBlack.withValues(alpha: opacity);
    _fallback.color = AbyssColors.plainBlue
        .withValues(alpha: AbyssColors.plainBlue.a * opacity);
    _fog.color = AbyssColors.abyssBlack
        .withValues(alpha: AbyssColors.fogOpacity * opacity);
    _mark.color = AbyssColors.biolumCyan.withValues(alpha: opacity);
    _beacon.color = Color.fromRGBO(0, 0, 0, opacity);
    for (final MapEntry(key: cell, value: terrain) in fog.cells.entries) {
      final rect = _rectOf(cell);
      final sprite = stage.image(terrain);
      canvas.drawRect(rect, _sea);
      sprite == null
          ? canvas.drawRect(rect, _fallback)
          : canvas.drawImageRect(
              sprite, MapContentDrawer.spriteSrc, rect, _terrain);
      if (fog.scouts.contains(cell)) canvas.drawRect(rect.deflate(1), _mark);
      canvas.drawRect(rect, _fog);
      final beacon = fog.beacons[cell];
      if (beacon != null) _drawBeacon(canvas, rect, beacon);
    }
    final scout = stage.image(UnitType.scout.iconPath);
    for (final cell in fog.scouts) {
      _token.draw(canvas, MapTokenTrip.restingRect(cell), scout,
          opacity: opacity);
    }
  }

  /// Draws the wreck [sprite] seen through the fog of [cell], with its
  /// halo, as the map draws it.
  void _drawBeacon(Canvas canvas, Rect cell, String sprite) {
    final halo = stage.glow(MapGlow.wreck);
    final image = stage.image(sprite);
    final src = MapContentDrawer.spriteSrc;
    if (halo != null) canvas.drawImageRect(halo, src, cell, _beacon);
    if (image == null) return;
    const inset = (cellSize - MapContentDrawer.contentSize) / 2;
    canvas.drawImageRect(image, src, cell.deflate(inset), _beacon);
  }

  static Rect _rectOf((int, int) cell) =>
      Rect.fromLTWH(cell.$1 * cellSize, cell.$2 * cellSize, cellSize, cellSize);
}
