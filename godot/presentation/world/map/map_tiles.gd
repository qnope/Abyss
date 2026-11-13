class_name MapTiles
extends MapLayers
## The floor of the map: one tile of the level's floor model (map_terrain_<n>)
## per cell, laid by [method MapScenery.parts] in one MultiMesh for each of its
## tiles (a handful of draw calls for the whole level). A cell seen takes one of
## the lit tiles and a cell not seen one of the tiles under the fog, lower and
## dark; which one, and its quarter turn, come from the cell alone, so that the
## floor is the same every time and any two tiles meet. It takes shadows only
## while the view is close ([MapLayers]). The map is drawn again on each action
## of the player: the same floor again (the same model, size and cells seen)
## keeps its layers, and any other is laid whole.

## How many tiles lie on the floor, by the name of the tile ("Lit2").
var counts: Dictionary[StringName, int] = {}


## Lays the floor of [param looks] (the cells of a map [param width] by
## [param height], in the order of the grid), with the tiles of [param level],
## in place of the one before; the same floor again lays nothing.
func show_looks(looks: Array[MapLook], width: int, height: int, level := 1) -> void:
	var model := MapScenery.index_of(level)
	if _laid.again([model, width, height, _seen(looks, width)]):
		return
	_clear()
	counts.clear()
	var parts := MapScenery.parts(MapScenery.TERRAINS[model])
	var lit := MapScenery.named(parts, "Lit")
	var fog := MapScenery.named(parts, "Fog")
	var spots: Dictionary[StringName, Array] = {}
	for look in looks:
		var variants := lit if look.revealed else fog
		var chosen := variants[hash_of(look.x, look.y) % variants.size()]
		var centre := MapGrid.at(look.x, look.y, width, height)
		if not spots.has(chosen):
			spots[chosen] = []
		spots[chosen].append(Transform3D(turn_of(look.x, look.y), centre))
	for part_name in spots:
		var tiles: Array = spots[part_name]
		counts[part_name] = tiles.size()
		_lay(part_name, parts[part_name], tiles)


## A number of the cell ([param x], [param y]) alone, never negative.
static func hash_of(x: int, y: int) -> int:
	return ((x * 73856093) ^ (y * 19349663)) & 0x7fffffff


## The quarter turn of the tile of the cell ([param x], [param y]).
static func turn_of(x: int, y: int) -> Basis:
	return Basis(Vector3.UP, ((hash_of(x, y) >> 12) & 3) * PI / 2.0)


## The cells of [param looks] (a map [param width] wide), each with whether it
## is seen: what its tile depends on.
static func _seen(looks: Array[MapLook], width: int) -> PackedInt32Array:
	var found := PackedInt32Array()
	for look in looks:
		found.append((look.y * width + look.x) * 2 + int(look.revealed))
	return found
