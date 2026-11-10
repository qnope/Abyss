class_name AttackTransitionBaseHelpers
extends RefCounted
## lib/domain/action/attack_transition_base_helpers.dart: what the assaults
## led by an Abyss Admiral share: the army checked against the stock, sent
## out of it, and brought back after the fight.


## The failure that keeps `selected_units` of `level` home: no Abyss Admiral
## among them, or more of a type than `player` holds; null when they may go.
static func validate_units(
	player: Player, level: int, selected_units: Dictionary[UnitType.Value, int]
) -> AttackTransitionBaseResult:
	if selected_units.get(UnitType.Value.ABYSS_ADMIRAL, 0) <= 0:
		return AttackTransitionBaseResult.failure(ActionFailure.Value.ADMIRAL_REQUIRED)
	var stock := player.units_on_level(level)
	for type: UnitType.Value in selected_units:
		var count: int = selected_units[type]
		if count <= 0:
			continue
		if count > Unit.count_in(stock, type):
			return AttackTransitionBaseResult.failure(ActionFailure.Value.NOT_ENOUGH_UNITS)
	return null


## Whether an Abyss Admiral still stands among `final_combatants`.
static func is_admiral_alive(final_combatants: Array[Combatant]) -> bool:
	var admiral := DartEnum.name_of(UnitType.Value, UnitType.Value.ABYSS_ADMIRAL)
	return final_combatants.any(
		func(c: Combatant) -> bool: return c.type_key == admiral and c.is_alive()
	)


## Takes `selected_units` out of `player`'s stock on `level`.
static func remove_units_from_stock(
	player: Player, level: int, selected_units: Dictionary[UnitType.Value, int]
) -> void:
	var stock := player.units_on_level(level)
	for type: UnitType.Value in selected_units:
		var count: int = selected_units[type]
		if count <= 0:
			continue
		stock[type].count -= count


## Splits the fallen into wounded and dead with CasualtyCalculator (one die
## of `random` each, a die of its own when null), brings the unharmed and
## the wounded back to `level`, and counts each by unit type.
static func resolve_casualties(
	player: Player, level: int, fight_result: FightResult, random: DartRandom = null
) -> FightCasualtyBreakdown:
	var pct_lost := FightMonsterHelpers.compute_pct_lost(
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
	_restore_to_level(player, level, alive)
	_restore_to_level(player, level, split.wounded)
	return FightCasualtyBreakdown.new(
		FightMonsterHelpers.combatants_by_type(alive),
		FightMonsterHelpers.combatants_by_type(split.wounded),
		FightMonsterHelpers.combatants_by_type(split.dead),
	)


## `_restoreToLevel`, one unit back on `level` for each of `combatants`: the
## Dart lines of `FightMonsterHelpers.restoreToStock`, which it calls.
static func _restore_to_level(player: Player, level: int, combatants: Array[Combatant]) -> void:
	FightMonsterHelpers.restore_to_stock(player, combatants, level)
