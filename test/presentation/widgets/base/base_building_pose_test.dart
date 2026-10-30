import 'package:abyss/presentation/theme/abyss_motion.dart';
import 'package:abyss/presentation/widgets/ambience/sprite_motion.dart';
import 'package:abyss/presentation/widgets/base/base_building_pose.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cycle = AbyssMotion.breatheCycle.inMicroseconds / 1e6;

  test('a building that does not breathe nor rise stands as drawn', () {
    for (final seconds in [0.0, 1.3, cycle / 2]) {
      expect(baseBuildingPose(breathing: false, seconds: seconds).isRest,
          isTrue);
    }
  });

  test('a breathing building swells and settles on its foot', () {
    final swollen =
        baseBuildingPose(breathing: true, seconds: cycle / 2, phase: 0);
    expect(swollen.scale, greaterThan(1));
    expect(swollen.pivot, SpritePivot.bottom);
    expect(baseBuildingPose(breathing: true, seconds: 0, phase: 0).scale,
        closeTo(1, 1e-9));
  });

  test('neighbours breathe out of step', () {
    final a = baseBuildingPose(breathing: true, seconds: 1, phase: 0.1);
    final b = baseBuildingPose(breathing: true, seconds: 1, phase: 0.6);
    expect(a.scale, isNot(closeTo(b.scale, 1e-6)));
  });

  test('a building whose level went up pops from small and low', () {
    final start = baseBuildingPose(breathing: false, seconds: 0, rise: 0);
    expect(start.scale, lessThan(1));
    expect(start.dy, greaterThan(0));
    expect(start.glow, greaterThan(0));
    final end = baseBuildingPose(breathing: false, seconds: 0, rise: 1);
    expect(end.scale, closeTo(1, 1e-9));
    expect(end.dy, closeTo(0, 1e-9));
  });

  test('a breathing building pops as it breathes', () {
    final pose = baseBuildingPose(
        breathing: true, seconds: cycle / 2, phase: 0, rise: 0);
    expect(pose.scale, lessThan(1));
    expect(pose.scale, greaterThan(0.8));
  });
}
