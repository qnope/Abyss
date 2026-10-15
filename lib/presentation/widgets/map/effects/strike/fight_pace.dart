import 'dart:math' as math;

import '../../../../theme/abyss_motion.dart';

/// The pace of a fight played on the map from [start]: one lunge per
/// round, each hit landing at the peak of its lunge. A long fight lunges
/// faster, so its rounds keep within [roundsBudget].
class FightPace {
  /// The usual lunge: forward and back.
  static const usualLunge = AbyssMotion.eventStep;

  /// The quickest lunge of a very long fight.
  static const quickestLunge = Duration(milliseconds: 120);

  /// How long the lunges of a long fight last together.
  static const roundsBudget = Duration(seconds: 4);

  /// When the first lunge sets off.
  final Duration start;

  /// Number of rounds, one lunge each.
  final int rounds;

  const FightPace({required this.start, required this.rounds});

  /// The lunge of a fight of [rounds] rounds: the usual one, shortened in
  /// a long fight so its rounds keep within [roundsBudget].
  static Duration lungeFor(int rounds) {
    if (rounds == 0 || usualLunge * rounds <= roundsBudget) return usualLunge;
    final share = roundsBudget ~/ rounds;
    return share < quickestLunge ? quickestLunge : share;
  }

  /// One lunge of this fight.
  Duration get lunge => lungeFor(rounds);

  /// When the last lunge is over.
  Duration get end => start + lunge * rounds;

  /// When hit [index] lands, at the peak of its lunge.
  Duration hitAt(int index) => start + lunge * index + lunge ~/ 2;

  /// How far forward a lunge reaches at [t]: 0 at rest, 1 at its peak.
  double reachAt(Duration t) {
    if (t < start || t >= end) return 0;
    final within = (t - start).inMicroseconds % lunge.inMicroseconds;
    return math.sin(math.pi * within / lunge.inMicroseconds);
  }

  /// How long ago hit [index] landed at [t], `null` before it.
  Duration? sinceHit(int index, Duration t) {
    final since = t - hitAt(index);
    return since.isNegative ? null : since;
  }

  /// How long ago the latest hit landed at [t], `null` before the first.
  Duration? sinceLastHit(Duration t) {
    for (var i = rounds - 1; i >= 0; i--) {
      final since = sinceHit(i, t);
      if (since != null) return since;
    }
    return null;
  }

  /// Whether hit [index] still shows at [t]: from when it lands until
  /// the next one does, a [AbyssMotion.fade] at most.
  bool showsHit(int index, Duration t) {
    final since = sinceHit(index, t);
    if (since == null || since >= AbyssMotion.fade) return false;
    return index + 1 >= rounds || sinceHit(index + 1, t) == null;
  }

  /// How far hit [index] has gone through its [AbyssMotion.fade] at [t],
  /// from 0 as it lands; `null` before it lands.
  double? fadeOf(int index, Duration t) {
    final since = sinceHit(index, t);
    if (since == null) return null;
    return since.inMicroseconds / AbyssMotion.fade.inMicroseconds;
  }
}
