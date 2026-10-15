import '../../../../theme/abyss_motion.dart';
import 'fight_pace.dart';

/// When each step of an attack on a lair happens: the army's token swims
/// next to the lair, lunges at it once per hit, the outcome settles (the
/// monster fades away, or the token retreats), then the token vanishes.
///
/// A long fight lunges faster, so its hits keep within [roundsBudget].
class StrikeTimeline {
  /// The usual lunge: forward to the lair and back.
  static const usualLunge = FightPace.usualLunge;

  /// The quickest lunge of a very long fight.
  static const quickestLunge = FightPace.quickestLunge;

  /// How long the lunges of a long fight last together.
  static const roundsBudget = FightPace.roundsBudget;

  /// The defeated monster fading away, or the token retreating.
  static const outcome = AbyssMotion.fade;

  /// The token fading out at the end.
  static const vanish = AbyssMotion.quick;

  /// The swim next to the lair, nothing when the token starts there.
  final Duration swim;

  /// Number of lunges.
  final int hits;

  const StrikeTimeline({required this.swim, required this.hits});

  /// The lunges at the lair, once the token is beside it.
  FightPace get pace => FightPace(start: swim, rounds: hits);

  /// One lunge: forward to the lair and back.
  Duration get lunge => pace.lunge;

  /// The lunge of a fight of [hits] rounds: the usual one, shortened in
  /// a long fight so its rounds keep within [roundsBudget].
  static Duration lungeFor(int hits) => FightPace.lungeFor(hits);

  Duration get _outcomeStart => pace.end;

  Duration get _vanishStart => _outcomeStart + outcome;

  /// How long the whole attack lasts.
  Duration get total => _vanishStart + vanish;

  /// When hit [index] lands, at the peak of its lunge.
  Duration hitAt(int index) => pace.hitAt(index);

  /// How far along the swim is at [t], from 0 to 1.
  double swimAt(Duration t) => _share(t, Duration.zero, swim);

  /// How far forward a lunge reaches at [t]: 0 at rest, 1 at its peak.
  double reachAt(Duration t) => pace.reachAt(t);

  /// How long ago hit [index] landed at [t], `null` before it.
  Duration? sinceHit(int index, Duration t) => pace.sinceHit(index, t);

  /// Whether hit [index] still shows at [t]: from when it lands until
  /// the next one does, a [AbyssMotion.fade] at most.
  bool showsHit(int index, Duration t) => pace.showsHit(index, t);

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
