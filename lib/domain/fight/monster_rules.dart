import 'dart:math';

import '../map/monster_family.dart';
import '../unit/unit_type.dart';
import 'combat_role.dart';
import 'combatant.dart';

/// Combat rules of the monster families (see [MonsterFamily]).
abstract final class MonsterRules {
  /// Damage multiplier of a hunter against a unit that does not taunt.
  static const int huntMultiplier = 2;

  static MonsterFamily? familyOf(Combatant c) =>
      MonsterFamily.ofTypeKey(c.typeKey);

  /// Traque: hunters go for the frailest unit.
  static bool hunts(Combatant attacker) =>
      familyOf(attacker) == MonsterFamily.hunter;

  /// Damage multiplier the family rules give [attacker] against [target].
  static int multiplier(Combatant attacker, Combatant target) =>
      hunts(attacker) && CombatRole.of(target) != CombatRole.taunt
          ? huntMultiplier
          : 1;

  /// The frailest alive combatant of [pool], `null` when none stands.
  static Combatant? frailest(List<Combatant> pool) {
    Combatant? best;
    for (final Combatant c in pool) {
      if (!c.isAlive) continue;
      if (best == null || c.currentHp < best.currentHp) best = c;
    }
    return best;
  }

  /// Essaim: a Harponneur's hit on a swarm fish also strikes another
  /// fish of the swarm, picked at random. `null` when the hit does not
  /// sweep or no other fish stands.
  static Combatant? sweepTarget(
    Combatant attacker,
    Combatant target,
    List<Combatant> pool,
    Random random,
  ) {
    if (attacker.typeKey != UnitType.harpoonist.name) return null;
    if (familyOf(target) != MonsterFamily.swarm) return null;
    final List<Combatant> others =
        pool
            .where(
              (Combatant c) =>
                  c.isAlive &&
                  !identical(c, target) &&
                  familyOf(c) == MonsterFamily.swarm,
            )
            .toList();
    if (others.isEmpty) return null;
    return others[random.nextInt(others.length)];
  }

  /// Étreinte: a kraken's tentacles also strike another defender, picked
  /// at random. `null` when [attacker] is no kraken or no one else stands.
  static Combatant? embraceTarget(
    Combatant attacker,
    Combatant target,
    List<Combatant> pool,
    Random random,
  ) {
    if (familyOf(attacker) != MonsterFamily.kraken) return null;
    final List<Combatant> others =
        pool.where((Combatant c) => c.isAlive && !identical(c, target)).toList();
    if (others.isEmpty) return null;
    return others[random.nextInt(others.length)];
  }

  /// Second combatant [attacker]'s hit on [target] strikes, by the
  /// Essaim or Étreinte rule, or `null`.
  static Combatant? secondTarget(
    Combatant attacker,
    Combatant target,
    List<Combatant> pool,
    Random random,
  ) =>
      sweepTarget(attacker, target, pool, random) ??
      embraceTarget(attacker, target, pool, random);
}
