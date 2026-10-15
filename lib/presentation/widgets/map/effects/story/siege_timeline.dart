import 'dart:math' as math;

import '../../../../theme/abyss_motion.dart';
import '../strike/fight_pace.dart';

/// When each step of a siege happens: an alert rings around the place
/// besieged, the attackers close in, clash with its defenders once per
/// round of the fight, the outcome lands (they are pushed back, or they
/// break in), then the map rests a moment.
class SiegeTimeline {
  /// The alert ringing twice around the place.
  static final alert = AbyssMotion.eventStep * 2;

  /// The attackers closing in.
  static const approach = AbyssMotion.swim;

  /// The attackers pushed back, or breaking in.
  static const outcome = AbyssMotion.fade;

  /// The rest before what comes next.
  static const rest = AbyssMotion.storyPause;

  /// Number of rounds of the fight, one clash each.
  final int rounds;

  const SiegeTimeline({this.rounds = 0});

  /// The clashes, once the attackers are close.
  FightPace get clashes => FightPace(start: alert + approach, rounds: rounds);

  /// When the outcome lands, after the last clash.
  Duration get impact => clashes.end;

  /// How long the whole siege lasts.
  Duration get total => impact + outcome + rest;

  /// How bright the alert is at [t]: two pulses, then nothing.
  double alertAt(Duration t) {
    if (t >= alert) return 0;
    return math.sin(2 * math.pi * _share(t, Duration.zero, alert)).abs();
  }

  /// How far the attackers have closed in at [t], from 0 to 1.
  double approachAt(Duration t) => _share(t, alert, approach);

  /// How far along the outcome is at [t], from 0 to 1.
  double outcomeAt(Duration t) => _share(t, impact, outcome);

  static double _share(Duration t, Duration start, Duration length) {
    final share = (t - start).inMicroseconds / length.inMicroseconds;
    return share.clamp(0.0, 1.0);
  }
}
