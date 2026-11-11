class_name UnitStandIn
extends Node3D
## A unit with no model yet: its [StandInShape] solid in its colour
## ([WorldPalette]) standing on its origin, the floor under it. A locked unit
## is a ghost: the degraded grey, half there. Step 7 replaces it by a model of
## assets/models/ in [WorldModels], the one place that chooses.

var type: UnitType.Value
var ghost: bool
var shape: StandInShape
## The solid itself, lifted so that it stands on the floor.
var body := MeshInstance3D.new()


func _init(type_: UnitType.Value, ghost_ := false) -> void:
	type = type_
	ghost = ghost_
	shape = StandInShape.of_unit(type)
	body.name = &"Body"
	body.mesh = shape.mesh()
	body.position.y = shape.size.y / 2.0
	body.material_override = _material()
	add_child(body)


func _material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.roughness = 0.6
	if ghost:
		material.albedo_color = Color(WorldPalette.DEGRADED, WorldPalette.GHOST_OPACITY)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		return material
	material.albedo_color = WorldPalette.unit(type)
	material.emission_enabled = true
	material.emission = material.albedo_color
	material.emission_energy_multiplier = WorldPalette.GLOW
	return material
