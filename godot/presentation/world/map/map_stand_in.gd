class_name MapStandIn
extends Node3D
## What stands on a cell of the map until its model exists: the [MapContent]
## solid of a kind, in its colour or the tint of its holder, standing on its
## origin, the floor under it. An emptied one is dull and does not glow. The
## volcano wears a ring at its foot, the seal of its owner. Step 7 replaces
## it by a model of assets/models/ in [WorldModels], the one place that chooses.

## The seal's thickness, in metres.
const SEAL_THICKNESS := 0.12

var kind: MapContent.Kind
var dimmed: bool
var shape: StandInShape
## The solid itself, lifted so that it stands on the floor.
var body := MeshInstance3D.new()
## The ring a held volcano wears, or null.
var seal: MeshInstance3D = null


## A stand-in of [param kind]; [param tint] (a Color, or null) takes the place
## of its own colour, and on the volcano is the colour of the seal.
func _init(kind_: MapContent.Kind, tint: Variant = null, dimmed_ := false) -> void:
	kind = kind_
	dimmed = dimmed_
	shape = MapContent.shape_of(kind)
	var is_kernel := kind == MapContent.Kind.KERNEL
	var colour := MapContent.colour_of(kind)
	var tinted := colour
	if tint != null:
		tinted = tint
	if not is_kernel:
		colour = tinted
	body.name = &"Body"
	body.mesh = shape.mesh()
	body.position.y = shape.size.y / 2.0
	body.material_override = _material(colour)
	add_child(body)
	if is_kernel and tint != null:
		_add_seal(tinted)


func _add_seal(colour: Color) -> void:
	var ring := TorusMesh.new()
	ring.outer_radius = shape.size.x / 2.0
	ring.inner_radius = shape.size.x / 2.0 - SEAL_THICKNESS
	seal = MeshInstance3D.new()
	seal.name = &"Seal"
	seal.mesh = ring
	seal.position.y = SEAL_THICKNESS / 2.0
	seal.material_override = _material(colour)
	add_child(seal)


func _material(colour: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.roughness = 0.6
	material.albedo_color = WorldPalette.DEGRADED if dimmed else colour
	if not dimmed:
		material.emission_enabled = true
		material.emission = colour
		material.emission_energy_multiplier = WorldPalette.GLOW
	return material
