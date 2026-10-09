import 'combat_role.dart';
import 'combatant.dart';
import 'damage_calculator.dart';
import 'monster_rules.dart';

/// Damage of one attack between two combatants, unit roles and monster
/// family rules included.
class AttackDamage {
  const AttackDamage._();

  static const int bossMultiplier = 2;

  static int compute({
    required Combatant attacker,
    required Combatant target,
    bool crit = false,
  }) {
    final CombatRole role = CombatRole.of(attacker);
    final bool bossHit = role == CombatRole.bossBreaker && target.isBoss;
    return DamageCalculator.compute(
      atk: attacker.atk,
      def: target.def,
      crit: crit,
      ignoreDef: role == CombatRole.armourPiercer,
      multiplier: (bossHit ? bossMultiplier : 1) *
          MonsterRules.multiplier(attacker, target),
    );
  }
}
