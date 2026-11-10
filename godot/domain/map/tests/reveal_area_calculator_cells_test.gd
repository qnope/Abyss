extends TestCase
## test/domain/map/reveal_area_calculator_cells_test.dart: the cells a scout
## reveals around its target.


func test_odd_squares_side_3_at_5_5_reveals_9_cells_range_4_4_to_6_6() -> void:
	_assert_square(5, 5, 3, 9, 4, 6)


func test_odd_squares_side_5_at_10_10_reveals_25_cells_range_8_8_to_12_12() -> void:
	_assert_square(10, 10, 5, 25, 8, 12)


func test_odd_squares_side_7_at_10_10_reveals_49_cells_range_7_7_to_13_13() -> void:
	_assert_square(10, 10, 7, 49, 7, 13)


func test_odd_squares_side_9_at_10_10_reveals_81_cells_range_6_6_to_14_14() -> void:
	_assert_square(10, 10, 9, 81, 6, 14)


## Dart generates one test per side.
func test_strict_centering_each_side_is_strictly_centered_on_target() -> void:
	for side: int in [3, 5, 7, 9]:
		var positions := _reveal(10, 10, side)
		var around := {"left": 0, "right": 0, "above": 0, "below": 0}
		for p: Vector2i in positions:
			around["left"] += int(p.x < 10)
			around["right"] += int(p.x > 10)
			around["above"] += int(p.y < 10)
			around["below"] += int(p.y > 10)
		assert_eq(around["left"], around["right"], "left/right must match around target")
		assert_eq(around["above"], around["below"], "above/below must match around target")


func test_boundary_handling_corner_0_0_side_3_reveals_4_cells() -> void:
	var positions := _reveal(0, 0, 3)
	assert_eq(positions.size(), 4)
	for cell: Vector2i in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]:
		assert_has(positions, cell)


func test_boundary_handling_right_edge_19_10_side_3_reveals_6_cells() -> void:
	var positions := _reveal(19, 10, 3)
	assert_eq(positions.size(), 6)
	for x: int in range(18, 20):
		for y: int in range(9, 12):
			assert_has(positions, Vector2i(x, y))
	assert_has(positions, Vector2i(19, 10))


func test_boundary_handling_far_corner_19_19_side_3_reveals_4_cells() -> void:
	var positions := _reveal(19, 19, 3)
	assert_eq(positions.size(), 4)
	for cell: Vector2i in [Vector2i(18, 18), Vector2i(19, 18), Vector2i(18, 19), Vector2i(19, 19)]:
		assert_has(positions, cell)


## Dart generates one test per side.
func test_total_cell_count_on_open_map_each_side_reveals_its_square() -> void:
	var expected := {3: 9, 5: 25, 7: 49, 9: 81, 11: 121}
	for side: int in expected:
		var positions := _reveal(10, 10, side)
		assert_eq(positions.size(), expected[side], "side %d" % side)
		assert_has(positions, Vector2i(10, 10))


## The keys of the cells revealed on a map of 20.
func _reveal(tx: int, ty: int, side: int) -> Array[Vector2i]:
	return GridPosition.keys(RevealAreaCalculator.cells_to_reveal(tx, ty, side, 20, 20))


func _assert_square(tx: int, ty: int, side: int, count: int, from: int, to: int) -> void:
	var positions := _reveal(tx, ty, side)
	assert_eq(positions.size(), count)
	for x: int in range(from, to + 1):
		for y: int in range(from, to + 1):
			assert_has(positions, Vector2i(x, y))
	assert_has(positions, Vector2i(tx, ty))
