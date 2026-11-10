extends RefCounted
## The extent of a model, from the meshes under it.


## The box around every mesh of [param model], in the model's space.
static func of(model: Node3D) -> AABB:
	var bounds := AABB()
	var first := true
	for node: Node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		var box := _transform_to(model, mesh) * mesh.get_aabb()
		bounds = box if first else bounds.merge(box)
		first = false
	return bounds


## The radius around the vertical axis that holds the model's top, for the
## game's camera which frames the plateau, not what hangs under it.
static func top_radius(bounds: AABB) -> float:
	var x := maxf(absf(bounds.position.x), absf(bounds.end.x))
	var z := maxf(absf(bounds.position.z), absf(bounds.end.z))
	return Vector2(x, z).length() * 0.78


static func _transform_to(model: Node3D, node: Node3D) -> Transform3D:
	var transform := Transform3D.IDENTITY
	var current: Node = node
	while current != model and current is Node3D:
		transform = (current as Node3D).transform * transform
		current = current.get_parent()
	return transform
