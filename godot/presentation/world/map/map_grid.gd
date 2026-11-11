class_name MapGrid
extends RefCounted
## Where each cell stands in the map's scene, in metres: cells 1 wide on the
## plane y = 0, the map centred on the origin, the first row at the back (the
## top of the screen) and the first column on the left.

## The side of a cell, and the highest a stand-in rises (the volcano), which
## the camera's frame allows for.
const CELL := 1.0
const TALLEST := 2.0
## The deepest the tiles go under their top.
const DEPTH := 0.6


## The centre of the cell ([param x], [param y]) on the floor, in a map of
## [param width] by [param height] cells.
static func at(x: int, y: int, width: int, height: int) -> Vector3:
	return Vector3((x + 0.5 - width / 2.0) * CELL, 0.0, (y + 0.5 - height / 2.0) * CELL)


## The cell under [param point], or null when it falls off the map.
static func cell_at(point: Vector3, width: int, height: int) -> Variant:
	var x := floori(point.x / CELL + width / 2.0)
	var y := floori(point.z / CELL + height / 2.0)
	if x < 0 or y < 0 or x >= width or y >= height:
		return null
	return Vector2i(x, y)


## The points the camera's default view fits to the screen: the corners of
## the map, down to its tiles' foot and up to its tallest stand-in.
static func outline(width: int, height: int) -> PackedVector3Array:
	var points := PackedVector3Array()
	for corner_x: float in [-0.5, 0.5]:
		for corner_z: float in [-0.5, 0.5]:
			for level: float in [-DEPTH, TALLEST]:
				points.append(Vector3(corner_x * width * CELL, level, corner_z * height * CELL))
	return points
