class_name LeviathanDefenceAdvisor
extends RefCounted
## lib/domain/leviathan/leviathan_defence_advisor.dart: sizes the defence of
## the Faille against the guardians coming back (LeviathanForce), as a
## careful player does: by rehearsing the fight with the units of the level
## below, without rampart, then adding Harpoonists until the Faille holds
## with a safety margin, as KernelDefenceAdvisor does for the kernel.
##
## The rehearsals use the planner's own seeded dice, so the advice is the
## same for the same game and never consumes the game's random stream.
## Answers are remembered, since the screen asks at every rebuild: a static
## cache, which debug_reset() empties between test files.

## Most Harpoonists ever advised on top of the defenders.
const MAX_ADDED := 150

static var _answers := MemoCache.new(8)


## `planner`, a const object in Dart: wins 19 rehearsals out of 20 at least.
## Built at each call.
static func planner() -> ArmyPlanner:
	return ArmyPlanner.new(20, 0.95)


## Units `player` should have on `level` against the guardians of `game`,
## counting those already there (an int); null when even MAX_ADDED more
## Harpoonists would not hold.
static func units_for(game: Game, player: Player, level: int) -> Variant:
	var defenders: Dictionary[UnitType.Value, int] = {}
	var units := player.units_on_level(level)
	for type: UnitType.Value in units:
		if units[type].count > 0:
			defenders[type] = units[type].count
	var boost := FightMonsterHelpers.unit_boost_of(player)
	var percent := LeviathanForce.percent_of(game)
	var compute := func() -> Variant:
		var have: int = defenders.get(UnitType.Value.HARPOONIST, 0)
		var army_of := func(k: int) -> Dictionary[UnitType.Value, int]:
			var army: Dictionary[UnitType.Value, int] = defenders.duplicate()
			army[UnitType.Value.HARPOONIST] = have + k
			return army
		var added: Variant = planner().smallest_winning(MAX_ADDED, army_of, _attackers.bind(percent), boost)
		return null if added == null else _plus_defenders(added, defenders)
	return _answers.answer(_key_of(defenders, boost, percent), compute)


## `added` Harpoonists and every defender. The planner's null, which no game
## reaches (MAX_ADDED Harpoonists always hold), never comes here.
static func _plus_defenders(added: Variant, defenders: Dictionary[UnitType.Value, int]) -> int:
	var total: int = added
	for count: int in defenders.values():
		total += count
	return total


static func debug_reset() -> void:
	_answers = MemoCache.new(8)


## The guardians, on the monsters' side of a rehearsal.
static func _attackers(percent: int) -> Array[Combatant]:
	var side: Array[Combatant] = []
	for c: Combatant in LeviathanForce.combatants(percent):
		side.append(Combatant.new(CombatSide.Value.MONSTER, c.type_key, c.max_hp, c.atk, c.def, null, c.is_boss))
	return side


## Everything the answer depends on, as Dart joins it.
static func _key_of(defenders: Dictionary[UnitType.Value, int], boost: UnitBoost, percent: int) -> String:
	var parts := PackedStringArray()
	for type: UnitType.Value in UnitType.Value.values():
		parts.append(str(defenders.get(type, 0)))
	parts.append_array([str(boost.atk_percent), str(boost.def_percent), str(boost.hp_percent), str(percent)])
	return "/".join(parts)
