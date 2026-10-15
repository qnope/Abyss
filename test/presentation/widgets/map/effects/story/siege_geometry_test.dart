import 'package:abyss/presentation/widgets/map/effects/story/siege_geometry.dart';
import 'package:abyss/presentation/widgets/map/map_content_drawer.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const base = SiegeGeometry(place: (5, 5));

  double distance(Rect token) => (token.center - base.center).distance;

  test('the place is the middle of its cells', () {
    expect(base.center, const Offset(5.5 * cellSize, 5.5 * cellSize));
    expect(const SiegeGeometry(place: (6, 4), span: 2).center,
        const Offset(7 * cellSize, 5 * cellSize));
  });

  test('the attackers close in from around the place', () {
    for (var i = 0; i < SiegeGeometry.attackers; i++) {
      final far = base.attackerRect(i, approach: 0);
      final near = base.attackerRect(i, approach: 1);
      expect(distance(far), greaterThan(distance(near)));
      expect(distance(near), greaterThan(base.radius));
    }
    expect(base.attackerRect(0, approach: 1).center,
        isNot(base.attackerRect(1, approach: 1).center));
  });

  test('lunging, they come closer without reaching the place', () {
    final near = distance(base.attackerRect(0, approach: 1));
    final lunged = distance(base.attackerRect(0, approach: 1, reach: 1));
    expect(lunged, lessThan(near));
    expect(lunged, greaterThan(base.radius));
  });

  test('repelled, they are pushed back; winning, they reach the place', () {
    final near = distance(base.attackerRect(0, approach: 1));
    expect(distance(base.attackerRect(0, approach: 1, pushed: 1)),
        greaterThan(near));
    expect(distance(base.attackerRect(0, approach: 1, breach: 1)),
        lessThan(base.radius));
  });
}
