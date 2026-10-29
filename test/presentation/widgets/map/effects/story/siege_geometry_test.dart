import 'package:abyss/presentation/widgets/map/effects/story/siege_geometry.dart';
import 'package:abyss/presentation/widgets/map/map_content_drawer.dart';
import 'package:abyss/presentation/widgets/map/map_projection.dart';
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

  test("the place's circle goes through the corners of its cells, which "
      'the projection lays through the vertices of its diamonds', () {
    for (final geometry in [base, const SiegeGeometry(place: (6, 4), span: 2)]) {
      final corner = Offset(geometry.place.$1 * cellSize,
          geometry.place.$2 * cellSize);
      expect(geometry.radius,
          closeTo((corner - geometry.center).distance, 1e-9));
    }
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

  test('seen on screen, none closes in from behind the place, where they '
      'would hide its sprite', () {
    for (final geometry in [base, const SiegeGeometry(place: (5, 5), span: 2)]) {
      final centre = MapProjection.toScreen(geometry.center);
      for (var i = 0; i < SiegeGeometry.attackers; i++) {
        final near = geometry.attackerRect(i, approach: 1).center;
        final off = MapProjection.toScreen(near) - centre;
        expect(off.dy > 0 || off.dx.abs() > off.dy.abs(), isTrue,
            reason: 'attacker $i comes from the front or from a side');
      }
    }
  });
}
