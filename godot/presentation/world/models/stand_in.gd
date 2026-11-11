class_name StandIn
extends Node3D
## A building with no model yet: its [StandInShape] solid in its colour
## ([WorldPalette]) standing on its origin, the pad's top centre. It rises
## with the building's tier (taller at each band of levels) and turns grey
## when the building is degraded. Step 7 replaces it by a model of
## assets/models/ in [WorldModels], the one place that chooses.

## How much taller the solid is at each tier (index 0 is a plot's, never
## shown: the first tier's).
const TIER_HEIGHT: Array[float] = [1.0, 1.0, 1.3, 1.6]

var type: BuildingType.Value
var level: int
var degraded: bool
var shape: StandInShape
## The solid itself, lifted so that it stands on the pad.
var body := MeshInstance3D.new()


func _init(type_: BuildingType.Value, level_ := 1, degraded_ := false) -> void:
	type = type_
	level = level_
	degraded = degraded_
	shape = StandInShape.of(type)
	body.name = &"Body"
	body.mesh = shape.mesh()
	body.position.y = shape.size.y / 2.0
	body.material_override = _material()
	scale.y = TIER_HEIGHT[BuildingTier.of_level(level)]
	add_child(body)


func _material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = WorldPalette.DEGRADED if degraded else WorldPalette.of(type)
	material.roughness = 0.6
	if not degraded:
		material.emission_enabled = true
		material.emission = material.albedo_color
		material.emission_energy_multiplier = WorldPalette.GLOW
	return material
