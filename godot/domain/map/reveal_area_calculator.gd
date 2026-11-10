class_name RevealAreaCalculator
extends RefCounted
## lib/domain/map/reveal_area_calculator.dart: the cells a base or a scout
## reveals, a square clipped by the edges of the map.

## Side of the square revealed around the base when a game starts.
const BASE_SIDE := 5


## The square of BASE_SIDE revealed around the base at (`base_x`, `base_y`)
## when a game starts.
static func around_base(
	base_x: int, base_y: int, map_width: int, map_height: int
) -> Array[GridPosition]:
	return cells_to_reveal(base_x, base_y, BASE_SIDE, map_width, map_height)


## The cells of the square of `side` centred on the target, row by row.
static func cells_to_reveal(
	target_x: int, target_y: int, side: int, map_width: int, map_height: int
) -> Array[GridPosition]:
	var half := DartMath.trunc_div(side, 2)
	var start_x := target_x - half
	var start_y := target_y - half
	var positions: Array[GridPosition] = []
	for dy: int in side:
		for dx: int in side:
			var x := start_x + dx
			var y := start_y + dy
			if x >= 0 and x < map_width and y >= 0 and y < map_height:
				positions.append(GridPosition.new(x, y))
	return positions
