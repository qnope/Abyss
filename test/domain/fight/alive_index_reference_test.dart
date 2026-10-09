import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:abyss/domain/fight/alive_index.dart';
import 'package:abyss/domain/fight/combat_role.dart';
import 'package:abyss/domain/fight/combat_side.dart';
import 'package:abyss/domain/fight/combatant.dart';
import 'package:abyss/domain/fight/monster_rules.dart';
import 'package:abyss/domain/fight/target_picker.dart';
import 'package:abyss/domain/map/monster_family.dart';

const List<String> _unitKeys = <String>['guardian', 'harpoonist', 'scout'];
const List<String> _monsterKeys = <String>['swarmL1', 'hunterL1', 'armouredL2'];

Combatant _of(CombatSide side, String key, {int hp = 10}) =>
    Combatant(side: side, typeKey: key, maxHp: hp, atk: 3, def: 0);

/// A pool of 1 to 40 combatants of one side, a third of them dead.
List<Combatant> _randomPool(Random gen) {
  final CombatSide side = gen.nextBool() ? CombatSide.player : CombatSide.monster;
  final List<String> keys = side == CombatSide.player ? _unitKeys : _monsterKeys;
  return List<Combatant>.generate(1 + gen.nextInt(40), (_) {
    final Combatant c = _of(side, keys[gen.nextInt(3)], hp: 1 + gen.nextInt(20));
    if (gen.nextInt(3) == 0) c.applyDamage(999);
    return c;
  });
}

/// Today's list-based pick, kept here as the reference the index must match.
Combatant? _referencePick(List<Combatant> pool, Random random, Combatant? by) {
  final List<Combatant> taunting = pool
      .where((Combatant c) => c.isAlive && c.role == CombatRole.taunt)
      .toList();
  if (taunting.isNotEmpty) return taunting[random.nextInt(taunting.length)];
  if (by != null && by.family == MonsterFamily.hunter) {
    return MonsterRules.frailest(pool);
  }
  final List<Combatant> alive = pool.where((Combatant c) => c.isAlive).toList();
  if (alive.isEmpty) return null;
  return alive[random.nextInt(alive.length)];
}

/// Today's list-based second target: another alive combatant that [keeps].
Combatant? _referenceOther(
  List<Combatant> pool,
  Combatant target,
  Random random,
  bool Function(Combatant) keeps,
) {
  final List<Combatant> others = pool
      .where((Combatant c) => c.isAlive && !identical(c, target) && keeps(c))
      .toList();
  if (others.isEmpty) return null;
  return others[random.nextInt(others.length)];
}

/// Today's list-based Essaim rule for a Harponneur's hit on [target].
Combatant? _referenceSweep(List<Combatant> pool, Combatant target, Random random) =>
    target.family != MonsterFamily.swarm
        ? null
        : _referenceOther(pool, target, random,
            (Combatant c) => c.family == MonsterFamily.swarm);

/// Wounds [target] as the engine would, burying it in [index] if it falls.
void _wound(Combatant target, AliveIndex index, Random gen) {
  target.applyDamage(gen.nextBool() ? 999 : 1);
  if (!target.isAlive) index.bury(target);
}

void main() {
  final Combatant hunter = _of(CombatSide.monster, 'hunterL1');
  final Combatant harpoonist = _of(CombatSide.player, 'harpoonist');
  final Combatant kraken = _of(CombatSide.monster, 'krakenL1');

  group('AliveIndex draws match the list-based references', () {
    for (int seed = 1; seed <= 200; seed++) {
      test('seed $seed', () {
        final Random gen = Random(seed);
        final List<Combatant> pool = _randomPool(gen);
        final AliveIndex index = AliveIndex(pool);
        final Random actual = Random(seed * 31);
        final Random expected = Random(seed * 31);

        for (int round = 0; round < 12; round++) {
          final Combatant? by = gen.nextBool() ? hunter : null;
          final Combatant? target =
              TargetPicker.pickFrom(index, actual, attacker: by);
          expect(target, same(_referencePick(pool, expected, by)));
          if (target == null) break;
          _wound(target, index, gen);

          expect(
            MonsterRules.sweepTargetIn(harpoonist, target, index, actual),
            same(_referenceSweep(pool, target, expected)),
          );
          final Combatant? embraced =
              MonsterRules.embraceTargetIn(kraken, target, index, actual);
          expect(
            embraced,
            same(_referenceOther(pool, target, expected, (_) => true)),
          );
          if (embraced != null) _wound(embraced, index, gen);
        }
        expect(actual.nextInt(1 << 20), expected.nextInt(1 << 20));
      });
    }
  });

  test('pickRandomFrom matches pickRandom draw for draw', () {
    final List<Combatant> pool = _randomPool(Random(5));
    final AliveIndex index = AliveIndex(pool);
    final Random actual = Random(9);
    final Random expected = Random(9);
    for (int i = 0; i < 50; i++) {
      expect(
        TargetPicker.pickRandomFrom(index, actual),
        same(TargetPicker.pickRandom(pool, expected)),
      );
    }
  });
}
