class_name MapTint
extends RefCounted
## What a map model of a held post, a rival base or the volcano's seal puts in
## the colour of whoever holds it: its node `Tint`, one lamp of a neutral white
## whose surface is given the colour, glowing as it did.

## The node of a model that takes the colour.
const NODE := &"Tint"


## Colours the node `Tint` of [param model] with [param colour]; a model with no
## such node stays as it is.
static func apply(model: Node, colour: Color) -> void:
	var lamp := model.find_child(NODE, true, false) as MeshInstance3D
	if lamp == null:
		return
	for surface in lamp.mesh.get_surface_count():
		var material := lamp.mesh.surface_get_material(surface).duplicate() as StandardMaterial3D
		material.albedo_color = colour
		if material.emission_enabled:
			material.emission = colour
		lamp.set_surface_override_material(surface, material)
