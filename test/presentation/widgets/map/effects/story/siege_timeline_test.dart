import 'package:abyss/presentation/widgets/map/effects/strike/fight_pace.dart';
import 'package:abyss/presentation/widgets/map/effects/story/siege_timeline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const t = SiegeTimeline();
  final closed = SiegeTimeline.alert + SiegeTimeline.approach;

  test('the alert, the approach and the outcome follow each other', () {
    expect(t.total,
        SiegeTimeline.alert + SiegeTimeline.approach +
            SiegeTimeline.outcome + SiegeTimeline.rest);
    expect(t.alertAt(Duration.zero), 0);
    expect(t.approachAt(SiegeTimeline.alert), 0);
    expect(t.approachAt(closed), 1);
    expect(t.outcomeAt(closed), 0);
    expect(t.outcomeAt(t.total), 1);
  });

  test('the alert pulses, then rests', () {
    expect(t.alertAt(SiegeTimeline.alert ~/ 4), greaterThan(0));
    expect(t.alertAt(SiegeTimeline.alert), 0);
    expect(t.alertAt(t.total), 0);
  });

  test('without rounds, the outcome lands when the approach ends', () {
    expect(t.impact, closed);
  });

  test('the clashes come once the attackers are close, before the outcome',
      () {
    const fought = SiegeTimeline(rounds: 3);
    final lunge = FightPace.lungeFor(3);
    expect(fought.clashes.start, closed);
    expect(fought.clashes.hitAt(0), closed + lunge ~/ 2);
    expect(fought.impact, closed + lunge * 3);
    expect(fought.outcomeAt(fought.impact - lunge), 0);
    expect(fought.approachAt(fought.clashes.hitAt(0)), 1);
  });

  test('the siege lasts longer the more rounds its fight has', () {
    const short = SiegeTimeline(rounds: 2), long = SiegeTimeline(rounds: 6);
    expect(short.total, greaterThan(t.total));
    expect(long.total, greaterThan(short.total));
    expect(long.total - t.total, FightPace.lungeFor(6) * 6);
  });
}
