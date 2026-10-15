import 'package:abyss/presentation/theme/abyss_motion.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/strike_timeline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const swim = Duration(milliseconds: 900);
  const timeline = StrikeTimeline(swim: swim, hits: 2);
  const lunge = StrikeTimeline.lunge;

  test('swims, lunges once per hit, settles the outcome, then vanishes',
      () {
    expect(timeline.total,
        swim + lunge * 2 + AbyssMotion.fade + AbyssMotion.quick);
    expect(timeline.swimAt(Duration.zero), 0);
    expect(timeline.swimAt(swim ~/ 2), closeTo(0.5, 1e-9));
    expect(timeline.swimAt(swim), 1);
  });

  test('each hit lands at the peak of its lunge', () {
    expect(timeline.hitAt(0), swim + lunge ~/ 2);
    expect(timeline.hitAt(1), swim + lunge + lunge ~/ 2);
    expect(timeline.reachAt(timeline.hitAt(0)), closeTo(1, 1e-9));
    expect(timeline.reachAt(timeline.hitAt(1)), closeTo(1, 1e-9));
    expect(timeline.reachAt(swim), closeTo(0, 1e-9));
    expect(timeline.reachAt(swim + lunge), closeTo(0, 1e-9));
    expect(timeline.reachAt(swim ~/ 2), 0);
  });

  test('tells how long ago a hit landed, null before it', () {
    expect(timeline.sinceHit(0, swim), isNull);
    expect(timeline.sinceHit(0, timeline.hitAt(0) + lunge),
        lunge);
  });

  test('the outcome follows the last lunge, the vanish ends it', () {
    final outcome = swim + lunge * 2;
    expect(timeline.outcomeAt(outcome), 0);
    expect(timeline.outcomeAt(outcome + AbyssMotion.fade), 1);
    expect(timeline.vanishAt(outcome + AbyssMotion.fade), 0);
    expect(timeline.vanishAt(timeline.total), 1);
  });

  test('without a swim, the first lunge starts at once', () {
    const still = StrikeTimeline(swim: Duration.zero, hits: 2);
    expect(still.swimAt(Duration.zero), 1);
    expect(still.hitAt(0), lunge ~/ 2);
  });
}
