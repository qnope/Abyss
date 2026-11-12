extends RefCounted
## Which tile goes on which cell of the review board of the map's floor
## (grid_view.gd): a variant for each cell that never repeats its left or
## upper neighbour's, and a ragged region of cells seen with the rest under
## the fog, so that the board shows the seams between tiles of every variant
## and the edge between the lit and the dark.


## The variant, 0 to [param count] - 1, of each cell of a board of [param width]
## by [param height], row by row: never that of the cell on its left nor of the
## one above it, and the same for the same [param seed].
static func variants(width: int, height: int, count: int, seed_ := 7) -> PackedInt32Array:
	var dice := RandomNumberGenerator.new()
	dice.seed = seed_
	var result := PackedInt32Array()
	for y in height:
		for x in width:
			var taken: Array[int] = []
			if x > 0:
				taken.append(result[y * width + x - 1])
			if y > 0:
				taken.append(result[(y - 1) * width + x])
			var choices: Array[int] = []
			for variant in count:
				if not taken.has(variant):
					choices.append(variant)
			if choices.is_empty():
				choices.append(0)
			result.append(choices[dice.randi() % choices.size()])
	return result


## A quarter turn, 0 to 3, for each cell of a board of [param width] by [param height],
## row by row: the tiles are turned as the game turns its own, which multiplies
## the looks of a few variants by four.
static func turns(width: int, height: int, seed_ := 11) -> PackedInt32Array:
	var dice := RandomNumberGenerator.new()
	dice.seed = seed_
	var result := PackedInt32Array()
	for index in width * height:
		result.append(dice.randi() % 4)
	return result


## Whether the cell ([param x], [param y]) of a board [param side] cells wide
## is seen: a round patch with a ragged edge, off the middle, as a scout's
## trip lights.
static func seen(x: int, y: int, side: int) -> bool:
	var reach := Vector2(x, y).distance_to(Vector2(side * 0.4, side * 0.6))
	return reach + 1.2 * sin(x * 1.7 + y * 0.9) < side * 0.34
