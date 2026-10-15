import 'dart:math' as math;

import '../../../../theme/abyss_motion.dart';

/// When each step of an attack on a lair happens: the army's token swims
/// next to the lair, lunges at it once per hit, the outcome settles (the
/// monster fades away, or the token retreats), then the token vanishes.
///
/// A long fight lunges faster, so its hits keep within [roundsBudget].
class StrikeTimeline {
  /// The usual lunge: forward to the lair and back.
  static const usualLunge = AbyssMotion.eventStep;

  /// The quickest lunge of a very long fight.
  static const quickestLunge = Duration(milliseconds: 120);

  /// How long the lunges of a long fight last together.
  static const roundsBudget = Duration(seconds: 4);

  /// The defeated monster fading away, or the token retreating.
  static const outcome = AbyssMotion.fade;

  /// The token fading out at the end.
  static const vanish = AbyssMotion.quick;

  /// The swim next to the lair, nothing when the token starts there.
  final Duration swim;

  /// Number of lunges.
  final int hits;

  const StrikeTimeline({required this.swim, required this.hits});

  /// One lunge: forward to the lair and back.
  Duration get lunge => lungeFor(hits);

  /// The lunge of a fight of [hits] rounds: the usual one, shortened in
  /// a long fight so its rounds keep within [roundsBudget].
  static Duration lungeFor(int hits) {
    if (hits == 0 || usualLunge * hits <= roundsBudget) return usualLunge;
    final share = roundsBudget ~/ hits;
    return share < quickestLunge ? quickestLunge : share;
  }

  Duration get _outcomeStart => swim + lunge * hits;

  Duration get _vanishStart => _outcomeStart + outcome;

  /// How long the whole attack lasts.
  Duration get total => _vanishStart + vanish;

  /// When hit [index] lands, at the peak of its lunge.
  Duration hitAt(int index) => swim + lunge * index + lunge ~/ 2;

  /// How far along the swim is at [t], from 0 to 1.
  double swimAt(Duration t) => _share(t, Duration.zero, swim);

  /// How far forward a lunge reaches at [t]: 0 at rest, 1 at its peak.
  double reachAt(Duration t) {
    if (t < swim || t >= _outcomeStart) return 0;
    final within = (t - swim).inMicroseconds % lunge.inMicroseconds;
    return math.sin(math.pi * within / lunge.inMicroseconds);
  }

  /// How long ago hit [index] landed at [t], `null` before it.
  Duration? sinceHit(int index, Duration t) {
    final since = t - hitAt(index);
    return since.isNegative ? null : since;
  }

  /// Whether hit [index] still shows at [t]: from when it lands until
  /// the next one does, a [AbyssMotion.fade] at most.
  bool showsHit(int index, Duration t) {
    final since = sinceHit(index, t);
    if (since == null || since >= AbyssMotion.fade) return false;
    return index + 1 >= hits || sinceHit(index + 1, t) == null;
  }

  /// How far along the outcome is at [t], from 0 to 1.
  double outcomeAt(Duration t) => _share(t, _outcomeStart, outcome);

  /// How far the token has vanished at [t], from 0 to 1.
  double vanishAt(Duration t) => _share(t, _vanishStart, vanish);

  static double _share(Duration t, Duration start, Duration length) {
    if (length == Duration.zero) return t >= start ? 1 : 0;
    final share = (t - start).inMicroseconds / length.inMicroseconds;
    return share.clamp(0.0, 1.0);
  }
}
