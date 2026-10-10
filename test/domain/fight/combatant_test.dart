import 'package:flutter_test/flutter_test.dart';

import 'package:abyss/domain/fight/combat_role.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/map/monster_family.dart';

Combatant _c(String key, CombatSide side) =>
    Combatant(side: side, typeKey: key, maxHp: 10, atk: 1, def: 1);

void main() {
  group('Combatant', () {
    test('defaults currentHp to maxHp', () {
      final Combatant c = Combatant(
        side: CombatSide.player,
        typeKey: 'scout',
        maxHp: 12,
        atk: 3,
        def: 1,
      );

      expect(c.currentHp, 12);
      expect(c.isAlive, isTrue);
    });

    test('isBoss defaults to false', () {
      final Combatant c = Combatant(
        side: CombatSide.player,
        typeKey: 'scout',
        maxHp: 10,
        atk: 3,
        def: 1,
      );

      expect(c.isBoss, isFalse);
    });

    test('isBoss can be set to true', () {
      final Combatant c = Combatant(
        side: CombatSide.monster,
        typeKey: 'boss',
        maxHp: 100,
        atk: 20,
        def: 10,
        isBoss: true,
      );

      expect(c.isBoss, isTrue);
    });

    test('applyDamage drops HP and returns amount applied', () {
      final Combatant c = Combatant(
        side: CombatSide.player,
        typeKey: 'scout',
        maxHp: 10,
        atk: 3,
        def: 1,
      );

      final int applied = c.applyDamage(3);

      expect(applied, 3);
      expect(c.currentHp, 7);
      expect(c.isAlive, isTrue);
    });

    test('applyDamage clamps HP at 0 and returns applied delta', () {
      final Combatant c = Combatant(
        side: CombatSide.monster,
        typeKey: 'monsterL2',
        maxHp: 5,
        atk: 4,
        def: 2,
      );

      final int applied = c.applyDamage(8);

      expect(applied, 5);
      expect(c.currentHp, 0);
      expect(c.isAlive, isFalse);
    });

    test('isAlive becomes false when HP hits 0', () {
      final Combatant c = Combatant(
        side: CombatSide.player,
        typeKey: 'scout',
        maxHp: 4,
        atk: 1,
        def: 0,
      );

      c.applyDamage(4);

      expect(c.currentHp, 0);
      expect(c.isAlive, isFalse);
    });

    test('role is the combat role of its type key', () {
      expect(_c('guardian', CombatSide.player).role, CombatRole.taunt);
      expect(
        _c(CombatRole.rampartKey, CombatSide.player).role,
        CombatRole.taunt,
      );
      expect(_c('guardian', CombatSide.monster).role, CombatRole.taunt);
      expect(_c('monsterL1', CombatSide.monster).role, CombatRole.none);
      expect(_c('hunterL2', CombatSide.monster).role, CombatRole.none);
    });

    test('family is the monster family of its type key', () {
      expect(_c('hunterL2', CombatSide.monster).family, MonsterFamily.hunter);
      expect(_c('monsterL1', CombatSide.monster).family, isNull);
      expect(_c('guardian', CombatSide.player).family, isNull);
    });
  });
}
