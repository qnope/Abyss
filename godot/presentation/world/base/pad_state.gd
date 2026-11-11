class_name PadState
extends RefCounted
## What the base shows of one pad: the building that stands on it (its level,
## 0 while it is to build), whether the headquarters is too low for it
## (degraded), whether it can rise a level right now (upgradable: a plot
## that can be built on counts) and whether a missing prerequisite holds the
## plot back (locked). The base is drawn from one per pad.

var type: BuildingType.Value
var level: int
var degraded: bool
var upgradable: bool
var locked: bool


func _init(
	type_: BuildingType.Value, level_ := 0, degraded_ := false, upgradable_ := false, locked_ := false
) -> void:
	type = type_
	level = level_
	degraded = degraded_
	upgradable = upgradable_
	locked = locked_


## The name of the pad: the building's.
func pad() -> StringName:
	return BaseBuildings.pad_of(type)


func is_built() -> bool:
	return level > 0


## Everything the state tells, in a line: two states are the same when their
## signatures are.
func signature() -> String:
	return "%d:%d:%d%d%d" % [type, level, int(degraded), int(upgradable), int(locked)]


## The state of every building of [param held], in order. [param upgradable]
## and [param locked] are the sets of the buildings that can rise now and of
## the ones a prerequisite holds back (a plot only: a building that stands is
## never locked).
static func of_base(
	held: Dictionary[BuildingType.Value, Building],
	upgradable: Dictionary[BuildingType.Value, bool] = {},
	locked: Dictionary[BuildingType.Value, bool] = {},
) -> Array[PadState]:
	var states: Array[PadState] = []
	for type: BuildingType.Value in held:
		var level := held[type].level
		states.append(PadState.new(type, level, BuildingDegradation.is_degraded(held, type),
			upgradable.has(type), level == 0 and locked.has(type)))
	return states


## The states of the pads named [param names], each standing at level 1 and
## nothing else: the prototype's and the menus' base.
static func standing(names: Array[StringName]) -> Array[PadState]:
	var states: Array[PadState] = []
	for name in names:
		states.append(PadState.new(BaseBuildings.type_of(name), 1))
	return states


## The signature of [param states].
static func signature_of(states: Array[PadState]) -> String:
	var parts := PackedStringArray()
	for state in states:
		parts.append(state.signature())
	return ",".join(parts)
