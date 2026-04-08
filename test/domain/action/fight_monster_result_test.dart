import 'package:flutter_test/flutter_test.dart';
import 'package:abyss/domain/action/action_result.dart';
import 'package:abyss/domain/action/fight_monster_result.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/fight_result.dart';
import 'package:abyss/domain/resource/resource_type.dart';
import 'package:abyss/domain/unit/unit_type.dart';

void main() {
  group('FightMonsterResult', () {
    test('failure exposes isSuccess false and empty maps', () {
      const result = FightMonsterResult.failure('reason');

      expect(result.isSuccess, false);
      expect(result.reason, 'reason');
      expect(result.victory, false);
      expect(result.fight, isNull);
      expect(result.loot, isEmpty);
      expect(result.sent, isEmpty);
      expect(result.survivorsIntact, isEmpty);
      expect(result.wounded, isEmpty);
      expect(result.dead, isEmpty);
    });

    test('success preserves all fields and victory flag', () {
      const fight = FightResult(CombatSide.player, 3, [], [], [], 4, 0);
      const loot = {ResourceType.algae: 12, ResourceType.ore: 4};
      const sent = {UnitType.scout: 3, UnitType.harpoonist: 2};
      const intact = {UnitType.scout: 2};
      const wounded = {UnitType.harpoonist: 1};
      const dead = {UnitType.scout: 1, UnitType.harpoonist: 1};

      final result = FightMonsterResult.success(
        victory: true,
        fight: fight,
        loot: loot,
        sent: sent,
        survivorsIntact: intact,
        wounded: wounded,
        dead: dead,
      );

      expect(result.isSuccess, true);
      expect(result.reason, isNull);
      expect(result.victory, true);
      expect(result.fight, same(fight));
      expect(result.loot, loot);
      expect(result.sent, sent);
      expect(result.survivorsIntact, intact);
      expect(result.wounded, wounded);
      expect(result.dead, dead);
    });

    test('is assignable to an ActionResult variable', () {
      const FightMonsterResult fight = FightMonsterResult.failure('nope');
      const ActionResult result = fight;

      expect(result.isSuccess, false);
    });
  });
}
