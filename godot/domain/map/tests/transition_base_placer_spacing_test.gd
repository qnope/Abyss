extends TestCase
## test/domain/map/transition_base_placer_spacing_test.dart: where the posts
## stand, away from the centre and from each other.

const WIDTH := 20
const HEIGHT := 20
const CENTER := 10


func test_level_1_faille_quadrants_each_quadrant_has_exactly_1_faille() -> void:
	for seed_of_map: int in 20:
		var quadrants: Array[int] = [0, 0, 0, 0]
		for cell: Vector2i in _positions(1, seed_of_map):
			quadrants[(0 if cell.x < CENTER else 1) + (0 if cell.y < CENTER else 2)] += 1
		assert_eq(quadrants, [1, 1, 1, 1], "seed=%d" % seed_of_map)


func test_level_1_faille_distances_all_failles_at_chebyshev_distance_8_from_center() -> void:
	_assert_away_from_the_centre(1, 8)


func test_level_1_faille_distances_minimum_spacing_of_5_between_failles() -> void:
	_assert_spaced(1, 0, 20)


func test_level_2_cheminee_distances_all_cheminees_at_chebyshev_distance_10_from_center() -> void:
	_assert_away_from_the_centre(2, 10)


func test_level_2_cheminee_distances_minimum_spacing_of_5_between_cheminees() -> void:
	_assert_spaced(2, 0, 20)


## Not in the Dart file: a larger map holds more posts, the extra Failles
## going round the quarters again and the Cheminées staying on the edges.
func test_a_larger_map_holds_more_posts_spaced_as_well() -> void:
	for seed_of_map: int in 10:
		var failles := _positions(1, seed_of_map, 26, 2)
		assert_eq(failles.size(), 6)
		var per_quadrant: Array[int] = [0, 0, 0, 0]
		for cell: Vector2i in failles:
			per_quadrant[(0 if cell.x < 13 else 1) + (0 if cell.y < 13 else 2)] += 1
		assert_eq(per_quadrant, [2, 2, 1, 1], "seed=%d" % seed_of_map)
		var cheminees := _positions(2, seed_of_map, 26, 2)
		assert_eq(cheminees.size(), 5)
		for cell: Vector2i in cheminees:
			assert_true(cell.x == 0 or cell.y == 0 or cell.x == 25 or cell.y == 25, str(cell))
	_assert_spaced(1, 2, 10, 26)
	_assert_spaced(2, 2, 10, 26)


## Not in the Dart file: a map of 20 has 39 cells for its Cheminées, its top
## row and its left column. Too many of them stand closer than 5 cells, the
## spacing asked going down until a cell fits.
func test_posts_too_many_for_the_spacing_stand_closer() -> void:
	var cells := _positions(2, 3, 20, 9)
	assert_true(cells.size() > 8 and cells.size() <= 12, str(cells.size()))
	var closest := 20
	for i: int in cells.size():
		assert_true(cells[i].x == 0 or cells[i].y == 0, str(cells[i]))
		for j: int in i:
			var apart := MapSamples.chebyshev(cells[i].x, cells[i].y, cells[j].x, cells[j].y)
			closest = mini(closest, apart)
	assert_true(closest < 5, "closest posts %d cells apart" % closest)


## The cells of the posts placed, in the order of the grid.
func _positions(level: int, seed_of_map: int, size := WIDTH, extra := 0) -> Array[Vector2i]:
	var cells := MapSamples.plain_cells(size * size)
	var centre := DartMath.trunc_div(size, 2)
	TransitionBasePlacer.place(
		cells, size, size, centre, centre, level, DartRandom.new(seed_of_map), {}, extra
	)
	var positions: Array[Vector2i] = []
	for i: int in MapSamples.transition_base_indices(cells):
		positions.append(Vector2i(i % size, DartMath.trunc_div(i, size)))
	return positions


func _assert_away_from_the_centre(level: int, least: int) -> void:
	for seed_of_map: int in 20:
		for cell: Vector2i in _positions(level, seed_of_map):
			var apart := MapSamples.chebyshev(cell.x, cell.y, CENTER, CENTER)
			assert_true(apart >= least, "seed=%d post at %s" % [seed_of_map, cell])


func _assert_spaced(level: int, extra: int, seeds: int, size := WIDTH) -> void:
	for seed_of_map: int in seeds:
		var cells := _positions(level, seed_of_map, size, extra)
		for i: int in cells.size():
			for j: int in range(i + 1, cells.size()):
				var apart := MapSamples.chebyshev(cells[i].x, cells[i].y, cells[j].x, cells[j].y)
				assert_true(apart >= 5, "seed=%d %s-%s" % [seed_of_map, cells[i], cells[j]])
