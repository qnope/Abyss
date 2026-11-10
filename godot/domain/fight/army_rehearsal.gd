class_name ArmyRehearsal
extends RefCounted
## lib/domain/fight/army_rehearsal.dart: one `army` facing one `enemy`,
## replayed in the head with dice seeded from the army alone, so rehearsing
## never consumes the game's dice.

const _ADMIRAL_KEY := "abyssAdmiral"

var army: Dictionary[UnitType.Value, int]
## Gives fresh foes at each call: `List<Combatant> Function()`.
var enemy: Callable
var boost: UnitBoost
## Gives fresh allies at each call, or is not valid for none: the nullable
## `List<Combatant> Function()?` of Dart.
var allies: Callable
## Counts a win only when an Abyss Admiral survives.
var needs_admiral: bool


## `boost_` null is `UnitBoost.none`.
func _init(
	army_: Dictionary[UnitType.Value, int],
	enemy_: Callable,
	boost_: UnitBoost = null,
	allies_ := Callable(),
	needs_admiral_ := false,
) -> void:
	army = army_
	enemy = enemy_
	boost = boost_ if boost_ != null else UnitBoost.none()
	allies = allies_
	needs_admiral = needs_admiral_


## Fights won out of `rehearsals`, `0` at once when the army is empty or
## clearly outmatched. Given `needed` (an int, or null), stops as soon as
## `needed` wins are reached or out of reach: the count then only tells
## whether it gets to `needed`.
func wins(rehearsals: int, needed: Variant = null) -> int:
	var random := DartRandom.new(_seed_of(army))
	var won := 0
	for i: int in rehearsals:
		if needed != null:
			var goal: int = needed
			if won >= goal or i - won > rehearsals - goal:
				break
		var side := _side()
		if side.is_empty():
			return 0
		var foes: Array[Combatant] = enemy.call()
		if i == 0 and _outmatched(side, foes):
			return 0
		var result := FightEngine.new(random).resolve(side, foes)
		if result.is_victory() and (not needs_admiral or _admiral_stands(result)):
			won += 1
	return won


## Whether the army is far too weak for `enemy`, judged without replaying
## the fight.
func hopeless() -> bool:
	var foes: Array[Combatant] = enemy.call()
	return _outmatched(_side(), foes)


## Rough Lanchester strength of `side` against `foes`: total hit points
## times the damage it deals per round. Lets clearly hopeless fights be
## ruled out without replaying them. Infinite against no foe.
static func strength(side: Array[Combatant], foes: Array[Combatant]) -> float:
	if foes.is_empty():
		return INF
	var def_sum := 0
	for c: Combatant in foes:
		def_sum += c.def
	var def := DartMath.quotient(def_sum, foes.size())
	var hp := 0.0
	var dmg := 0.0
	for c: Combatant in side:
		hp += c.max_hp
		dmg += DamageCalculator.compute(c.atk, DartMath.round(def))
	return hp * dmg


func _side() -> Array[Combatant]:
	var side := CombatantBuilder.player_combatants_from(army, boost)
	if allies.is_valid():
		var extra: Array[Combatant] = allies.call()
		side.append_array(extra)
	return side


static func _outmatched(side: Array[Combatant], foes: Array[Combatant]) -> bool:
	return strength(side, foes) * 2 < strength(foes, side)


static func _admiral_stands(result: FightResult) -> bool:
	for c: Combatant in result.final_player_combatants:
		if c.type_key == _ADMIRAL_KEY and c.current_hp > 0:
			return true
	return false


## 17, then `seed * 31 + count` for each unit type in the order of the enum,
## wrapping to 64 bits, kept to 31 bits.
static func _seed_of(units: Dictionary[UnitType.Value, int]) -> int:
	var seed_ := 17
	for type: UnitType.Value in UnitType.Value.values():
		seed_ = seed_ * 31 + units.get(type, 0)
	return seed_ & 0x7FFFFFFF
