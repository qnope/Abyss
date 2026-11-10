class_name StartingBasePlacer
extends RefCounted
## lib/domain/map/starting_base_placer.dart: picks the starting bases of the
## other players, far from each other.

const _MARGIN := 2
const _FAR := 1 << 30


## `first` and then `count` - 1 more bases on a `size` map: each one is
## drawn among the cells farthest from the bases already placed. The centre,
## where the Noyau stands, is never taken.
##
## Dart scores every cell against every base again for each base; this
## keeps the distance from each cell to its nearest base and only measures
## the last one placed, which gives the same scores. A map too small to
## hold a cell makes Dart throw: this logs an error and stops placing.
static func place(
	size: int, first: GridPosition, count: int, random: DartRandom
) -> Array[GridPosition]:
	var bases: Array[GridPosition] = [first]
	if count <= 1:
		return bases
	var centre := DartMath.trunc_div(size, 2)
	var cells: Array[Vector2i] = []
	for y: int in range(_MARGIN, size - _MARGIN):
		for x: int in range(_MARGIN, size - _MARGIN):
			if x != centre or y != centre:
				cells.append(Vector2i(x, y))
	if cells.is_empty():
		push_error("StartingBasePlacer.place: no cell for a base on a map of %d" % size)
		return bases
	var nearest := PackedInt32Array()
	nearest.resize(cells.size())
	nearest.fill(_FAR)
	while bases.size() < count:
		var last: GridPosition = bases[-1]
		var best := 0
		for index: int in cells.size():
			var cell := cells[index]
			var distance := maxi(absi(cell.x - last.x), absi(cell.y - last.y))
			if distance < nearest[index]:
				nearest[index] = distance
			best = maxi(best, nearest[index])
		var pool: Array[int] = []
		for index: int in cells.size():
			if nearest[index] >= best - 1:
				pool.append(index)
		bases.append(GridPosition.of_key(cells[pool[random.next_int(pool.size())]]))
	return bases
