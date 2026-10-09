import 'dart:math';

import 'alive_index.dart';
import 'combatant.dart';
import 'monster_rules.dart';

class TargetPicker {
  const TargetPicker._();

  static Combatant? pickRandom(List<Combatant> pool, Random random) =>
      pickRandomFrom(AliveIndex(pool), random);

  /// A random alive combatant of [index], `null` when none stands.
  static Combatant? pickRandomFrom(AliveIndex index, Random random) {
    if (index.alive == 0) {
      return null;
    }
    return index.nthAlive(random.nextInt(index.alive));
  }

  /// Picks a random alive target, restricted to taunting combatants when
  /// at least one of them still stands. A hunting [attacker] goes for the
  /// frailest target instead of a random one.
  static Combatant? pick(
    List<Combatant> pool,
    Random random, {
    Combatant? attacker,
  }) =>
      pickFrom(AliveIndex(pool), random, attacker: attacker);

  /// [pick] through an [AliveIndex] the caller keeps up to date.
  static Combatant? pickFrom(
    AliveIndex index,
    Random random, {
    Combatant? attacker,
  }) {
    if (index.taunting > 0) {
      return index.nthTaunting(random.nextInt(index.taunting));
    }
    if (attacker != null && MonsterRules.hunts(attacker)) {
      return MonsterRules.frailest(index.pool);
    }
    return pickRandomFrom(index, random);
  }
}
