import 'dart:math' as math;

import 'package:abyss/presentation/theme/abyss_motion.dart';
import 'package:abyss/presentation/widgets/ambience/creature_undulation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const wave = CreatureUndulation.standard;
  final side = wave.grid + 1;
  final rest = wave.restVertices();

  /// The furthest any vertex of [row] goes from its rest place.
  double reachOfRow(int row) {
    var most = 0.0;
    for (var frame = 0; frame < wave.frames; frame++) {
      final moved = wave.verticesAt(frame);
      for (var col = 0; col < side; col++) {
        final i = row * side + col;
        most = math.max(most, (moved[i] - rest[i]).distance);
      }
    }
    return most;
  }

  test('lays a regular grid over the sprite at rest', () {
    expect(rest, hasLength(side * side));
    expect(rest.first, Offset.zero);
    expect(rest.last, const Offset(1, 1));
    expect(rest[1].dx, closeTo(1 / wave.grid, 1e-9));
  });

  test('loops seamlessly: frame N is frame 0 again', () {
    expect(wave.verticesAt(wave.frames), wave.verticesAt(0));
    expect(wave.verticesAt(wave.frames + 3), wave.verticesAt(3));
  });

  test('the head stays put while the bottom moves the most', () {
    expect(reachOfRow(0), lessThan(0.005));
    for (var row = 1; row <= wave.grid; row++) {
      expect(reachOfRow(row), greaterThan(reachOfRow(row - 1)));
    }
    expect(reachOfRow(wave.grid), greaterThan(0.03));
  });

  test('never moves a vertex further than its reach', () {
    for (var frame = 0; frame < wave.frames; frame++) {
      final moved = wave.verticesAt(frame);
      for (var i = 0; i < moved.length; i++) {
        expect((moved[i].dx - rest[i].dx).abs(), lessThanOrEqualTo(wave.reach));
        expect((moved[i].dy - rest[i].dy).abs(), lessThanOrEqualTo(wave.reach));
      }
    }
  });

  test('two triangles cover each square of the grid', () {
    final triangles = wave.triangles();
    expect(triangles, hasLength(wave.grid * wave.grid * 6));
    expect(triangles.reduce(math.max), side * side - 1);
  });

  group('frameAt', () {
    final cycle = AbyssMotion.swimCycle.inMicroseconds / 1e6;

    test('goes through every frame once per swim cycle', () {
      expect(wave.frameAt(0), 0);
      expect(wave.frameAt(cycle / wave.frames * 1.5), 1);
      expect(wave.frameAt(cycle * 0.999), wave.frames - 1);
      expect(wave.frameAt(cycle), 0);
    });

    test('is shifted by the phase of the sprite', () {
      expect(wave.frameAt(0, phase: 0.5), wave.frames ~/ 2);
      expect(wave.frameAt(cycle / 2, phase: 0.5), 0);
    });

    test('stays on one frame while the clock is frozen', () {
      expect(wave.frameAt(7.3, phase: 0.2), wave.frameAt(7.3, phase: 0.2));
    });
  });
}
