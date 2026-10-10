import 'package:abyss/domain/fight/combat_role.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/unit/unit_type.dart';
import 'package:flutter_test/flutter_test.dart';

Combatant _c(String key, CombatSide side) =>
    Combatant(side: side, typeKey: key, maxHp: 10, atk: 1, def: 1);

void main() {
  group('CombatRole.forUnit', () {
    test('maps each special unit to its role', () {
      expect(CombatRole.forUnit(UnitType.guardian), CombatRole.taunt);
      expect(CombatRole.forUnit(UnitType.domeBreaker), CombatRole.bossBreaker);
      expect(CombatRole.forUnit(UnitType.saboteur), CombatRole.armourPiercer);
      expect(CombatRole.forUnit(UnitType.scout), CombatRole.evasive);
      expect(CombatRole.forUnit(UnitType.harpoonist), CombatRole.none);
      expect(CombatRole.forUnit(UnitType.abyssAdmiral), CombatRole.none);
    });
  });

  group('CombatRole.of', () {
    test('reads the role of a player combatant from its type key', () {
      expect(
        CombatRole.of(_c('guardian', CombatSide.player)),
        CombatRole.taunt,
      );
    });

    test('monsters never have a role', () {
      expect(
        CombatRole.of(_c('monsterL1', CombatSide.monster)),
        CombatRole.none,
      );
    });

    test('the defenders of a base keep their role on the monsters side', () {
      expect(
        CombatRole.of(_c('guardian', CombatSide.monster)),
        CombatRole.taunt,
      );
      expect(
        CombatRole.of(_c(CombatRole.rampartKey, CombatSide.monster)),
        CombatRole.taunt,
      );
    });
  });
}
