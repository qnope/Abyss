import 'package:abyss/domain/fight/attack_damage.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:flutter_test/flutter_test.dart';

Combatant _player(String key, {int atk = 8}) => Combatant(
      side: CombatSide.player,
      typeKey: key,
      maxHp: 20,
      atk: atk,
      def: 0,
    );

Combatant _monster({int def = 10, bool isBoss = false}) => Combatant(
      side: CombatSide.monster,
      typeKey: 'm',
      maxHp: 100,
      atk: 1,
      def: def,
      isBoss: isBoss,
    );

void main() {
  group('AttackDamage.compute', () {
    test('plain unit is reduced by the target DEF', () {
      final int dmg = AttackDamage.compute(
        attacker: _player('harpoonist'),
        target: _monster(),
      );
      expect(dmg, 4);
    });

    test('dome breaker deals double damage to bosses only', () {
      final Combatant breaker = _player('domeBreaker');
      expect(
        AttackDamage.compute(attacker: breaker, target: _monster()),
        4,
      );
      expect(
        AttackDamage.compute(
          attacker: breaker,
          target: _monster(isBoss: true),
        ),
        8,
      );
    });

    test('saboteur ignores the target DEF', () {
      final int dmg = AttackDamage.compute(
        attacker: _player('saboteur', atk: 10),
        target: _monster(def: 20),
      );
      expect(dmg, 10);
    });

    test('crit triples the role-adjusted damage', () {
      final int dmg = AttackDamage.compute(
        attacker: _player('domeBreaker'),
        target: _monster(isBoss: true),
        crit: true,
      );
      expect(dmg, 24);
    });
  });
}
