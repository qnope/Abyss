class_name AttackDamage
extends RefCounted
## lib/domain/fight/attack_damage.dart: damage of one attack between two
## combatants, unit roles and monster family rules included.

const BOSS_MULTIPLIER := 2


static func compute(attacker: Combatant, target: Combatant, crit := false) -> int:
	var role := attacker.role
	var boss_hit := role == CombatRole.Value.BOSS_BREAKER and target.is_boss
	return DamageCalculator.compute(
		attacker.atk,
		target.def,
		crit,
		role == CombatRole.Value.ARMOUR_PIERCER,
		(BOSS_MULTIPLIER if boss_hit else 1) * MonsterRules.multiplier(attacker, target),
	)
