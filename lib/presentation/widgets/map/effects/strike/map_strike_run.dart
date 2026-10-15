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
import '../map_jolt.dart';
import 'map_strike.dart';
import 'strike_geometry.dart';
import 'strike_marks.dart';
import 'strike_timeline.dart';

/// A [MapStrike] placed on a map: each round's hit flashes the target
/// white, shakes the map and floats up what each side lost, over the
/// target and over the army's token; a defeated monster shrinks and fades
/// over the dimmed remains the still map shows, a taken place lights up.
class MapStrikeRun implements MapEffectRun {
  /// How long the lair flashes after a hit.
  static const flashLength = AbyssMotion.tap;

  /// How long the map shakes after a hit.
  static const shakeLength = AbyssMotion.quick;

  /// How far the map shakes, in logical pixels.
  static const shakeAmplitude = 3.0;

  /// Size a defeated monster shrinks to, as a share of its own.
  static const shrunk = 0.3;

  /// Strongest light of a taken place, at the middle of the outcome.
  static const capturedGlow = 0.8;

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
  Offset shakeAt(Duration elapsed) => mapJolt(
      timeline.pace.sinceLastHit(elapsed),
      length: shakeLength,
      amplitude: shakeAmplitude);

  @override
  void paint(Canvas canvas, Duration elapsed) {
    _paintTarget(canvas, elapsed);
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
      final progress = timeline.pace.fadeOf(i, elapsed)!;
      _loss(canvas, geometry.lairRect.topCenter, round.dealt, progress);
      _loss(canvas, army, round.taken, progress);
    }
  }

  void _loss(Canvas canvas, Offset from, int damage, double progress) {
    if (damage > 0) _marks.damage(canvas, from, damage, progress);
  }

  /// The target, flashing white as each hit lands. A beaten monster stays
  /// alive over its dimmed remains until it shrinks and fades away; a
  /// taken place stays as the map draws it and lights up in cyan.
  void _paintTarget(Canvas canvas, Duration elapsed) {
    final sprite = stage.image(strike.targetSprite);
    if (sprite == null) return;
    var body = geometry.lairRect;
    final outcome = strike.victory ? timeline.outcomeAt(elapsed) : 0.0;
    if (strike.victory && strike.fades) {
      final gone = AbyssMotion.exit.transform(outcome);
      body = Rect.fromCenter(
          center: body.center,
          width: body.width * (1 - (1 - shrunk) * gone),
          height: body.height * (1 - (1 - shrunk) * gone));
      _lair.color = Color.fromRGBO(0, 0, 0, 1 - gone);
      _draw(canvas, sprite, body, _lair);
    }
    _tint(canvas, sprite, body, AbyssColors.daylight, _flashAt(elapsed));
    if (strike.victory && !strike.fades) {
      _tint(canvas, sprite, body, AbyssColors.biolumCyan,
          capturedGlow * math.sin(math.pi * outcome));
    }
  }

  /// Draws [sprite] over [body] all in [color], at [opacity].
  void _tint(Canvas canvas, ui.Image sprite, Rect body, Color color,
      double opacity) {
    if (opacity <= 0) return;
    _flash
      ..color = Color.fromRGBO(0, 0, 0, opacity)
      ..colorFilter = ColorFilter.mode(color, BlendMode.srcIn);
    _draw(canvas, sprite, body, _flash);
  }

  double _flashAt(Duration elapsed) {
    final since = timeline.pace.sinceLastHit(elapsed);
    if (since == null || since >= flashLength) return 0;
    return 0.8 * (1 - since.inMicroseconds / flashLength.inMicroseconds);
  }

  static void _draw(Canvas canvas, ui.Image sprite, Rect body, Paint paint) {
    if (paint.color.a <= 0) return;
    canvas.drawImageRect(sprite, MapContentDrawer.spriteSrc, body, paint);
  }
}
