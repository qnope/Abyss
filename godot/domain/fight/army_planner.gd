class_name ArmyPlanner
extends RefCounted
## lib/domain/fight/army_planner.dart: sizes an army the way a careful
## player does, by replaying the fight in their head a few times before
## committing.
##
## The rehearsals use their own seeded generator, so planning never consumes
## the game's dice and a seed still replays the same game. In every call,
## `enemy` and `allies` give fresh combatants (allies not valid for none),
## `boost` null is `UnitBoost.none`.

## Rehearsals per estimate.
var rehearsals: int
## Share of rehearsals the army must win to be judged good enough.
var confidence: float


func _init(rehearsals_ := 8, confidence_ := 0.85) -> void:
	rehearsals = rehearsals_
	confidence = confidence_


## Share of rehearsals `army` wins against `enemy`, counting a win only when
## an Abyss Admiral survives if `needs_admiral`.
func win_rate(
	army: Dictionary[UnitType.Value, int],
	enemy: Callable,
	boost: UnitBoost = null,
	allies := Callable(),
	needs_admiral := false,
) -> float:
	var r := ArmyRehearsal.new(army, enemy, boost, allies, needs_admiral)
	return DartMath.quotient(r.wins(rehearsals), rehearsals)


## Whether `win_rate` reaches `confidence`, rehearsing only until the
## verdict is settled.
func wins(
	army: Dictionary[UnitType.Value, int],
	enemy: Callable,
	boost: UnitBoost = null,
	allies := Callable(),
	needs_admiral := false,
) -> bool:
	var needed: Variant = _needed_wins()
	if needed == null:
		return false
	var goal: int = needed
	var r := ArmyRehearsal.new(army, enemy, boost, allies, needs_admiral)
	return r.wins(rehearsals, goal) >= goal


## Fewest wins out of `rehearsals` whose `win_rate` reaches `confidence`,
## with the very same division; null when no count does.
func _needed_wins() -> Variant:
	for w: int in rehearsals + 1:
		if DartMath.quotient(w, rehearsals) >= confidence:
			return w
	return null


## Smallest `k` in `0..max_k` for which `army_of.call(k)` wins (an int), or
## null when even `army_of.call(max_k)` does not.
func smallest_winning(
	max_k: int,
	army_of: Callable,
	enemy: Callable,
	boost: UnitBoost = null,
	allies := Callable(),
	needs_admiral := false,
) -> Variant:
	var ok := func(k: int) -> bool:
		var army: Dictionary[UnitType.Value, int] = army_of.call(k)
		return wins(army, enemy, boost, allies, needs_admiral)
	if max_k < 0:
		return null
	if ok.call(0):
		return 0
	# Without needs_admiral, as in Dart.
	var largest: Dictionary[UnitType.Value, int] = army_of.call(max_k)
	if ArmyRehearsal.new(largest, enemy, boost, allies).hopeless():
		return null
	# Galloping first: large armies are slow to rehearse, so try them last.
	var low := 0
	var high := 1
	while not ok.call(mini(high, max_k)):
		if high >= max_k:
			return null
		low = high
		high *= 2
	if high > max_k:
		high = max_k
	while high - low > 1:
		var mid := DartMath.trunc_div(low + high, 2)
		if ok.call(mid):
			high = mid
		else:
			low = mid
	return high


## Rough Lanchester strength of `side` against `foes`, see
## ArmyRehearsal.strength.
static func strength(side: Array[Combatant], foes: Array[Combatant]) -> float:
	return ArmyRehearsal.strength(side, foes)
