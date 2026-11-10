class_name CombatantBuilder
extends RefCounted
## lib/domain/fight/combatant_builder.dart: the fighters of an army or of a
## lair.


## One combatant per unit of `selected_units`, entry by entry in the order
## of the map, the stats boosted by `boost` (none when null, `UnitBoost
## .none` in Dart). An entry of 0 or fewer units gives none.
static func player_combatants_from(
	selected_units: Dictionary[UnitType.Value, int],
	boost: UnitBoost = null,
	side := CombatSide.Value.PLAYER,
) -> Array[Combatant]:
	var applied := boost if boost != null else UnitBoost.none()
	var combatants: Array[Combatant] = []
	for type: UnitType.Value in selected_units:
		var count := selected_units[type]
		if count <= 0:
			continue
		var stats := UnitStats.for_type(type)
		var atk := applied.atk(stats.atk)
		var def := applied.def(stats.def)
		var hp := applied.hp(stats.hp)
		var key := DartEnum.name_of(UnitType.Value, type)
		for _i: int in count:
			combatants.append(Combatant.new(side, key, hp, atk, def))
	return combatants


## One combatant per monster of `lair`, family by family; colossi and
## krakens fight as bosses.
static func monster_combatants_from(lair: MonsterLair) -> Array[Combatant]:
	var level := lair.level()
	var combatants: Array[Combatant] = []
	var groups := lair.groups()
	for family: Variant in groups:
		var stats := MonsterUnitStats.of(family, level)
		var key := MonsterFamily.type_key_of(family, level)
		var is_boss := false
		if family != null:
			var known: MonsterFamily.Value = family
			is_boss = MonsterFamily.is_boss(known)
		for _i: int in groups[family]:
			combatants.append(
				Combatant.new(CombatSide.Value.MONSTER, key, stats.hp, stats.atk, stats.def, null, is_boss)
			)
	return combatants


## The unit type (a UnitType.Value) whose Dart name is `key`, or null.
static func unit_type_from_key(key: String) -> Variant:
	return DartEnum.by_name(UnitType.Value, key)
