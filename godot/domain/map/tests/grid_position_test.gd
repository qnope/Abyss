extends TestCase
## test/domain/map/grid_position_test.dart: a cell of a map, by its column
## and its row.


func test_grid_position_construction_with_x_and_y() -> void:
	var pos := GridPosition.new(3, 7)
	assert_eq(pos.x, 3)
	assert_eq(pos.y, 7)


func test_grid_position_value_equality_for_same_coordinates() -> void:
	var a := GridPosition.new(5, 10)
	var b := GridPosition.new(5, 10)
	assert_true(a.equals(b))
	assert_true(a.equals(a))


func test_grid_position_inequality_for_different_coordinates() -> void:
	var a := GridPosition.new(1, 2)
	var b := GridPosition.new(2, 1)
	assert_false(a.equals(b))
	assert_false(a.equals(GridPosition.new(1, 3)))
	assert_false(a.equals(Vector2i(1, 2)))
	assert_false(a.equals(null))


## Dart's `hashCode` makes equal positions one key of a map and one member of
## a set: here `key()` does.
func test_grid_position_hash_code_is_consistent_for_equal_positions() -> void:
	var a := GridPosition.new(4, 4)
	var b := GridPosition.new(4, 4)
	assert_eq(a.key(), b.key())
	var seen: Dictionary[Vector2i, bool] = {a.key(): true}
	assert_true(seen.has(b.key()))
	assert_false(seen.has(GridPosition.new(4, 5).key()))


func test_grid_position_to_string_shows_coordinates() -> void:
	var pos := GridPosition.new(1, 2)
	assert_eq(str(pos), "GridPosition(1, 2)")


## Not in the Dart file: a key read back as its position, and the keys of a
## list, in its order.
func test_a_position_is_read_back_from_its_key() -> void:
	var pos := GridPosition.of_key(Vector2i(6, 9))
	assert_eq([pos.x, pos.y], [6, 9])
	assert_true(pos.equals(GridPosition.of_key(pos.key())))
	var positions: Array[GridPosition] = [GridPosition.new(3, 1), GridPosition.new(0, 2)]
	assert_eq(GridPosition.keys(positions), [Vector2i(3, 1), Vector2i(0, 2)])
	assert_eq(GridPosition.keys([]), [])
