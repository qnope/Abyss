import 'package:abyss/presentation/theme/abyss_motion.dart';
import 'package:abyss/presentation/widgets/map/effects/strike/fight_pace.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const start = Duration(seconds: 1);
  const pace = FightPace(start: start, rounds: 3);
  const lunge = AbyssMotion.eventStep;

  test('its rounds follow each other from its start', () {
    expect(pace.lunge, lunge);
    expect(pace.end, start + lunge * 3);
    expect(pace.hitAt(0), start + lunge ~/ 2);
    expect(pace.hitAt(2), start + lunge * 2 + lunge ~/ 2);
  });

  test('a lunge reaches out only between its start and its end', () {
    expect(pace.reachAt(start - lunge), 0);
    expect(pace.reachAt(pace.hitAt(1)), closeTo(1, 1e-9));
    expect(pace.reachAt(pace.end), 0);
  });

  test('tells how long ago the latest hit landed, null before the first',
      () {
    expect(pace.sinceLastHit(start), isNull);
    expect(pace.sinceLastHit(pace.hitAt(0)), Duration.zero);
    expect(pace.sinceLastHit(pace.hitAt(2) + lunge), lunge);
  });

  test('tells how far a hit has faded, null before it lands', () {
    expect(pace.fadeOf(0, start), isNull);
    expect(pace.fadeOf(0, pace.hitAt(0)), 0);
    expect(pace.fadeOf(0, pace.hitAt(0) + AbyssMotion.fade ~/ 2),
        closeTo(0.5, 1e-9));
  });

  test('a fight without rounds takes no time', () {
    const none = FightPace(start: start, rounds: 0);
    expect(none.end, start);
    expect(none.sinceLastHit(start * 3), isNull);
  });
}
