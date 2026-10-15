import 'package:abyss/presentation/theme/abyss_motion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('short feedback lasts between 150 and 400 ms', () {
    for (final d in [
      AbyssMotion.tap,
      AbyssMotion.quick,
      AbyssMotion.emphasis,
    ]) {
      expect(d.inMilliseconds, inInclusiveRange(150, 400));
    }
  });

  test('ambient cycles last several seconds and divide the loop', () {
    for (final d in AbyssMotion.ambientCycles) {
      expect(d.inSeconds, greaterThanOrEqualTo(2));
      expect(AbyssMotion.ambientLoop.inMicroseconds % d.inMicroseconds, 0);
    }
  });

  test('the ambient frame caps clocks near 30 per second', () {
    final perSecond = 1e6 / AbyssMotion.ambientFrame.inMicroseconds;
    expect(perSecond, closeTo(30, 1));
  });

  test('reduced motion makes any duration instant', () {
    expect(
      AbyssMotion.orInstant(AbyssMotion.swim, reduced: true),
      Duration.zero,
    );
    expect(
      AbyssMotion.orInstant(AbyssMotion.swim, reduced: false),
      AbyssMotion.swim,
    );
  });

  test('a longer swim takes longer, within bounds', () {
    expect(AbyssMotion.swimOver(0), AbyssMotion.swim);
    expect(AbyssMotion.swimOver(1), AbyssMotion.swim);
    expect(AbyssMotion.swimOver(4), AbyssMotion.swim * 2);
    expect(AbyssMotion.swimOver(100), AbyssMotion.swim * 3);
  });
}
