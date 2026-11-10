class_name FightMonsterHelpers
extends RefCounted
## lib/domain/action/fight_monster_helpers.dart: what every fight shares
## once fought, ported ahead of the action module for the raids and the
## volcano. `buildCombatEntry` waits for the history module (`CombatEntry`).


## Stat boosts the player's research grants its units, when they attack or
## when they guard the base against a raid.
static func unit_boost_of(player: Player, attacking := false, defending_base := false) -> UnitBoost:
	return TechEffects.of(player).unit_boost(attacking, defending_base)


## Guarded share of the hit points lost: 0 for a side of no hit points.
static func compute_pct_lost(initial: Array[Combatant], final_c: Array[Combatant]) -> float:
	var initial_hp := 0
	for c: Combatant in initial:
		initial_hp += c.max_hp
	if initial_hp <= 0:
		return 0.0
	var final_hp := 0
	for c: Combatant in final_c:
		final_hp += c.current_hp
	return DartMath.quotient(initial_hp - final_hp, initial_hp)


## Restores the given combatants to the player's units on `level` (one stock
## increment per combatant). A unit type the level does not hold makes Dart
## throw: this logs an error and stops there.
static func restore_to_stock(player: Player, combatants: Array[Combatant], level: int) -> void:
	var units := player.units_on_level(level)
	for combatant: Combatant in combatants:
		var type: Variant = CombatantBuilder.unit_type_from_key(combatant.type_key)
		if type == null:
			continue
		var unit: Unit = units.get(type)
		if unit == null:
			push_error("FightMonsterHelpers: no %s on level %d" % [combatant.type_key, level])
			return
		unit.count += 1


## Applies loot deltas to player resources clamped to max storage. Returns
## the actual delta map (after clamping).
static func apply_loot(
	player: Player, loot: Dictionary[ResourceType.Value, int]
) -> Dictionary[ResourceType.Value, int]:
	return ResourceCredit.add(player.resources, loot)


## Counts the combatants by unit type, in the order met; the others (the
## rampart, a monster) are left out.
static func combatants_by_type(combatants: Array[Combatant]) -> Dictionary[UnitType.Value, int]:
	var map: Dictionary[UnitType.Value, int] = {}
	for c: Combatant in combatants:
		var type: Variant = CombatantBuilder.unit_type_from_key(c.type_key)
		if type == null:
			continue
		var known: UnitType.Value = type
		map[known] = map.get(known, 0) + 1
	return map


## Splits the player's fallen combatants into wounded and dead with
## CasualtyCalculator (one die of `random` each, a die of its own when
## null), restores the unharmed and the wounded to the player's units on
## `level`, and returns the counts of each by unit type.
static func resolve_casualties(
	player: Player, level: int, fight_result: FightResult, random: DartRandom = null
) -> FightCasualtyBreakdown:
	var pct_lost := compute_pct_lost(
		fight_result.initial_player_combatants, fight_result.final_player_combatants
	)
	var fallen: Array[Combatant] = []
	var alive: Array[Combatant] = []
	for i: int in fight_result.final_player_combatants.size():
		var initial := fight_result.initial_player_combatants[i]
		if fight_result.final_player_combatants[i].current_hp <= 0:
			fallen.append(initial)
		else:
			alive.append(initial)
	var split := CasualtyCalculator.new(random).partition(fallen, pct_lost)
	restore_to_stock(player, alive, level)
	restore_to_stock(player, split.wounded, level)
	return FightCasualtyBreakdown.new(
		combatants_by_type(alive), combatants_by_type(split.wounded), combatants_by_type(split.dead)
	)
