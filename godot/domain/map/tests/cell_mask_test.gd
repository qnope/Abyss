extends TestCase
## test/domain/map/cell_mask_test.dart: which cells of a grid are marked.

var _mask := CellMask.new(4, 3, [GridPosition.new(1, 1), GridPosition.new(3, 2)])


func test_cell_mask_contains_the_marked_cells_only() -> void:
	assert_eq(_mask.width, 4)
	assert_eq(_mask.height, 3)
	assert_true(_mask.contains(1, 1))
	assert_true(_mask.contains(3, 2))
	assert_false(_mask.contains(0, 0))
	assert_false(_mask.contains(2, 1))


func test_cell_mask_never_contains_a_cell_off_the_grid() -> void:
	assert_false(_mask.contains(-1, 1))
	assert_false(_mask.contains(4, 1))
	assert_false(_mask.contains(1, -1))
	assert_false(_mask.contains(1, 3))


func test_cell_mask_touches_covers_a_marked_cell_and_its_eight_neighbours() -> void:
	assert_true(_mask.touches(1, 1))
	assert_true(_mask.touches(0, 0))
	assert_true(_mask.touches(2, 2))
	assert_true(_mask.touches(3, 1))
	assert_false(_mask.touches(3, 0))


func test_cell_mask_touches_looks_past_the_edges_without_failing() -> void:
	assert_true(_mask.touches(0, 2))
	assert_false(_mask.touches(3, 0))
	assert_false(_mask.touches(-1, -1))
	assert_true(_mask.touches(4, 3))


func test_cell_mask_ignores_marks_off_the_grid() -> void:
	var small := CellMask.new(2, 2, [GridPosition.new(5, 5)])
	assert_false(small.contains(1, 1))
	assert_false(small.touches(1, 1))
