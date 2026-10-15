import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../../../extensions/unit_type_extensions.dart';
import '../../../../theme/abyss_colors.dart';
import '../../../../theme/abyss_motion.dart';
import '../../map_content_drawer.dart';
import '../../token/map_token_drawer.dart';
import '../../token/map_token_trip.dart';
import '../map_effect.dart';
import 'map_strike.dart';
import 'strike_geometry.dart';
import 'strike_marks.dart';
import 'strike_timeline.dart';

/// A [MapStrike] placed on a map: each round's hit flashes the lair
/// white, shakes the map and floats up what each side lost, over the lair
/// and over the army's token; a defeated monster shrinks and fades over
/// the dimmed remains the still map shows.
class MapStrikeRun implements MapEffectRun {
  /// How long the lair flashes after a hit.
  static const flashLength = AbyssMotion.tap;

  /// How long the map shakes after a hit.
  static const shakeLength = AbyssMotion.quick;

  /// How far the map shakes, in logical pixels.
  static const shakeAmplitude = 3.0;

  /// Size a defeated monster shrinks to, as a share of its own.
  static const shrunk = 0.3;

  final MapStrike strike;
  final MapStage stage;
  final StrikeGeometry geometry;
  final StrikeTimeline timeline;

  final _token = MapTokenDrawer();
  final _marks = StrikeMarks();
  final _lair = Paint()..filterQuality = FilterQuality.medium;
  final _flash = Paint()..filterQuality = FilterQuality.medium;

  MapStrikeRun(this.strike, {required this.stage, required this.geometry})
      : timeline = StrikeTimeline(
          swim: geometry.origin == geometry.approach
              ? Duration.zero
              : MapTokenTrip.durationOf(geometry.origin, geometry.approach),
          hits: strike.rounds.length,
        );

  @override
  Duration get duration => timeline.total;

  @override
  Offset shakeAt(Duration elapsed) {
    for (var i = 0; i < strike.rounds.length; i++) {
      final since = timeline.sinceHit(i, elapsed);
      if (since == null || since >= shakeLength) continue;
      final p = since.inMicroseconds / shakeLength.inMicroseconds;
      return Offset(math.sin(p * 6 * math.pi) * shakeAmplitude * (1 - p), 0);
    }
    return Offset.zero;
  }

  @override
  void paint(Canvas canvas, Duration elapsed) {
    _paintLair(canvas, elapsed);
    final token = geometry.tokenRect(
      swim: timeline.swimAt(elapsed),
      reach: timeline.reachAt(elapsed),
      retreat: strike.victory ? 0 : timeline.outcomeAt(elapsed),
    );
    final opacity = 1 - AbyssMotion.exit.transform(timeline.vanishAt(elapsed));
    _token.draw(canvas, token, stage.image(strike.lead.iconPath),
        opacity: opacity);
    _marks.badge(canvas, token, strike.count, opacity);
    final army = geometry.tokenRect(swim: 1).topCenter;
    for (final (i, round) in strike.rounds.indexed) {
      if (!timeline.showsHit(i, elapsed)) continue;
      final progress = timeline.sinceHit(i, elapsed)!.inMicroseconds /
          AbyssMotion.fade.inMicroseconds;
      _loss(canvas, geometry.lairRect.topCenter, round.dealt, progress);
      _loss(canvas, army, round.taken, progress);
    }
  }

  void _loss(Canvas canvas, Offset from, int damage, double progress) {
    if (damage > 0) _marks.damage(canvas, from, damage, progress);
  }

  /// The monster: on a victory, alive over its dimmed remains until it
  /// shrinks and fades away; flashing white as each hit lands.
  void _paintLair(Canvas canvas, Duration elapsed) {
    final sprite = stage.image(strike.lairSprite);
    if (sprite == null) return;
    var body = geometry.lairRect;
    if (strike.victory) {
      final gone = AbyssMotion.exit.transform(timeline.outcomeAt(elapsed));
      body = Rect.fromCenter(
          center: body.center,
          width: body.width * (1 - (1 - shrunk) * gone),
          height: body.height * (1 - (1 - shrunk) * gone));
      _lair.color = Color.fromRGBO(0, 0, 0, 1 - gone);
      _draw(canvas, sprite, body, _lair);
    }
    final flash = _flashAt(elapsed);
    if (flash <= 0) return;
    _flash.colorFilter = ColorFilter.mode(
        AbyssColors.daylight.withValues(alpha: flash), BlendMode.srcIn);
    _draw(canvas, sprite, body, _flash);
  }

  double _flashAt(Duration elapsed) {
    for (var i = 0; i < strike.rounds.length; i++) {
      final since = timeline.sinceHit(i, elapsed);
      if (since == null || since >= flashLength) continue;
      return 0.8 * (1 - since.inMicroseconds / flashLength.inMicroseconds);
    }
    return 0;
  }

  static void _draw(Canvas canvas, ui.Image sprite, Rect body, Paint paint) {
    if (paint.color.a <= 0) return;
    canvas.drawImageRect(sprite, MapContentDrawer.spriteSrc, body, paint);
  }
}
