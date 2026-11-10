class_name AssaultRehearsals
extends RefCounted
## lib/domain/fight/assault/assault_rehearsals.dart: rehearses assaults with
## the planner's own seeded dice, derived from the army rehearsed, so the
## answer is the same for the same input and never consumes the game's
## random stream. A rehearsal counts as a capture only when the fight is won
## and an Abyss Admiral survives.
##
## Answers are remembered, since the army screen asks again at every unit
## added or removed, and often comes back to an army already seen: static
## caches, which debug_reset() empties between test files.

static var _chances := MemoCache.new(64)
static var _harpoonists := MemoCache.new(16)


## `planner`, a const object in Dart: captures 19 rehearsals out of 20 at
## least to be advised. Built at each call.
static func planner() -> ArmyPlanner:
	return ArmyPlanner.new(20, 0.95)


## How often `army` captures `target`, fighting with `boost`.
static func chance_of(
	army: Dictionary[UnitType.Value, int], target: AssaultTarget.Value, boost: UnitBoost
) -> AssaultChance:
	var compute := func() -> AssaultChance:
		var p := planner()
		var rate := p.win_rate(army, AssaultTarget.guardians_of(target), boost, Callable(), true)
		return AssaultChance.new(roundi(rate * p.rehearsals), p.rehearsals)
	return _chances.answer(_key_of(army, target, boost), compute)


## Fewest Harpoonists to add to `escort` for it to capture `target` often
## enough for the planner (an int); null when even `max_added` fall short.
static func harpoonists_for(
	escort: Dictionary[UnitType.Value, int],
	target: AssaultTarget.Value,
	boost: UnitBoost,
	max_added: int,
) -> Variant:
	var compute := func() -> Variant:
		var have: int = escort.get(UnitType.Value.HARPOONIST, 0)
		var army_of := func(k: int) -> Dictionary[UnitType.Value, int]:
			var army: Dictionary[UnitType.Value, int] = escort.duplicate()
			army[UnitType.Value.HARPOONIST] = have + k
			return army
		var enemy := AssaultTarget.guardians_of(target)
		return planner().smallest_winning(max_added, army_of, enemy, boost, Callable(), true)
	var key := "%s/%d" % [_key_of(escort, target, boost), max_added]
	return _harpoonists.answer(key, compute)


static func debug_reset() -> void:
	_chances = MemoCache.new(64)
	_harpoonists = MemoCache.new(16)


## Everything an answer depends on: the target, the count of each unit type
## in the order of the enum, the three percents of the boost.
static func _key_of(
	army: Dictionary[UnitType.Value, int], target: AssaultTarget.Value, boost: UnitBoost
) -> String:
	var parts := PackedStringArray([DartEnum.name_of(AssaultTarget.Value, target)])
	for type: UnitType.Value in UnitType.Value.values():
		parts.append(str(army.get(type, 0)))
	parts.append(str(boost.atk_percent))
	parts.append(str(boost.def_percent))
	parts.append(str(boost.hp_percent))
	return "/".join(parts)
