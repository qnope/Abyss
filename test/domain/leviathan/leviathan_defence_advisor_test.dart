import 'package:abyss/domain/leviathan/leviathan_defence_advisor.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'leviathan_scene.dart';

void main() {
  group('LeviathanDefenceAdvisor.unitsFor', () {
    test('asks for defenders on an empty level 2', () {
      final war = leviathanScene();
      final needed = LeviathanDefenceAdvisor.unitsFor(war.game, war.human, 2);
      expect(needed, isNotNull);
      expect(needed, greaterThan(0));
    });

    test('the advised army holds: no more is asked once it stands', () {
      final war = leviathanScene();
      final needed = LeviathanDefenceAdvisor.unitsFor(war.game, war.human, 2)!;
      war.put(war.human, 2, {UnitType.harpoonist: needed});
      expect(LeviathanDefenceAdvisor.unitsFor(war.game, war.human, 2), needed);
    });

    test('counts the units already there', () {
      final war = leviathanScene();
      war.put(war.human, 2, {UnitType.guardian: 200, UnitType.harpoonist: 200});
      expect(LeviathanDefenceAdvisor.unitsFor(war.game, war.human, 2), 400);
    });

    test('gives the same answer for the same game', () {
      final war = leviathanScene();
      war.put(war.human, 2, {UnitType.harpoonist: 2});
      final first = LeviathanDefenceAdvisor.unitsFor(war.game, war.human, 2);
      expect(LeviathanDefenceAdvisor.unitsFor(war.game, war.human, 2), first);
    });
  });
}
