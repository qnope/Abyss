extends TestCase
## test/domain/map/cell_eligibility_checker_test.dart: the cells a scout can
## be sent to. Its 'boundary conditions' (a corner, an edge "does not
## crash") are one test, which a script error would fail.

var _map: GameMap
var _player: Player


## A 7x7 map with the base at (3, 3), the 3x3 square around it revealed.
func before_each() -> void:
	_map = MapSamples.plain_map(7, 7, 0)
	var revealed: Array[GridPosition] = []
	for dy: int in range(-1, 2):
		for dx: int in range(-1, 2):
			revealed.append(GridPosition.new(3 + dx, 3 + dy))
	_player = Player.new("Test", null, 3, 3, null, null, null, null, [], [], {1: revealed})


func _eligible(x: int, y: int, level := 1) -> bool:
	return CellEligibilityChecker.is_eligible(_map, _player, x, y, level)


func test_revealed_cells_revealed_cell_is_eligible() -> void:
	assert_true(_eligible(2, 2))


func test_revealed_cells_revealed_cell_at_map_edge_is_eligible() -> void:
	_player.add_revealed_cell(1, GridPosition.new(0, 3))
	assert_true(_eligible(0, 3))


func test_base_cell_base_cell_is_not_eligible() -> void:
	assert_false(_eligible(3, 3))


func test_unrevealed_cells_adjacent_to_revealed_unrevealed_cell_adjacent_to_revealed_is_eligible() -> void:
	assert_false(_player.revealed_cells().has(Vector2i(1, 2)))
	assert_true(_player.revealed_cells().has(Vector2i(2, 2)))
	assert_true(_eligible(1, 2))


func test_unrevealed_cells_adjacent_to_revealed_unrevealed_cell_diagonally_adjacent_is_eligible() -> void:
	assert_false(_player.revealed_cells().has(Vector2i(1, 1)))
	assert_true(_player.revealed_cells().has(Vector2i(2, 2)))
	assert_true(_eligible(1, 1))


func test_unrevealed_cells_not_adjacent_to_revealed_unrevealed_cell_far_from_revealed_is_not_eligible() -> void:
	assert_false(_player.revealed_cells().has(Vector2i(0, 0)))
	assert_false(_eligible(0, 0))


func test_boundary_conditions_corner_and_edge_cells_do_not_crash() -> void:
	assert_false(_eligible(0, 0))
	assert_false(_eligible(0, 3))


func test_level_2_behavior_base_cell_is_eligible_on_level_2() -> void:
	_player.add_revealed_cell(2, GridPosition.new(3, 3))
	assert_true(_eligible(3, 3, 2))


func test_level_2_behavior_uses_level_2_revealed_cells() -> void:
	_player.add_revealed_cell(2, GridPosition.new(6, 6))
	assert_true(_eligible(6, 6, 2))
	assert_false(_eligible(2, 2, 2))


func test_level_2_behavior_unrevealed_cell_adjacent_to_level_2_revealed_is_eligible() -> void:
	_player.add_revealed_cell(2, GridPosition.new(5, 5))
	assert_true(_eligible(5, 6, 2))


## Not in the Dart file: the cells gathered once serve many tests.
func test_is_eligible_among_reads_the_cells_given() -> void:
	var revealed: Dictionary[Vector2i, bool] = {Vector2i(6, 0): true}
	assert_true(CellEligibilityChecker.is_eligible_among(_map, _player, revealed, 5, 1))
	assert_false(CellEligibilityChecker.is_eligible_among(_map, _player, revealed, 2, 2))
