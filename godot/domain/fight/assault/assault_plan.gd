class_name AssaultPlan
extends RefCounted
## lib/domain/fight/assault/assault_plan.dart: what the player should know
## before assaulting a Faille, a Cheminée or the volcanic kernel with the
## army being composed: is an Abyss Admiral in it and covered, how likely
## the capture is, what comes after, and the army the guide advises.
##
## Purely informative: it never changes the player, and it is cheap to
## recompute at every unit added or removed (see AssaultRehearsals).

## Most Harpoonists ever advised by default: enough for the kernel without
## any research (about 260 with a lone admiral).
const DEFAULT_MAX_HARPOONISTS := 300

var target: AssaultTarget.Value
## The army being composed, without empty entries.
var army: Dictionary[UnitType.Value, int]
## Abyss Admirals the player has on the level of the assault.
var admirals_available: int
## The building to raise after the capture; null for the kernel.
var next_step: AssaultNextStep

var _boost: UnitBoost
var _max_harpoonists: int
## The `late final` fields, computed on first read: `_chance` an
## AssaultChance, `_suggested` an int or null, `_suggested_read` whether it
## was.
var _chance: AssaultChance
var _suggested: Variant
var _suggested_read := false


func _init(
	target_: AssaultTarget.Value,
	army_: Dictionary[UnitType.Value, int],
	admirals_available_: int,
	next_step_: AssaultNextStep,
	boost: UnitBoost,
	max_harpoonists: int,
) -> void:
	target = target_
	army = army_
	admirals_available = admirals_available_
	next_step = next_step_
	_boost = boost
	_max_harpoonists = max_harpoonists


## Rehearsals behind every `chance()`.
static func rehearsals() -> int:
	return AssaultRehearsals.planner().rehearsals


## `AssaultPlan.of`: the plan for `player` sending `army_` against
## `target_` from `level`, with the attacker boosts the real assault uses.
## The advice adds at most `max_harpoonists`.
static func of(
	player: Player,
	level: int,
	target_: AssaultTarget.Value,
	army_: Dictionary[UnitType.Value, int],
	max_harpoonists := DEFAULT_MAX_HARPOONISTS,
) -> AssaultPlan:
	var kept: Dictionary[UnitType.Value, int] = {}
	for type: UnitType.Value in army_:
		if army_[type] > 0:
			kept[type] = army_[type]
	kept.make_read_only()
	var admirals: Unit = player.units_on_level(level).get(UnitType.Value.ABYSS_ADMIRAL)
	return AssaultPlan.new(
		target_, kept, admirals.count if admirals != null else 0, _next_step_of(player, target_),
		FightMonsterHelpers.unit_boost_of(player, true), max_harpoonists,
	)


## Whether the army holds an Abyss Admiral, without whom nothing is
## captured.
func has_admiral() -> bool:
	return _admirals() > 0


## Whether a Guardian marches with the admiral: Guardians draw the blows,
## so they keep the 0-attack admiral alive longer.
func admiral_covered() -> bool:
	return _guardians() > 0


## How often the army captures the target; AssaultChance.none() without an
## admiral.
func chance() -> AssaultChance:
	if _chance == null:
		_chance = AssaultRehearsals.chance_of(army, target, _boost) if has_admiral() else AssaultChance.none()
	return _chance


## Fewest Harpoonists to send with the admirals (one if none is selected)
## and Guardians selected, for a capture in 19 rehearsals of 20 (an int);
## null when out of reach. Computed on first read.
func suggested_harpoonists() -> Variant:
	if not _suggested_read:
		_suggested = AssaultRehearsals.harpoonists_for(_escort(), target, _boost, _max_harpoonists)
		_suggested_read = true
	return _suggested


## The escort plus `suggested_harpoonists()`; null when out of reach.
func suggested_army() -> Variant:
	var harpoonists: Variant = suggested_harpoonists()
	if harpoonists == null:
		return null
	var count: int = harpoonists
	var suggested := _escort()
	if count > 0:
		suggested[UnitType.Value.HARPOONIST] = count
	return suggested


func _admirals() -> int:
	return army.get(UnitType.Value.ABYSS_ADMIRAL, 0)


func _guardians() -> int:
	return army.get(UnitType.Value.GUARDIAN, 0)


func _escort() -> Dictionary[UnitType.Value, int]:
	var escort: Dictionary[UnitType.Value, int] = {
		UnitType.Value.ABYSS_ADMIRAL: _admirals() if has_admiral() else 1,
	}
	if _guardians() > 0:
		escort[UnitType.Value.GUARDIAN] = _guardians()
	return escort


static func _next_step_of(player: Player, target_: AssaultTarget.Value) -> AssaultNextStep:
	var passage_or_null: Variant = AssaultTarget.passage(target_)
	if passage_or_null == null:
		return null
	var passage: BuildingType.Value = passage_or_null
	var required: int = BuildingCostCalculator.new().prerequisites(passage, 1).get(
		BuildingType.Value.HEADQUARTERS, 0
	)
	var current := Building.level_in(player.buildings, BuildingType.Value.HEADQUARTERS)
	return AssaultNextStep.new(passage, required, current)
