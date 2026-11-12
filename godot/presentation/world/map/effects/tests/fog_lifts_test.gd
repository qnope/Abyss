extends MapTestCase
## What the fog lifts from: the cells a level sees that it did not when it was
## last shown.

var _lifts := FogLifts.new()


func _looks(seen: Array[Vector2i], level := 1) -> Array[MapLook]:
	return MapLooks.of(level_of(5, 5, seen, false, level))


func test_the_first_time_a_level_is_shown_nothing_lifts() -> void:
	assert_eq(_lifts.newly_seen(1, _looks([Vector2i(1, 1)])), [] as Array[Vector2i])


func test_the_cells_seen_since_the_level_was_last_shown_lift() -> void:
	_lifts.newly_seen(1, _looks([Vector2i(1, 1)]))
	var seen := _lifts.newly_seen(1, _looks([Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 3)]))
	assert_eq(seen, [Vector2i(2, 1), Vector2i(0, 3)] as Array[Vector2i], "in the order of the grid")
	assert_eq(_lifts.newly_seen(1, _looks([Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 3)])), [] as Array[Vector2i])


func test_each_level_remembers_its_own_cells() -> void:
	_lifts.newly_seen(1, _looks([Vector2i(1, 1)]))
	assert_eq(_lifts.newly_seen(2, _looks([Vector2i(2, 2)], 2)), [] as Array[Vector2i])
	assert_eq(_lifts.newly_seen(1, _looks([Vector2i(1, 1), Vector2i(1, 2)])), [Vector2i(1, 2)] as Array[Vector2i])


func test_another_game_lifts_nothing() -> void:
	_lifts.newly_seen(1, _looks([Vector2i(1, 1), Vector2i(1, 2)]))
	assert_eq(_lifts.newly_seen(1, _looks([Vector2i(3, 3), Vector2i(4, 4)])), [] as Array[Vector2i],
		"the cells of the game before are not among the ones seen now")


func test_forgetting_the_levels_lifts_nothing_the_next_time() -> void:
	_lifts.newly_seen(1, _looks([Vector2i(1, 1)]))
	_lifts.forget()
	assert_eq(_lifts.newly_seen(1, _looks([Vector2i(1, 1), Vector2i(2, 2)])), [] as Array[Vector2i])


func test_the_hidden_cells_are_the_ones_not_seen() -> void:
	var hidden := FogLifts.hidden(_looks([Vector2i(1, 1)]))
	assert_eq(hidden.size(), 24)
	assert_false(hidden.has(Vector2i(1, 1)))
