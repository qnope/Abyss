class_name ModelBounds
extends RefCounted
## Where a model, or a stand-in, ends: the same for both, so that what floats
## over a building (its level, its marks) clears it whatever it is.


## The highest point of the meshes under [param node], in the space of its
## parent (the base's, for a building standing on its pad). 0 when it holds no
## mesh.
static func top_of(node: Node3D) -> float:
	return _top(node, node.transform, 0.0)


static func _top(node: Node3D, to_space: Transform3D, so_far: float) -> float:
	var top := so_far
	var mesh := node as MeshInstance3D
	if mesh != null and mesh.mesh != null:
		top = maxf(top, (to_space * mesh.mesh.get_aabb()).end.y)
	for child: Node in node.get_children():
		var part := child as Node3D
		if part != null:
			top = maxf(top, _top(part, to_space * part.transform, top))
	return top
