extends TestCase
## The cells in space, and what a ray picks: pure maths, as the base's and the
## parade ground's picking.

const SIDE := 6


func test_the_map_is_centred_with_its_first_row_at_the_back() -> void:
	assert_eq(MapGrid.at(0, 0, SIDE, SIDE), Vector3(-2.5, 0.0, -2.5))
	assert_eq(MapGrid.at(5, 5, SIDE, SIDE), Vector3(2.5, 0.0, 2.5))
	assert_eq(MapGrid.at(2, 0, 3, 1), Vector3(1.0, 0.0, 0.0))


func test_a_point_is_in_the_cell_under_it_or_off_the_map() -> void:
	for y in SIDE:
		for x in SIDE:
			assert_eq(MapGrid.cell_at(MapGrid.at(x, y, SIDE, SIDE) + Vector3(0.4, 2.0, -0.4), SIDE, SIDE),
				Vector2i(x, y))
	for off: Vector3 in [Vector3(-3.1, 0, 0), Vector3(3.1, 0, 0), Vector3(0, 0, -3.1), Vector3(0, 0, 3.1)]:
		assert_null(MapGrid.cell_at(off, SIDE, SIDE), str(off))


func test_the_outline_holds_the_corners_down_to_the_tiles_and_up_to_the_tallest() -> void:
	var points := MapGrid.outline(SIDE, 4)
	assert_eq(points.size(), 8)
	assert_true(points.has(Vector3(-3.0, MapGrid.TALLEST, 2.0)))
	assert_true(points.has(Vector3(3.0, -MapGrid.DEPTH, -2.0)))


func test_a_ray_picks_the_cell_it_meets() -> void:
	var from := Vector3(1.2, 10.0, 0.4)
	assert_eq(MapPick.cell(from, Vector3.DOWN, SIDE, SIDE), Vector2i(4, 3))
	var tilted := (MapGrid.at(4, 1, SIDE, SIDE) + Vector3(0.0, MapPick.HEIGHT, 0.0) - Vector3(0.0, 8.0, 6.0))
	assert_eq(MapPick.cell(Vector3(0.0, 8.0, 6.0), tilted.normalized(), SIDE, SIDE), Vector2i(4, 1))


func test_a_ray_beside_the_map_or_pointing_up_picks_nothing() -> void:
	assert_null(MapPick.cell(Vector3(9.0, 10.0, 0.0), Vector3.DOWN, SIDE, SIDE))
	assert_null(MapPick.cell(Vector3(0.0, 10.0, 0.0), Vector3.UP, SIDE, SIDE))
	assert_null(MapPick.cell(Vector3(0.0, 10.0, 0.0), Vector3.RIGHT, SIDE, SIDE))
