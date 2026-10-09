import 'dart:math';

import 'package:abyss/domain/fight/attack_damage.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/monster_rules.dart';
import 'package:abyss/domain/fight/target_picker.dart';
import 'package:flutter_test/flutter_test.dart';

Combatant unit(String key, {int hp = 20, int atk = 5, int def = 0}) =>
    Combatant(
      side: CombatSide.player,
      typeKey: key,
      maxHp: hp,
      atk: atk,
      def: def,
    );

Combatant monster(String key, {int hp = 10, int atk = 6, int def = 0}) =>
    Combatant(
      side: CombatSide.monster,
      typeKey: key,
      maxHp: hp,
      atk: atk,
      def: def,
    );

void main() {
  group('Traque', () {
    test('a hunter goes for the frailest unit', () {
      final frail = unit('scout', hp: 4);
      final pool = [unit('harpoonist', hp: 15), frail, unit('saboteur')];
      expect(
        TargetPicker.pick(pool, Random(1), attacker: monster('hunterL1')),
        same(frail),
      );
    });

    test('a taunting unit still draws the hunter', () {
      final guardian = unit('guardian', hp: 25);
      final pool = [unit('scout', hp: 4), guardian];
      expect(
        TargetPicker.pick(pool, Random(1), attacker: monster('hunterL1')),
        same(guardian),
      );
    });

    test('a hunter hits twice as hard, except a taunting unit', () {
      final hunter = monster('hunterL1', atk: 6);
      expect(AttackDamage.compute(attacker: hunter, target: unit('scout')), 12);
      expect(
        AttackDamage.compute(attacker: hunter, target: unit('guardian')),
        6,
      );
      expect(
        AttackDamage.compute(
          attacker: monster('swarmL1', atk: 6),
          target: unit('scout'),
        ),
        6,
      );
    });
  });

  group('Essaim', () {
    test("a Harponneur's hit on the swarm strikes another fish", () {
      final target = monster('swarmL1');
      final other = monster('swarmL1');
      final pool = [target, monster('hunterL1'), other];
      expect(
        MonsterRules.sweepTarget(unit('harpoonist'), target, pool, Random(3)),
        same(other),
      );
    });

    test('only a Harponneur sweeps, and only the swarm', () {
      final target = monster('swarmL1');
      final pool = [target, monster('swarmL1')];
      expect(
        MonsterRules.sweepTarget(unit('saboteur'), target, pool, Random(1)),
        isNull,
      );
      final hunter = monster('hunterL1');
      expect(
        MonsterRules.sweepTarget(unit('harpoonist'), hunter, [
          hunter,
          monster('hunterL1'),
        ], Random(1)),
        isNull,
      );
    });

    test('a lone fish leaves nothing to sweep', () {
      final target = monster('swarmL1');
      expect(
        MonsterRules.sweepTarget(unit('harpoonist'), target, [
          target,
          monster('swarmL1', hp: 0)..applyDamage(1),
        ], Random(1)),
        isNull,
      );
    });
  });
}
