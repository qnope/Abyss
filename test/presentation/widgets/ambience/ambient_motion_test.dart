import 'package:abyss/presentation/theme/abyss_motion.dart';
import 'package:abyss/presentation/widgets/ambience/ambient_motion.dart';
import 'package:abyss/presentation/widgets/ambience/sprite_motion.dart';
import 'package:flutter_test/flutter_test.dart';

const _degree = 3.141592653589793 / 180;

/// Every pose of [motion] sampled over one ambient loop.
Iterable<SpriteMotion> _samples(AmbientMotion motion, {double phase = 0}) {
  final loop = AbyssMotion.ambientLoop.inMilliseconds / 1000;
  return [
    for (var i = 0; i <= 600; i++) motion.at(loop * i / 600, phase: phase),
  ];
}

void main() {
  test('still never moves', () {
    for (final pose in _samples(AmbientMotion.still)) {
      expect(pose, SpriteMotion.rest);
    }
  });

  test('bob floats within 3% of the size', () {
    final dys = _samples(AmbientMotion.bob).map((p) => p.dy);
    expect(dys.reduce((a, b) => a > b ? a : b), closeTo(0.03, 1e-3));
    expect(dys.reduce((a, b) => a < b ? a : b), closeTo(-0.03, 1e-3));
  });

  test('breathe scales between 1 and 1.04', () {
    final scales = _samples(AmbientMotion.breathe).map((p) => p.scale);
    expect(scales.reduce((a, b) => a > b ? a : b), closeTo(1.04, 1e-3));
    expect(scales.reduce((a, b) => a < b ? a : b), closeTo(1, 1e-3));
  });

  test('sway turns within 3 degrees around the bottom', () {
    final poses = _samples(AmbientMotion.sway);
    final angles = poses.map((p) => p.rotation);
    expect(angles.reduce((a, b) => a > b ? a : b), closeTo(3 * _degree, 1e-3));
    expect(angles.reduce((a, b) => a < b ? a : b), closeTo(-3 * _degree, 1e-3));
    expect(poses.first.pivot, SpritePivot.bottom);
  });

  test('pulse glows between 0.2 and 0.6, others do not glow', () {
    final glows = _samples(AmbientMotion.pulse).map((p) => p.glow);
    expect(glows.reduce((a, b) => a > b ? a : b), closeTo(0.6, 1e-3));
    expect(glows.reduce((a, b) => a < b ? a : b), closeTo(0.2, 1e-3));
    expect(AmbientMotion.bob.at(1).glow, 0);
  });

  test('every motion loops seamlessly over the ambient loop', () {
    final loop = AbyssMotion.ambientLoop.inMilliseconds / 1000;
    for (final motion in AmbientMotion.values) {
      for (final t in [0.0, 1.3, 7.9]) {
        final a = motion.at(t, phase: 0.4);
        final b = motion.at(t + loop, phase: 0.4);
        expect(b.dy, closeTo(a.dy, 1e-9));
        expect(b.scale, closeTo(a.scale, 1e-9));
        expect(b.rotation, closeTo(a.rotation, 1e-9));
        expect(b.glow, closeTo(a.glow, 1e-9));
      }
    }
  });

  test('a phase shifts the pose, a whole phase changes nothing', () {
    final a = AmbientMotion.bob.at(1, phase: 0);
    expect(AmbientMotion.bob.at(1, phase: 0.25).dy, isNot(closeTo(a.dy, 1e-3)));
    expect(AmbientMotion.bob.at(1, phase: 1).dy, closeTo(a.dy, 1e-9));
  });

  group('phaseOf', () {
    test('is deterministic and within [0, 1)', () {
      for (var x = -5; x < 20; x++) {
        for (var y = -5; y < 20; y++) {
          final p = AmbientMotion.phaseOf(x, y);
          expect(p, inInclusiveRange(0, 1));
          expect(p, lessThan(1));
          expect(AmbientMotion.phaseOf(x, y), p);
        }
      }
    });

    test('differs between neighbours', () {
      final p = AmbientMotion.phaseOf(4, 7);
      for (final (dx, dy) in [
        (1, 0),
        (-1, 0),
        (0, 1),
        (0, -1),
        (1, 1),
        (1, -1),
      ]) {
        final q = AmbientMotion.phaseOf(4 + dx, 7 + dy);
        final gap = (p - q).abs();
        expect(gap < 0.5 ? gap : 1 - gap, greaterThan(0.05));
      }
    });
  });
}
