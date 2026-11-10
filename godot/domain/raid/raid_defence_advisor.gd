class_name RaidDefenceAdvisor
extends RefCounted
## lib/domain/raid/raid_defence_advisor.dart: sizes the defence of the base
## against an announced raid wave, the way a careful player does: by
## rehearsing the fight with the units standing on the base level and the
## Coral Citadel rampart, then adding Harpoonists until the base wins with a
## safety margin.
##
## The rehearsals use the planner's own seeded dice, derived from the army
## rehearsed, so the advice is the same for the same game and never consumes
## the game's random stream. The last answer is kept, since the guide asks
## again at every rebuild of the screen: static state, which debug_reset()
## forgets between test files.

## Most Harpoonists ever advised on top of the defenders.
const MAX_ADDED := 150

static var _last_key: Variant = null
static var _last_answer: Variant = null


## `planner`, a const object in Dart: wins 19 rehearsals out of 20 at least.
## Built at each call.
static func planner() -> ArmyPlanner:
	return ArmyPlanner.new(20, 0.95)


## Harpoonists `player` should have on the base level against `wave`,
## counting those already there (an int); null when even MAX_ADDED more
## would not hold.
static func harpoonists_for(player: Player, wave: MonsterLair) -> Variant:
	var base := RaidBattle.defenders_of(player)
	var boost := FightMonsterHelpers.unit_boost_of(player, false, true)
	var rampart := CoralCitadelRampart.combatant_of(player.buildings)
	var key := _key_of(base, wave, boost, rampart)
	if key == _last_key:
		return _last_answer
	var have: int = base.get(UnitType.Value.HARPOONIST, 0)
	var army_of := func(k: int) -> Dictionary[UnitType.Value, int]:
		var army: Dictionary[UnitType.Value, int] = base.duplicate()
		army[UnitType.Value.HARPOONIST] = have + k
		return army
	var added: Variant = planner().smallest_winning(
		MAX_ADDED, army_of, _enemy(wave), boost, _rampart_of(player)
	)
	_last_key = key
	_last_answer = null
	if added != null:
		var more: int = added
		_last_answer = have + more
	return _last_answer


## Harpoonists alone, backed by the rampart, that beat `wave` on `player`'s
## base (an int); null when even MAX_ADDED would not hold.
static func harpoonists_alone(player: Player, wave: MonsterLair) -> Variant:
	var army_of := func(k: int) -> Dictionary[UnitType.Value, int]:
		return {UnitType.Value.HARPOONIST: k}
	return planner().smallest_winning(
		MAX_ADDED,
		army_of,
		_enemy(wave),
		FightMonsterHelpers.unit_boost_of(player, false, true),
		_rampart_of(player),
	)


static func debug_reset() -> void:
	_last_key = null
	_last_answer = null


## Everything the answer depends on, as Dart joins it ("null" for a value
## that is not there).
static func _key_of(
	base: Dictionary[UnitType.Value, int], wave: MonsterLair, boost: UnitBoost, rampart: Combatant
) -> String:
	var parts := PackedStringArray()
	for type: UnitType.Value in UnitType.Value.values():
		parts.append(str(base.get(type, 0)))
	parts.append_array(wave_key(wave))
	parts.append_array([str(boost.atk_percent), str(boost.def_percent), str(boost.hp_percent)])
	parts.append(str(rampart.max_hp) if rampart != null else "null")
	parts.append(str(rampart.def) if rampart != null else "null")
	return "/".join(parts)


## Not in the Dart class: the part of a key that tells `wave`, the index of
## its difficulty then `family:count` for each group ("null" for the generic
## monsters), which KernelDefenceAdvisor writes too.
static func wave_key(wave: MonsterLair) -> PackedStringArray:
	var parts := PackedStringArray([str(wave.difficulty)])
	var groups := wave.groups()
	for family: Variant in groups:
		var name := "null"
		if family != null:
			var known: MonsterFamily.Value = family
			name = DartEnum.name_of(MonsterFamily.Value, known)
		parts.append("%s:%d" % [name, groups[family]])
	return parts


## `() => CombatantBuilder.monsterCombatantsFrom(wave)`.
static func _enemy(wave: MonsterLair) -> Callable:
	return CombatantBuilder.monster_combatants_from.bind(wave)


## The Coral Citadel rampart that backs `player`'s base, if built: a fresh
## one at each call, or an invalid Callable for none.
static func _rampart_of(player: Player) -> Callable:
	if CoralCitadelRampart.combatant_of(player.buildings) == null:
		return Callable()
	return func() -> Array[Combatant]:
		return [CoralCitadelRampart.combatant_of(player.buildings)]
