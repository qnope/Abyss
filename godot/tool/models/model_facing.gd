extends RefCounted
## Which way the renders of tool/models turn a creature. A model that moves (a
## unit or a monster: it has a `Rig`) is built facing Godot's forward, -Z, so
## the renders turn it toward the camera, as the game turns its figures: a
## building is built facing the camera already and is left alone.

## The yaw, in degrees, that faces the game's camera (standing at +x, +z) and
## the one that faces a camera at +z.
const GAME := -135.0
const FRONT := 180.0


## Whether [param model] is a creature: it holds a rig.
static func is_creature(model: Node) -> bool:
	return model.find_child("Rig", true, false) != null


## Turns [param model] to [param yaw] degrees when it is a creature; a building
## stays as it is.
static func face(model: Node3D, yaw: float) -> void:
	if is_creature(model):
		model.rotation_degrees.y = yaw
