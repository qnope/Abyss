import 'package:flutter_test/flutter_test.dart';

import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';

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
  });
}
