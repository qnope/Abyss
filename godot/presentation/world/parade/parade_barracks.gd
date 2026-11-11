class_name ParadeBarracks
extends Node3D
## The barracks at the back of the parade ground, what unlocks the units: the
## building on its plot with its level over it (greyed and warned of when it
## is degraded), or the bare plot with a plus when it can be built and a
## padlock when a prerequisite holds it back. Drawn from the [PadState] the
## base uses, the signs clearing the building as on the base ([PadMarks]).

## The plot's footprint in cells, as wide as a pad of the base, and how high
## it stands.
const FOOTPRINT := 2.0
const PLOT_HEIGHT := 0.12
## How high a bare plot is picked, and how far above a building's top.
const PLOT_REACH := 0.8
const REACH_MARGIN := 0.3

var state: PadState
var plot := MeshInstance3D.new()
var building: Node3D
var _reach := PLOT_REACH
var _shown: Array[Node] = []


func _init() -> void:
	name = &"Barracks"
	position = ParadeLayout.at(ParadeLayout.BARRACKS)
	var disc := CylinderMesh.new()
	disc.top_radius = FOOTPRINT * ParadeLayout.CELL / 2.0
	disc.bottom_radius = disc.top_radius
	disc.height = PLOT_HEIGHT
	plot.name = &"Plot"
	plot.mesh = disc
	plot.position.y = PLOT_HEIGHT / 2.0
	var stone := StandardMaterial3D.new()
	stone.albedo_color = WorldPalette.PLOT
	plot.material_override = stone
	add_child(plot)


## The box a tap picks, in the parade's space.
func box() -> AABB:
	var width := FOOTPRINT * ParadeLayout.CELL
	return AABB(position + Vector3(-width / 2.0, 0.0, -width / 2.0), Vector3(width, _reach, width))


## Stands the barracks of [param next]: the building at its level or the plot
## to build, with the signs of what it needs.
func show_state(next: PadState) -> void:
	state = next
	for old in _shown:
		# Freed in the tree, as the base's buildings are.
		old.free()
	_shown.clear()
	building = null
	plot.visible = not next.is_built()
	if not next.is_built():
		_reach = PLOT_REACH
		if next.locked:
			_add(PadMark.new(PadMark.Kind.LOCKED), PadMarks.PLOT_HEIGHT)
		elif next.upgradable:
			_add(PadMark.new(PadMark.Kind.BUILD), PadMarks.PLOT_HEIGHT)
		return
	building = WorldModels.building(BuildingType.Value.BARRACKS, next.level, next.degraded)
	add_child(building)
	_shown.append(building)
	var top := ModelBounds.top_of(building)
	_reach = top + REACH_MARGIN
	_add(PadLevelLabel.new(next.level), top + PadMarks.LEVEL_GAP)
	if next.degraded:
		_add(PadMark.new(PadMark.Kind.DEGRADED), top + PadMarks.SIGN_GAP)
	elif next.upgradable:
		_add(PadMark.new(PadMark.Kind.UPGRADE), top + PadMarks.SIGN_GAP)


func _add(mark: Node3D, height: float) -> void:
	mark.position.y = height
	add_child(mark)
	_shown.append(mark)
