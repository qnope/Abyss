extends TestCase
## test/presentation/widgets/map/effects/strike/strike_geometry_test.dart,
## strike_approach_test.dart: the cell beside the place an army attacks from, and
## the way it swims, lunges and falls back.

const SIZE := 10


func _approach(origin: Vector2i, target: Vector2i, span := 1) -> Vector2i:
	return StrikeGeometry.approach_cell(origin, target, SIZE, SIZE, span)


func test_it_never_comes_from_behind_the_place_from_any_origin_of_the_map() -> void:
	for place: Array in [[Vector2i(5, 5), 1], [Vector2i(0, 5), 1], [Vector2i(9, 4), 1], [Vector2i(4, 4), 2], [Vector2i(0, 4), 2]]:
		var target: Vector2i = place[0]
		var span: int = place[1]
		for x in SIZE:
			for y in SIZE:
				var cell := _approach(Vector2i(x, y), target, span)
				var reason := "from (%d, %d) to %s" % [x, y, target]
				assert_false(StrikeGeometry.covers(target, span, cell), reason)
				assert_true(cell.y >= target.y, reason)
				assert_true(absi(cell.x - target.x - span / 2) <= span + 1, reason)
				assert_true(cell.x >= 0 and cell.x < SIZE and cell.y < SIZE, reason)


func test_it_comes_to_the_neighbour_nearest_the_origin_beside_or_in_front() -> void:
	assert_eq(_approach(Vector2i(0, 6), Vector2i(5, 5)), Vector2i(4, 6))
	assert_eq(_approach(Vector2i(5, 9), Vector2i(5, 5)), Vector2i(5, 6))
	assert_eq(_approach(Vector2i(9, 9), Vector2i(5, 5)), Vector2i(6, 6))
	assert_eq(_approach(Vector2i(0, 5), Vector2i(5, 5)), Vector2i(4, 5), "level with the place, on its left")
	assert_eq(_approach(Vector2i(9, 5), Vector2i(5, 5)), Vector2i(6, 5))


func test_an_origin_behind_the_place_comes_round_to_the_side() -> void:
	assert_eq(_approach(Vector2i(5, 0), Vector2i(5, 5)), Vector2i(4, 5))
	assert_eq(_approach(Vector2i(8, 0), Vector2i(5, 5)), Vector2i(6, 5))
	assert_eq(_approach(Vector2i(1, 1), Vector2i(5, 5), 2), Vector2i(4, 5))


func test_it_is_the_origin_itself_when_it_touches_the_place_there() -> void:
	assert_eq(_approach(Vector2i(6, 6), Vector2i(5, 5)), Vector2i(6, 6))


func test_from_within_the_place_it_comes_from_the_side_before_the_front() -> void:
	assert_eq(_approach(Vector2i(5, 5), Vector2i(5, 5)), Vector2i(4, 5))
	assert_eq(_approach(Vector2i(0, 3), Vector2i(0, 3)), Vector2i(1, 3), "the left one is off the map")
	assert_eq(_approach(Vector2i(6, 6), Vector2i(5, 5), 2), Vector2i(4, 5))


func test_it_keeps_inside_the_map_and_comes_from_behind_only_where_nothing_lies_beside_or_in_front() -> void:
	assert_eq(_approach(Vector2i(9, 0), Vector2i(9, 9)), Vector2i(8, 9))
	assert_eq(_approach(Vector2i(0, 0), Vector2i(9, 9)), Vector2i(8, 9))
	assert_eq(StrikeGeometry.approach_cell(Vector2i(0, 0), Vector2i(0, 0), 1, 1), Vector2i(0, 0),
		"a map of one cell has no cell beside: the origin")


func _on(origin: Vector2i, target: Vector2i, span := 1) -> StrikeGeometry:
	return StrikeGeometry.new(origin, target, SIZE, SIZE, span)


func _at(cell: Vector2i) -> Vector3:
	return MapGrid.at(cell.x, cell.y, SIZE, SIZE)


func test_the_army_swims_from_the_origin_to_the_approach_cell() -> void:
	var geometry := _on(Vector2i(0, 6), Vector2i(5, 5))
	assert_eq(geometry.approach(), Vector2i(4, 6))
	assert_eq(geometry.army_at(0.0), _at(Vector2i(0, 6)))
	assert_almost_eq(geometry.army_at(1.0).distance_to(_at(Vector2i(4, 6))), 0.0, 1e-6)
	var half := geometry.army_at(0.5)
	assert_almost_eq(half.x, _at(Vector2i(2, 6)).x, 1e-6)


func test_it_lunges_part_of_the_way_towards_the_middle_of_the_place_then_back() -> void:
	var geometry := _on(Vector2i(0, 6), Vector2i(5, 5))
	var rest := _at(Vector2i(4, 6))
	var peak := geometry.army_at(1.0, 1.0)
	assert_almost_eq(peak.distance_to(rest + (_at(Vector2i(5, 5)) - rest) * StrikeGeometry.LUNGE_REACH), 0.0, 1e-6)
	assert_true(StrikeGeometry.LUNGE_REACH > 0.0 and StrikeGeometry.LUNGE_REACH < 1.0)
	assert_almost_eq(geometry.army_at(1.0, 0.0).distance_to(rest), 0.0, 1e-6)


func test_it_retreats_a_cell_back_towards_the_origin() -> void:
	assert_almost_eq(_on(Vector2i(0, 6), Vector2i(5, 5)).army_at(1.0, 0.0, 1.0).distance_to(_at(Vector2i(3, 6))), 0.0, 1e-6)


func test_it_retreats_away_from_the_place_when_it_set_off_beside_it() -> void:
	var geometry := _on(Vector2i(4, 6), Vector2i(5, 5))
	var away := Vector3(-1.0, 0.0, 1.0).normalized()
	assert_almost_eq(geometry.army_at(0.0, 0.0, 1.0).distance_to(_at(Vector2i(4, 6)) + away * MapGrid.CELL), 0.0, 1e-6)


func test_the_lair_is_the_middle_of_the_cells_the_place_covers() -> void:
	assert_eq(_on(Vector2i(0, 0), Vector2i(2, 1)).lair(), _at(Vector2i(2, 1)))
	var volcano := _on(Vector2i(0, 0), Vector2i(2, 1), 2).lair()
	assert_almost_eq(volcano.x, (_at(Vector2i(2, 1)).x + _at(Vector2i(3, 1)).x) / 2.0, 1e-6)
	assert_almost_eq(volcano.z, (_at(Vector2i(2, 1)).z + _at(Vector2i(2, 2)).z) / 2.0, 1e-6)
