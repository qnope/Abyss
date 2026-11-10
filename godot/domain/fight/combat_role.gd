class_name CombatRole
extends RefCounted
## lib/domain/fight/combat_role.dart: special behaviour a player unit brings
## to a fight.

enum Value {
	## No special rule.
	NONE,
	## Draws enemy attacks: monsters must target it while it stands.
	TAUNT,
	## Deals double damage to bosses.
	BOSS_BREAKER,
	## Ignores the target's DEF.
	ARMOUR_PIERCER,
	## Flees instead of dying: always comes back wounded.
	EVASIVE,
}

## Type key of the Coral Citadel rampart (see CoralCitadelRampart).
const RAMPART_KEY := "rampart"
const _FOR_UNIT: Dictionary[UnitType.Value, Value] = {
	UnitType.Value.GUARDIAN: Value.TAUNT,
	UnitType.Value.DOME_BREAKER: Value.BOSS_BREAKER,
	UnitType.Value.SABOTEUR: Value.ARMOUR_PIERCER,
	UnitType.Value.SCOUT: Value.EVASIVE,
	UnitType.Value.HARPOONIST: Value.NONE,
	UnitType.Value.ABYSS_ADMIRAL: Value.NONE,
}


## `_unitTypes`, the units by their Dart name, a table since `of` runs for
## every combatant built; its test holds it to DartEnum.names.
const _UNIT_TYPES: Dictionary[String, UnitType.Value] = {
	"scout": UnitType.Value.SCOUT,
	"harpoonist": UnitType.Value.HARPOONIST,
	"guardian": UnitType.Value.GUARDIAN,
	"domeBreaker": UnitType.Value.DOME_BREAKER,
	"abyssAdmiral": UnitType.Value.ABYSS_ADMIRAL,
	"saboteur": UnitType.Value.SABOTEUR,
}


static func for_unit(type: UnitType.Value) -> Value:
	return _FOR_UNIT[type]


## Role of `combatant`, read from its type key: no monster key is a unit's,
## so only units and the Citadel rampart have one, on either side (the
## defenders of a base fight on the side of the monsters).
static func of(combatant: Combatant) -> Value:
	if combatant.type_key == RAMPART_KEY:
		return Value.TAUNT
	var type: Variant = _UNIT_TYPES.get(combatant.type_key)
	if type == null:
		return Value.NONE
	var unit: UnitType.Value = type
	return for_unit(unit)
