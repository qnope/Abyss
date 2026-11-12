class_name MapProbe
extends RefCounted
## What a test can ask of what stands on a map cell, a model or a stand-in.


## Whether [param content] shows as emptied: a stand-in's flag, or the veil a
## model wears over each of its meshes.
static func is_dimmed(content: Node) -> bool:
	if content is MapStandIn:
		return (content as MapStandIn).dimmed
	for mesh: Node in content.find_children("*", "GeometryInstance3D", true, false):
		if (mesh as GeometryInstance3D).material_overlay == null:
			return false
	return true


## The colour a held content shows: the stand-in's body, or the model's `Tint`.
static func tint_of(content: Node) -> Color:
	var material: StandardMaterial3D
	if content is MapStandIn:
		material = (content as MapStandIn).body.material_override as StandardMaterial3D
	else:
		var lamp := content.find_child(MapTint.NODE, true, false) as MeshInstance3D
		material = lamp.get_surface_override_material(0) as StandardMaterial3D
		if material == null:
			material = lamp.mesh.surface_get_material(0) as StandardMaterial3D
	return material.albedo_color
