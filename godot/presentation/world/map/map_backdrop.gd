class_name MapBackdrop
extends MapLayers
## The scenery round the slab of the map (map_backdrop_<n>): the rim's straight
## pieces, 2 long and falling away to the outside, along each side, a corner
## piece at each corner, and the far silhouettes (kelp, a whale, spires) beyond.
## The rim is repeated from the pieces the model gives, so the map can be of any
## size. It takes shadows only while the view is close ([MapLayers]), and stays
## as it is while the map drawn again has the same model and size.

const PIECE := 2.0
## The yaw of the south, west, north and east sides: the pieces as modelled stand
## on the south one, outward +z.
const SIDES: Array[float] = [0.0, -90.0, 180.0, 90.0]


## Dresses the map of [param width] by [param height] cells with the backdrop
## of [param level] in place of the one before; the same again lays nothing.
func show_level(level: int, width: int, height: int) -> void:
	var model := MapScenery.index_of(level)
	if _laid.again([model, width, height]):
		return
	_clear()
	var parts := MapScenery.parts(MapScenery.BACKDROPS[model])
	var edges := MapScenery.named(parts, "Edge")
	var edge_spots := edge_places(width, height)
	for index in edges.size():
		var mine: Array[Transform3D] = []
		for at in range(index, edge_spots.size(), edges.size()):
			mine.append(edge_spots[at])
		_lay(edges[index], parts[edges[index]], mine)
	_lay(&"Corner", parts[&"Corner"], corner_places(width, height))
	var spots := far_places(width, height)
	var far := 0
	for part_name in parts:
		if part_name == &"Corner" or edges.has(part_name):
			continue
		var spot := spots[far % spots.size()]
		_lay(part_name, parts[part_name], [Transform3D(Basis.IDENTITY, spot)])
		far += 1


## Where the straight pieces go, in the order along the four sides: a piece
## every [constant PIECE] along a side, the run centred on it.
static func edge_places(width: int, height: int) -> Array[Transform3D]:
	var found: Array[Transform3D] = []
	for turn in SIDES:
		var across := width if absf(turn) != 90.0 else height
		var depth := height if absf(turn) != 90.0 else width
		var basis := Basis(Vector3.UP, deg_to_rad(turn))
		var count := ceili(across / PIECE)
		for index in count:
			var along := (index - (count - 1) / 2.0) * PIECE
			found.append(Transform3D(basis, basis * Vector3(along, 0.0, depth / 2.0)))
	return found


## Where the corner pieces go: one at each corner of the slab.
static func corner_places(width: int, height: int) -> Array[Transform3D]:
	var found: Array[Transform3D] = []
	for turn in SIDES:
		var across := width if absf(turn) != 90.0 else height
		var depth := height if absf(turn) != 90.0 else width
		var basis := Basis(Vector3.UP, deg_to_rad(turn))
		found.append(Transform3D(basis, basis * Vector3(across / 2.0, 0.0, depth / 2.0)))
	return found


## The spots of the far silhouettes, behind the back of the slab and to its
## side.
static func far_places(width: int, height: int) -> Array[Vector3]:
	return [Vector3(-width * 0.3, 0.0, -height / 2.0 - 5.0),
		Vector3(width * 0.3, 0.0, -height / 2.0 - 6.0), Vector3(-width / 2.0 - 5.0, 0.0, height * 0.2)]
