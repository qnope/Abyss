class_name Squad
extends Node3D
## The squad of one unit on the parade ground: its drill pad, ringed in the
## unit's colour, the figures standing on it (as many as the count's tier,
## each what [WorldModels] gives for the unit), the plaque over them and, over
## that, the sign of a squad that can recruit (a green plus) or that the
## barracks is too low for (a padlock). Its origin is the pad's centre on the
## deck.

## The pad's thickness, and how high the plaque and the sign float.
const PAD_HEIGHT := 0.12
const PLAQUE_HEIGHT := 2.2
const SIGN_HEIGHT := 3.0
## How high a tap picks the squad.
const REACH := 2.2

var type: UnitType.Value
var state: SquadState
var plaque := SquadPlaque.new()
## The figures standing, and the sign over them.
var figures := Node3D.new()
var marks := Node3D.new()
var _ring := MeshInstance3D.new()


func _init(type_: UnitType.Value) -> void:
	type = type_
	name = StringName("Squad%d" % type)
	position = ParadeLayout.pad_of(type)
	var width := ParadeLayout.PAD * ParadeLayout.CELL
	var pad := MeshInstance3D.new()
	pad.name = &"Pad"
	var disc := CylinderMesh.new()
	disc.top_radius = width / 2.0
	disc.bottom_radius = width / 2.0
	disc.height = PAD_HEIGHT
	pad.mesh = disc
	pad.position.y = PAD_HEIGHT / 2.0
	pad.material_override = _material(0.3)
	_ring.name = &"Ring"
	var torus := TorusMesh.new()
	torus.outer_radius = width / 2.0
	torus.inner_radius = width / 2.0 - 0.08
	_ring.mesh = torus
	_ring.position.y = PAD_HEIGHT
	_ring.material_override = _material(1.0)
	figures.name = &"Figures"
	marks.name = &"Marks"
	plaque.position.y = PLAQUE_HEIGHT
	for part: Node in [pad, _ring, figures, marks, plaque]:
		add_child(part)


## The box a tap picks, in the parade's space: the pad's footprint up to
## [constant REACH].
func box() -> AABB:
	var width := ParadeLayout.PAD * ParadeLayout.CELL
	return AABB(position + Vector3(-width / 2.0, 0.0, -width / 2.0), Vector3(width, REACH, width))


## Stands the squad of [param next]: its figures, its plaque and its sign.
func show_state(next: SquadState) -> void:
	state = next
	for old in figures.get_children():
		# Freed in the tree: a node with its own materials, freed outside it,
		# makes the renderer complain.
		old.free()
	for old in marks.get_children():
		old.free()
	for index in next.figures():
		var figure := WorldModels.unit(type, next.locked)
		figure.position = ParadeLayout.slot(index) + Vector3(0.0, PAD_HEIGHT, 0.0)
		figures.add_child(figure)
	plaque.show_state(next)
	_ring.visible = not next.locked
	if next.locked:
		_sign(PadMark.new(PadMark.Kind.LOCKED))
	elif next.recruitable:
		var plus := PadMark.new(PadMark.Kind.BUILD)
		plus.modulate = WorldPalette.UPGRADE
		_sign(plus)


func _sign(mark: PadMark) -> void:
	mark.position.y = SIGN_HEIGHT
	marks.add_child(mark)


## The unit's colour, [param energy] of it glowing.
func _material(energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = WorldPalette.unit(type).darkened(0.6 * (1.0 - energy))
	material.emission_enabled = true
	material.emission = WorldPalette.unit(type)
	material.emission_energy_multiplier = energy * 0.6 + 0.1
	return material
