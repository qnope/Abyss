extends RefCounted
## What the review board's grid wears besides the floor (grid_view.gd): the
## fog over the cells not seen, its wisps drifting off the edge of the seen
## patch, and the backdrop round the map's edge, each when its model exists in
## assets/models/.

const GridLayout := preload("res://tool/models/grid_layout.gd")
const GridBackdrop := preload("res://tool/models/grid_backdrop.gd")
const GridInstances := preload("res://tool/models/grid_instances.gd")
const FOG := "res://assets/models/map_fog.glb"
const BACKDROP := "res://assets/models/map_backdrop_%d.glb"
const NEIGHBOURS: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]


## Dresses [param floor_], a board [param side] cells wide whose unseen cells
## are under the fog when [param fogged], with the models of [param level].
static func dress(floor_: Node3D, side: int, fogged: bool, level: int) -> void:
	if fogged and ResourceLoader.exists(FOG):
		_fog(floor_, side)
	var path := BACKDROP % level
	if ResourceLoader.exists(path):
		var scene := (load(path) as PackedScene).instantiate() as Node3D
		GridBackdrop.dress(floor_, scene, side)
		scene.free()


## A cloud on each cell not seen, a wisp off each of them that touches one seen.
static func _fog(floor_: Node3D, side: int) -> void:
	var model := (load(FOG) as PackedScene).instantiate() as Node3D
	var clouds := GridInstances.meshes(model, "Cloud")
	var wisps := GridInstances.meshes(model, "Wisp")
	var dice := RandomNumberGenerator.new()
	dice.seed = 5
	var cloud_places: Array[Array] = []
	var wisp_places: Array[Array] = []
	for mesh in clouds:
		cloud_places.append([])
	for mesh in wisps:
		wisp_places.append([])
	for y in side:
		for x in side:
			if GridLayout.seen(x, y, side):
				continue
			var at := MapGrid.at(x, y, side, side)
			var turn := Basis(Vector3.UP, dice.randf() * TAU)
			cloud_places[dice.randi() % clouds.size()].append(Transform3D(Basis.IDENTITY, at))
			for step in NEIGHBOURS:
				if GridLayout.seen(x + step.x, y + step.y, side):
					var out := at + Vector3(step.x, 0.0, step.y) * 0.4 + Vector3.UP * 0.1
					wisp_places[dice.randi() % wisps.size()].append(Transform3D(turn, out))
	for index in clouds.size():
		floor_.add_child(GridInstances.multi(clouds[index], cloud_places[index]))
	for index in wisps.size():
		floor_.add_child(GridInstances.multi(wisps[index], wisp_places[index]))
	model.free()
