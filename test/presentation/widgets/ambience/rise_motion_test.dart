import 'package:abyss/presentation/widgets/ambience/rise_motion.dart';
import 'package:abyss/presentation/widgets/ambience/sprite_motion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts low and small, with a bright glow', () {
    final start = RiseMotion.at(0);
    expect(start.scale, lessThan(1));
    expect(start.dy, greaterThan(0));
    expect(start.glow, greaterThan(0.5));
    expect(start.pivot, SpritePivot.bottom);
  });

  test('overshoots on the way up', () {
    final peak = [
      for (var t = 0.0; t <= 1; t += 0.05) RiseMotion.at(t).scale,
    ].reduce((a, b) => a > b ? a : b);
    expect(peak, greaterThan(1));
  });

  test('the glow fades as it rises', () {
    expect(RiseMotion.at(0.5).glow, lessThan(RiseMotion.at(0.2).glow));
  });

  test('ends exactly at rest', () {
    final end = RiseMotion.at(1);
    expect(end.isRest, isTrue);
    expect(end.glow, 0);
  });
}
