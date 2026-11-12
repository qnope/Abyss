extends RefCounted
## The two chores of the review board's grid (grid_floor.gd, grid_cover.gd):
## the meshes of a model's numbered nodes, and a MultiMesh laying one of them
## in many places.


## The meshes of the nodes [param prefix]1, [param prefix]2... of [param model], up to 8.
static func meshes(model: Node3D, prefix: String) -> Array[Mesh]:
	var found: Array[Mesh] = []
	for index in 8:
		var node := model.get_node_or_null("%s%d" % [prefix, index + 1]) as MeshInstance3D
		if node != null:
			found.append(node.mesh)
	return found


## [param mesh] laid at each of [param places] ([Transform3D]s), in one draw call.
static func multi(mesh: Mesh, places: Array, label := "") -> MultiMeshInstance3D:
	var instance := MultiMeshInstance3D.new()
	if label != "":
		instance.name = label
	instance.multimesh = MultiMesh.new()
	instance.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	instance.multimesh.mesh = mesh
	instance.multimesh.instance_count = places.size()
	for index in places.size():
		var at: Transform3D = places[index]
		instance.multimesh.set_instance_transform(index, at)
	return instance
