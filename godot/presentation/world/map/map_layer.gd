class_name MapLayer
extends MultiMeshInstance3D
## A piece of the map's floor or scenery repeated: one MultiMesh, so a single
## draw call however many places it stands in, and no shadow cast (a pass of
## hundreds of tiles and rocks costs more than what it would ground). It takes
## the shadows of what stands on the map or not ([method receive_shadows]) by
## drawing the mesh of its model or the twin of it that takes none
## ([ShadowlessMesh]), in the same places.

var _mesh: Mesh


## The layer named [param part_name] drawing [param mesh] at each of
## [param places] (Transform3D), as its model does or, when not
## [param receiving], taking no shadow.
func _init(part_name: StringName, mesh: Mesh, places: Array, receiving := true) -> void:
	name = part_name
	_mesh = mesh
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = places.size()
	for index in places.size():
		var at: Transform3D = places[index]
		multimesh.set_instance_transform(index, at)
	receive_shadows(receiving)


## Lets the layer take the shadows its model takes, or none.
func receive_shadows(on: bool) -> void:
	multimesh.mesh = _mesh if on else ShadowlessMesh.of(_mesh)
