class_name MapLayer
extends RefCounted
## A piece of the map's floor or scenery repeated: one MultiMesh, so a single
## draw call however many places it stands in, and no shadow cast (a pass of
## hundreds of tiles and rocks costs more than what it would ground).


## The layer named [param part_name] drawing [param mesh] at each of
## [param places] (Transform3D).
static func of(part_name: StringName, mesh: Mesh, places: Array) -> MultiMeshInstance3D:
	var layer := MultiMeshInstance3D.new()
	layer.name = part_name
	layer.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	layer.multimesh = MultiMesh.new()
	layer.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	layer.multimesh.mesh = mesh
	layer.multimesh.instance_count = places.size()
	for index in places.size():
		var at: Transform3D = places[index]
		layer.multimesh.set_instance_transform(index, at)
	return layer
