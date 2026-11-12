extends RefCounted
## The floor of a board of cells: the tiles of assets/models/map_terrain_<level>.glb,
## one MultiMesh for each variant, laid in the variants and quarter turns of
## grid_layout.gd, the lit ones (and, when [param fogged], the fog's tiles
## beyond the patch GridLayout says is seen) and what covers them (grid_cover.gd).

const GridLayout := preload("res://tool/models/grid_layout.gd")
const GridCover := preload("res://tool/models/grid_cover.gd")
const GridInstances := preload("res://tool/models/grid_instances.gd")


## The floor of [param side] x [param side] cells of [param level].
static func build(level: int, side: int, fogged: bool) -> Node3D:
	var floor_ := Node3D.new()
	var scene := load("res://assets/models/map_terrain_%d.glb" % level) as PackedScene
	var model := scene.instantiate() as Node3D
	var lit := GridInstances.meshes(model, "Lit")
	var hidden := GridInstances.meshes(model, "Fog")
	var variants := GridLayout.variants(side, side, lit.size())
	var turns := GridLayout.turns(side, side)
	var meshes: Dictionary[String, Mesh] = {}
	var places: Dictionary[String, Array] = {}
	for y in side:
		for x in side:
			var seen := not fogged or GridLayout.seen(x, y, side)
			var tiles := lit if seen else hidden
			var variant := variants[y * side + x] % tiles.size()
			var key := "%s%d" % ["Lit" if seen else "Fog", variant]
			if not meshes.has(key):
				meshes[key] = tiles[variant]
				places[key] = []
			places[key].append(Transform3D(Basis(Vector3.UP, turns[y * side + x] * PI / 2.0),
				MapGrid.at(x, y, side, side)))
	for key: String in meshes:
		floor_.add_child(GridInstances.multi(meshes[key], places[key], key))
	model.free()
	GridCover.dress(floor_, side, fogged, level)
	return floor_
