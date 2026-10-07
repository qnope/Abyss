import 'dart:math';

import 'package:abyss/domain/action/fight_monster_action.dart';
import 'package:abyss/domain/action/recruit_unit_action.dart';
import 'package:abyss/domain/action/upgrade_building_action.dart';
import 'package:abyss/domain/building/building_type.dart';
import 'package:abyss/domain/script/action_codec.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActionCodec', () {
    test('reads a building upgrade', () {
      final action = ActionCodec.decode(
        <String, Object?>{'do': 'upgrade', 'building': 'algaeFarm'},
      )(Random(1));

      expect(action, isA<UpgradeBuildingAction>());
      expect((action as UpgradeBuildingAction).buildingType,
          BuildingType.algaeFarm);
    });

    test('reads a recruitment', () {
      final action = ActionCodec.decode(<String, Object?>{
        'do': 'recruit',
        'unit': 'guardian',
        'count': 4,
      })(Random(1)) as RecruitUnitAction;

      expect(action.unitType, UnitType.guardian);
      expect(action.quantity, 4);
    });

    test('hands the seeded generator to a fight', () {
      final random = Random(1);
      final action = ActionCodec.decode(<String, Object?>{
        'do': 'fight',
        'x': 3,
        'y': 4,
        'units': <String, Object?>{'harpoonist': 5},
      })(random) as FightMonsterAction;

      expect(action.random, same(random));
      expect(action.level, 1);
      expect(action.selectedUnits, <UnitType, int>{UnitType.harpoonist: 5});
    });

    test('rejects an unknown verb or value right away', () {
      expect(
        () => ActionCodec.decode(<String, Object?>{'do': 'dance'}),
        throwsFormatException,
      );
      expect(
        () => ActionCodec.decode(
          <String, Object?>{'do': 'upgrade', 'building': 'castle'},
        ),
        throwsFormatException,
      );
      expect(
        () => ActionCodec.decode(<String, Object?>{'do': 'explore', 'x': 1}),
        throwsFormatException,
      );
    });
  });
}
