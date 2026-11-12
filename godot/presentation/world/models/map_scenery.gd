class_name MapScenery
extends RefCounted
## The models of the map that are not what stands on its cells: the floor of
## each level (tiles), the fog, the backdrop round the slab and the creature
## that swims by, all of assets/models/. Each is told by its parts, the nodes
## of the glb, which the map repeats on its cells.

const LEVELS := 3

const TERRAINS: Array[PackedScene] = [
	preload("res://assets/models/map_terrain_1.glb"),
	preload("res://assets/models/map_terrain_2.glb"),
	preload("res://assets/models/map_terrain_3.glb"),
]
const BACKDROPS: Array[PackedScene] = [
	preload("res://assets/models/map_backdrop_1.glb"),
	preload("res://assets/models/map_backdrop_2.glb"),
	preload("res://assets/models/map_backdrop_3.glb"),
]
const CREATURES: Array[PackedScene] = [
	preload("res://assets/models/map_turtle.glb"),
	preload("res://assets/models/map_jelly.glb"),
	preload("res://assets/models/map_ray.glb"),
]
const FOG: PackedScene = preload("res://assets/models/map_fog.glb")


## The index in the three models of a level (1 and up): the deepest model
## serves the levels below it.
static func index_of(level: int) -> int:
	return clampi(level, 1, LEVELS) - 1


## The meshes of the nodes of [param scene], by the name of the node, in the
## order of the glb. The scene is freed: the meshes are the scene's own.
static func parts(scene: PackedScene) -> Dictionary[StringName, Mesh]:
	var found: Dictionary[StringName, Mesh] = {}
	var root := scene.instantiate()
	for child in root.get_children():
		if child is MeshInstance3D:
			found[child.name] = (child as MeshInstance3D).mesh
	root.free()
	return found


## The names of [param parts] that start with [param prefix] ("Lit", "Edge").
static func named(parts_: Dictionary[StringName, Mesh], prefix: String) -> Array[StringName]:
	var names: Array[StringName] = []
	for part_name in parts_:
		if String(part_name).begins_with(prefix):
			names.append(part_name)
	return names
