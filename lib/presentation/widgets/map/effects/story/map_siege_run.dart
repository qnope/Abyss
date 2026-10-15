import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../../../../theme/abyss_colors.dart';
import '../../../../theme/abyss_motion.dart';
import '../../token/map_token_drawer.dart';
import '../map_effect.dart';
import '../map_jolt.dart';
import '../strike/strike_marks.dart';
import 'map_siege.dart';
import 'siege_geometry.dart';
import 'siege_timeline.dart';

/// A [MapSiege] placed on a map: a red ring pulses around the place; the
/// attackers, red-ringed tokens, close in; at each round of the fight
/// they lunge at it, it flashes, the map shakes lightly and what each
/// side lost floats up; then on a victory a cyan shield flashes as it
/// pushes them back, on a defeat they break in as the place flashes red
/// and the map shakes.
class MapSiegeRun implements MapEffectRun {
  /// How far the map shakes as the attackers break in, in logical pixels.
  static const shakeAmplitude = 4.0;

  /// How far the map shakes at each clash, in logical pixels.
  static const clashShakeAmplitude = 2.0;

  /// How long the place flashes after a clash.
  static const flashLength = AbyssMotion.tap;

  final MapSiege siege;
  final MapStage stage;
  final SiegeGeometry geometry;
  final SiegeTimeline timeline;

  final _token = MapTokenDrawer();
  final _marks = StrikeMarks();
  final _fill = Paint();
  final _line = Paint()..style = PaintingStyle.stroke;

  MapSiegeRun(this.siege, {required this.stage, required this.geometry})
      : timeline = SiegeTimeline(rounds: siege.rounds.length);

  @override
  Duration get duration => timeline.total;

  /// How far the shield has risen at [elapsed], from 0 to 1; never on a
  /// defeat.
  double shieldAt(Duration elapsed) {
    if (!siege.victory) return 0;
    final rise = AbyssMotion.enter.transform(timeline.approachAt(elapsed));
    return rise * (1 - AbyssMotion.exit.transform(timeline.outcomeAt(elapsed)));
  }

  @override
  Offset shakeAt(Duration elapsed) {
    final since = elapsed - timeline.impact;
    if (!siege.victory && !since.isNegative) {
      return mapJolt(since,
          length: AbyssMotion.quick, amplitude: shakeAmplitude);
    }
    return mapJolt(timeline.clashes.sinceLastHit(elapsed),
        length: AbyssMotion.quick, amplitude: clashShakeAmplitude);
  }

  @override
  void paint(Canvas canvas, Duration elapsed) {
    final center = geometry.center, radius = geometry.radius;
    _ring(canvas, radius * 1.15, AbyssColors.error, timeline.alertAt(elapsed));
    final outcome = timeline.outcomeAt(elapsed);
    final shield = shieldAt(elapsed);
    if (shield > 0) {
      final flash = siege.victory ? math.sin(math.pi * outcome) : 0.0;
      _fill.color = AbyssColors.biolumCyan.withValues(alpha: 0.15 * shield);
      canvas.drawCircle(center, radius * 1.1 * shield, _fill);
      _ring(canvas, radius * 1.1 * shield, AbyssColors.biolumCyan,
          math.min(1, shield * 0.8 + flash));
    }
    _flash(canvas, AbyssColors.daylight, 0.4 * _clashFlashAt(elapsed));
    if (!siege.victory) {
      _flash(canvas, AbyssColors.error, 0.5 * math.sin(math.pi * outcome));
    }
    final opacity = 1 - AbyssMotion.exit.transform(outcome);
    final sprite = stage.image(siege.attackerSprite);
    for (var i = 0; i < SiegeGeometry.attackers; i++) {
      final rect = geometry.attackerRect(i,
          approach: timeline.approachAt(elapsed),
          reach: timeline.clashes.reachAt(elapsed),
          pushed: siege.victory ? outcome : 0,
          breach: siege.victory ? 0 : outcome);
      _token.draw(canvas, rect, sprite,
          opacity: opacity, ring: AbyssColors.error);
    }
    _paintLosses(canvas, elapsed);
  }

  /// What each side lost in the round showing at [elapsed]: what the
  /// defenders dealt over the attackers, what they took over the place.
  void _paintLosses(Canvas canvas, Duration elapsed) {
    final clashes = timeline.clashes;
    final attackers = geometry.attackerRect(0, approach: 1).topCenter;
    final place = geometry.center - Offset(0, geometry.radius);
    for (final (i, round) in siege.rounds.indexed) {
      if (!clashes.showsHit(i, elapsed)) continue;
      final progress = clashes.fadeOf(i, elapsed)!;
      _loss(canvas, attackers, round.dealt, progress);
      _loss(canvas, place, round.taken, progress);
    }
  }

  void _loss(Canvas canvas, Offset from, int damage, double progress) {
    if (damage > 0) _marks.damage(canvas, from, damage, progress);
  }

  double _clashFlashAt(Duration elapsed) {
    final since = timeline.clashes.sinceLastHit(elapsed);
    if (since == null || since >= flashLength) return 0;
    return 1 - since.inMicroseconds / flashLength.inMicroseconds;
  }

  void _flash(Canvas canvas, Color color, double opacity) {
    if (opacity <= 0) return;
    _fill.color = color.withValues(alpha: opacity);
    canvas.drawCircle(geometry.center, geometry.radius * 1.1, _fill);
  }

  void _ring(Canvas canvas, double radius, Color color, double opacity) {
    if (opacity <= 0) return;
    _line
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 3;
    canvas.drawCircle(geometry.center, radius, _line);
  }
}
