class_name BaseDefence
extends RefCounted
## lib/domain/action/attack_base_defence.dart, `BaseDefence`: the defence of
## a base against a player: every unit standing on the base level and the
## Citadel rampart (halved when degraded), as in a raid.
##
## They fight on the monsters' side of the FightEngine, the attackers on the
## player's; a unit keeps its role (a Gardien still draws the blows) on
## either side.

var engaged: Dictionary[UnitType.Value, int]
## The combatants of the fight; the engine wears them down in place.
var side: Array[Combatant]
## The level whose units defend, and get the survivors back.
var level: int


func _init(engaged_: Dictionary[UnitType.Value, int], side_: Array[Combatant], level_: int) -> void:
	engaged = engaged_
	side = side_
	level = level_


## `BaseDefence.post`: every unit `target` has on `level`, without rampart,
## as a Faille is held by the level 2 units and a Cheminée by the level 3
## units (the kernel garrison is kept in a stock of its own).
static func post(target: Player, level_: int) -> BaseDefence:
	var units := target.units_on_level(level_)
	var engaged_: Dictionary[UnitType.Value, int] = {}
	for type: UnitType.Value in units:
		if units[type].count > 0:
			engaged_[type] = units[type].count
	var boost := FightMonsterHelpers.unit_boost_of(target)
	return BaseDefence.new(
		engaged_, CombatantBuilder.player_combatants_from(engaged_, boost, CombatSide.Value.MONSTER), level_
	)


## `BaseDefence.fromIntel`: the defence of a base as a scout reported it:
## the army and the rampart `intel` saw, without the boosts nobody could
## see. What the base really fields can differ once the report is old.
static func from_intel(intel: BaseIntel) -> BaseDefence:
	var side_ := CombatantBuilder.player_combatants_from(intel.army, null, CombatSide.Value.MONSTER)
	return BaseDefence.new(
		intel.army, _with_rampart(side_, CoralCitadelRampart.combatant_for(intel.rampart_level)),
		RaidBattle.BASE_LEVEL,
	)


## `BaseDefence.kernel`: the garrison, backed by the magma rampart that its
## level raises. The garrison lives in a stock of its own, away from the
## units of the volcano level.
static func kernel(target: Player) -> BaseDefence:
	var engaged_ := KernelGarrison.of(target)
	var boost := FightMonsterHelpers.unit_boost_of(target, false, true)
	var side_ := CombatantBuilder.player_combatants_from(engaged_, boost, CombatSide.Value.MONSTER)
	var rampart := MagmaRampart.combatant_for(KernelGarrison.kernel_level_of(target))
	return BaseDefence.new(engaged_, _with_rampart(side_, rampart), KernelGarrison.STOCK_KEY)


## `BaseDefence.of`: the units on the base and the Citadel rampart.
static func of(target: Player) -> BaseDefence:
	var engaged_ := RaidBattle.defenders_of(target)
	var boost := FightMonsterHelpers.unit_boost_of(target, false, true)
	var side_ := CombatantBuilder.player_combatants_from(engaged_, boost, CombatSide.Value.MONSTER)
	var rampart := CoralCitadelRampart.combatant_of(target.buildings)
	return BaseDefence.new(engaged_, _with_rampart(side_, rampart), RaidBattle.BASE_LEVEL)


static func _with_rampart(side_: Array[Combatant], rampart: Combatant) -> Array[Combatant]:
	if rampart != null:
		side_.append(_on_defenders_side(rampart))
	return side_


## A fresh copy of `c` on the defenders' side, at full health.
static func _on_defenders_side(c: Combatant) -> Combatant:
	return Combatant.new(CombatSide.Value.MONSTER, c.type_key, c.max_hp, c.atk, c.def)


## Sends the survivors and the wounded back to the base once the fight is
## over; the dead are gone.
func settle(target: Player, random: DartRandom = null) -> DefenceOutcome:
	var pct_lost := FightMonsterHelpers.compute_pct_lost(side, side)
	var alive: Array[Combatant] = []
	var fallen: Array[Combatant] = []
	for c: Combatant in side:
		if c.is_alive():
			alive.append(c)
		else:
			fallen.append(c)
	var split := CasualtyCalculator.new(random).partition(fallen, pct_lost)
	var units := target.units_on_level(level)
	for type: UnitType.Value in engaged:
		units[type].count = 0
	FightMonsterHelpers.restore_to_stock(target, alive, level)
	FightMonsterHelpers.restore_to_stock(target, split.wounded, level)
	var initial: Array[Combatant] = []
	for c: Combatant in side:
		initial.append(_on_defenders_side(c))
	return DefenceOutcome.new(
		engaged, FightMonsterHelpers.combatants_by_type(alive),
		FightMonsterHelpers.combatants_by_type(split.wounded),
		FightMonsterHelpers.combatants_by_type(split.dead), initial,
	)
