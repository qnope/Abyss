import 'dart:math';

import 'combat_role.dart';
import 'combatant.dart';

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
  /// at least one of them still stands.
  static Combatant? pick(List<Combatant> pool, Random random) {
    final List<Combatant> taunting = pool
        .where((Combatant c) =>
            c.isAlive && CombatRole.of(c) == CombatRole.taunt)
        .toList();
    if (taunting.isNotEmpty) {
      return taunting[random.nextInt(taunting.length)];
    }
    return pickRandom(pool, random);
  }
}
