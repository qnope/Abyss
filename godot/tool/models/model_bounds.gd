extends RefCounted
## The extent of a model, from the meshes under it.


## The box around every mesh of [param model], in the model's space, or in its
## parent's when [param turned] (a creature the renders turned to the camera).
static func of(model: Node3D, turned := false) -> AABB:
	var bounds := AABB()
	var first := true
	for node: Node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		var transform := _transform_to(model, mesh)
		var box := _tight(mesh, model.transform * transform) if turned else transform * mesh.get_aabb()
		bounds = box if first else bounds.merge(box)
		first = false
	return bounds


## The radius around the vertical axis that holds the model's top, for the
## game's camera which frames the plateau, not what hangs under it.
static func top_radius(bounds: AABB) -> float:
	var x := maxf(absf(bounds.position.x), absf(bounds.end.x))
	var z := maxf(absf(bounds.position.z), absf(bounds.end.z))
	return Vector2(x, z).length() * 0.78


## The box round the vertices of [param mesh] moved by [param transform]: tighter
## than the moved box of its own, which a turn makes larger.
static func _tight(mesh: MeshInstance3D, transform: Transform3D) -> AABB:
	var faces := mesh.mesh.get_faces()
	var box := AABB(transform * faces[0], Vector3.ZERO)
	for corner in faces:
		box = box.expand(transform * corner)
	return box


static func _transform_to(model: Node3D, node: Node3D) -> Transform3D:
	var transform := Transform3D.IDENTITY
	var current: Node = node
	while current != model and current is Node3D:
		transform = (current as Node3D).transform * transform
		current = current.get_parent()
	return transform
