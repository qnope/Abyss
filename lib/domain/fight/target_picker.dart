import 'dart:math';

import 'combat_role.dart';
import 'combatant.dart';
import 'monster_rules.dart';

class TargetPicker {
  const TargetPicker._();

  static Combatant? pickRandom(List<Combatant> pool, Random random) {
    final List<Combatant> alive =
        pool.where((Combatant c) => c.isAlive).toList();
    if (alive.isEmpty) {
      return null;
    }
    return alive[random.nextInt(alive.length)];
  }

  /// Picks a random alive target, restricted to taunting combatants when
  /// at least one of them still stands. A hunting [attacker] goes for the
  /// frailest target instead of a random one.
  static Combatant? pick(
    List<Combatant> pool,
    Random random, {
    Combatant? attacker,
  }) {
    final List<Combatant> taunting = pool
        .where((Combatant c) =>
            c.isAlive && CombatRole.of(c) == CombatRole.taunt)
        .toList();
    if (taunting.isNotEmpty) {
      return taunting[random.nextInt(taunting.length)];
    }
    if (attacker != null && MonsterRules.hunts(attacker)) {
      return MonsterRules.frailest(pool);
    }
    return pickRandom(pool, random);
  }
}
