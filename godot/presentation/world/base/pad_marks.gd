class_name PadMarks
extends Node3D
## What floats over the pads of the base, drawn again with each change of the
## base: over a building its level and, above it, a sign (it can rise, or it
## is degraded); over a plot a plus when it can be built on, a padlock when a
## prerequisite holds it back. The signs clear the building whatever it is,
## model or stand-in ([ModelBounds]).

## The gaps above a building's top: to the level's centre, then to the sign's.
const LEVEL_GAP := 0.4
const SIGN_GAP := 1.0
## How high over an empty pad its sign floats.
const PLOT_HEIGHT := 0.8


## Draws the marks of [param states] over their [param pads], above the
## buildings that stand in [param buildings].
func show_marks(states: Array[PadState], pads: BasePads, buildings: BaseBuildings) -> void:
	for child: Node in get_children():
		child.free()
	for state in states:
		var origin := pads.origin_of(state.pad())
		if state.is_built():
			var top := ModelBounds.top_of(buildings.building(state.pad()))
			_add(PadLevelLabel.new(state.level), origin, top + LEVEL_GAP)
			# A degraded building is warned of, whatever else it could do.
			if state.degraded:
				_add(PadMark.new(PadMark.Kind.DEGRADED), origin, top + SIGN_GAP)
			elif state.upgradable:
				_add(PadMark.new(PadMark.Kind.UPGRADE), origin, top + SIGN_GAP)
		elif state.locked:
			_add(PadMark.new(PadMark.Kind.LOCKED), origin, origin.y + PLOT_HEIGHT)
		elif state.upgradable:
			_add(PadMark.new(PadMark.Kind.BUILD), origin, origin.y + PLOT_HEIGHT)


func _add(mark: Node3D, origin: Vector3, height: float) -> void:
	mark.position = Vector3(origin.x, height, origin.z)
	add_child(mark)
