class_name TerrainGenerator
extends RefCounted
## lib/domain/map/terrain_generator.dart: the ground of a new map, plain
## everywhere.


## One bare cell per cell of the grid. The dice and the base are not read,
## as in Dart: no die is drawn here.
static func generate(
	width: int, height: int, _random: DartRandom, _base_x: int, _base_y: int
) -> Array[MapCell]:
	var cells: Array[MapCell] = []
	cells.resize(width * height)
	for index: int in cells.size():
		cells[index] = MapCell.new(TerrainType.Value.PLAIN)
	return cells
