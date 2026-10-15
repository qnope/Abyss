import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../../../../theme/abyss_colors.dart';
import '../../../../theme/abyss_motion.dart';
import '../../token/map_token_drawer.dart';
import '../map_effect.dart';
import 'map_siege.dart';
import 'siege_geometry.dart';
import 'siege_timeline.dart';

/// A [MapSiege] placed on a map: a red ring pulses around the place; the
/// attackers, red-ringed tokens, close in; on a victory a cyan shield
/// rises as they come and flashes as it pushes them back, on a defeat
/// they break in as the place flashes red and the map shakes.
class MapSiegeRun implements MapEffectRun {
  /// How far the map shakes, in logical pixels.
  static const shakeAmplitude = 4.0;

  final MapSiege siege;
  final MapStage stage;
  final SiegeGeometry geometry;
  final SiegeTimeline timeline = const SiegeTimeline();

  final _token = MapTokenDrawer();
  final _fill = Paint();
  final _line = Paint()..style = PaintingStyle.stroke;

  MapSiegeRun(this.siege, {required this.stage, required this.geometry});

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
    if (siege.victory || since.isNegative || since >= AbyssMotion.quick) {
      return Offset.zero;
    }
    final p = since.inMicroseconds / AbyssMotion.quick.inMicroseconds;
    return Offset(math.sin(p * 6 * math.pi) * shakeAmplitude * (1 - p), 0);
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
    if (!siege.victory && outcome > 0) {
      _fill.color =
          AbyssColors.error.withValues(alpha: 0.5 * math.sin(math.pi * outcome));
      canvas.drawCircle(center, radius * 1.1, _fill);
    }
    final opacity = 1 - AbyssMotion.exit.transform(outcome);
    final sprite = stage.image(siege.attackerSprite);
    for (var i = 0; i < SiegeGeometry.attackers; i++) {
      final rect = geometry.attackerRect(i,
          approach: timeline.approachAt(elapsed),
          pushed: siege.victory ? outcome : 0,
          breach: siege.victory ? 0 : outcome);
      _token.draw(canvas, rect, sprite,
          opacity: opacity, ring: AbyssColors.error);
    }
  }

  void _ring(Canvas canvas, double radius, Color color, double opacity) {
    if (opacity <= 0) return;
    _line
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 3;
    canvas.drawCircle(geometry.center, radius, _line);
  }
}
