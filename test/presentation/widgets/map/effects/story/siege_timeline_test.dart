import 'package:abyss/presentation/widgets/map/effects/story/siege_timeline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const t = SiegeTimeline();

  test('the alert, the approach and the outcome follow each other', () {
    expect(t.total,
        SiegeTimeline.alert + SiegeTimeline.approach +
            SiegeTimeline.outcome + SiegeTimeline.rest);
    expect(t.alertAt(Duration.zero), 0);
    expect(t.approachAt(SiegeTimeline.alert), 0);
    expect(t.approachAt(SiegeTimeline.alert + SiegeTimeline.approach), 1);
    expect(t.outcomeAt(SiegeTimeline.alert + SiegeTimeline.approach), 0);
    expect(t.outcomeAt(t.total), 1);
  });

  test('the alert pulses, then rests', () {
    expect(t.alertAt(SiegeTimeline.alert ~/ 4), greaterThan(0));
    expect(t.alertAt(SiegeTimeline.alert), 0);
    expect(t.alertAt(t.total), 0);
  });

  test('the outcome lands when the approach ends', () {
    expect(t.impact, SiegeTimeline.alert + SiegeTimeline.approach);
  });
}
