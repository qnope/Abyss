class_name KernelDefenceAdvisor
extends RefCounted
## lib/domain/volcano/kernel_defence_advisor.dart: sizes the garrison of the
## volcanic kernel against an announced kraken wave, as a careful player
## does: by rehearsing the fight with the garrison and the magma rampart,
## then adding Harpoonists until the kernel holds with a safety margin, as
## RaidDefenceAdvisor does for the base.
##
## The rehearsals use the planner's own seeded dice, so the advice is the
## same for the same game and never consumes the game's random stream.
## Answers are remembered, since the guide asks at every rebuild: a static
## cache, which debug_reset() empties between test files.

## Most Harpoonists ever advised on top of the garrison.
const MAX_ADDED := 150

static var _answers := MemoCache.new(8)


## `planner`, a const object in Dart: wins 19 rehearsals out of 20 at least.
## Built at each call.
static func planner() -> ArmyPlanner:
	return ArmyPlanner.new(20, 0.95)


## Units `player` should have in the kernel's garrison against `wave`,
## counting those already there (an int); null when even MAX_ADDED more
## Harpoonists would not hold.
static func units_for(player: Player, wave: MonsterLair) -> Variant:
	var garrison := KernelGarrison.of(player)
	var boost := FightMonsterHelpers.unit_boost_of(player, false, true)
	var level := KernelGarrison.kernel_level_of(player)
	var compute := func() -> Variant:
		var have: int = garrison.get(UnitType.Value.HARPOONIST, 0)
		var army_of := func(k: int) -> Dictionary[UnitType.Value, int]:
			var army: Dictionary[UnitType.Value, int] = garrison.duplicate()
			army[UnitType.Value.HARPOONIST] = have + k
			return army
		var enemy := CombatantBuilder.monster_combatants_from.bind(wave)
		var added: Variant = planner().smallest_winning(
			MAX_ADDED, army_of, enemy, boost, _rampart_of(level)
		)
		if added == null:
			return null
		var total: int = added
		for count: int in garrison.values():
			total += count
		return total
	return _answers.answer(_key_of(garrison, wave, boost, level), compute)


static func debug_reset() -> void:
	_answers = MemoCache.new(8)


## Everything the answer depends on, as Dart joins it.
static func _key_of(
	garrison: Dictionary[UnitType.Value, int], wave: MonsterLair, boost: UnitBoost, level: int
) -> String:
	var parts := PackedStringArray()
	for type: UnitType.Value in UnitType.Value.values():
		parts.append(str(garrison.get(type, 0)))
	parts.append_array(RaidDefenceAdvisor.wave_key(wave))
	parts.append_array([str(boost.atk_percent), str(boost.def_percent), str(boost.hp_percent), str(level)])
	return "/".join(parts)


## The magma rampart of a kernel at `level`, a fresh one at each call, or an
## invalid Callable for none.
static func _rampart_of(level: int) -> Callable:
	if MagmaRampart.combatant_for(level) == null:
		return Callable()
	return func() -> Array[Combatant]:
		return [MagmaRampart.combatant_for(level)]
