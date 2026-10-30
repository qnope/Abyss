import 'dart:math' as math;

import 'package:abyss/domain/unit/unit_type.dart';
import 'package:abyss/presentation/widgets/ambience/sprite_motion.dart';
import 'package:abyss/presentation/widgets/army/army_squad_pose.dart';
import 'package:abyss/presentation/widgets/army/squad_size.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const harpoonist = UnitType.harpoonist;
  final instants = [for (var k = 0; k < 40; k++) k * .37];

  group('ArmySquadPose.soldier', () {
    test('no two soldiers of a squad move in step', () {
      for (final seconds in [1.0, 2.5]) {
        final poses = {
          for (var figure = 0; figure < SquadSize.max; figure++)
            ArmySquadPose.soldier(harpoonist, figure, seconds),
        };
        expect(poses, hasLength(SquadSize.max), reason: '$seconds s');
      }
    });

    test('two squads do not move in step either', () {
      expect(ArmySquadPose.soldier(UnitType.scout, 0, 1),
          isNot(ArmySquadPose.soldier(harpoonist, 0, 1)));
    });

    test('breathes and bobs a little, around its feet, never leaning', () {
      for (final seconds in instants) {
        for (var figure = 0; figure < SquadSize.max; figure++) {
          final pose = ArmySquadPose.soldier(harpoonist, figure, seconds);
          expect(pose.scale, inInclusiveRange(1, 1.04));
          expect(pose.dy.abs(), lessThanOrEqualTo(.015));
          expect(pose.rotation, 0);
          expect(pose.pivot, SpritePivot.bottom);
        }
      }
    });

    test('moves over time and loops with the ambience', () {
      final now = ArmySquadPose.soldier(harpoonist, 2, 1);
      expect(ArmySquadPose.soldier(harpoonist, 2, 2), isNot(now));
      final loop = ArmySquadPose.soldier(harpoonist, 2, 61);
      expect(loop.scale, closeTo(now.scale, 1e-9));
      expect(loop.dy, closeTo(now.dy, 1e-9));
    });
  });

  group('ArmySquadPose.banner', () {
    test('sways gently around the foot of its pole', () {
      for (final seconds in instants) {
        final pose = ArmySquadPose.banner(harpoonist, seconds);
        expect(pose.rotation.abs(), lessThanOrEqualTo(2 * math.pi / 180));
        expect(pose.scale, 1);
        expect(pose.dy, 0);
        expect(pose.pivot, SpritePivot.bottom);
      }
      expect(ArmySquadPose.banner(harpoonist, 1),
          isNot(ArmySquadPose.banner(harpoonist, 2)));
    });

    test('the banners do not sway in step', () {
      final poses = {
        for (final type in UnitType.values) ArmySquadPose.banner(type, 1),
      };
      expect(poses, hasLength(UnitType.values.length));
    });
  });
}
