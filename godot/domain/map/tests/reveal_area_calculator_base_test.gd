extends TestCase
## test/domain/map/reveal_area_calculator_base_test.dart: the square a base
## reveals when a game starts. Left out: 'what a player standing on its
## base starts with', which waits for `game` (`Player.withBase`).


func test_around_base_a_square_of_base_side_cells_centred_on_the_base() -> void:
	var cells := GridPosition.keys(RevealAreaCalculator.around_base(10, 10, 20, 20))
	var half := DartMath.trunc_div(RevealAreaCalculator.BASE_SIDE, 2)
	assert_eq(cells.size(), 25)
	assert_has(cells, Vector2i(10 - half, 10 - half))
	assert_has(cells, Vector2i(10 + half, 10 + half))


func test_around_base_clipped_by_the_edges_of_the_map() -> void:
	var cells := RevealAreaCalculator.around_base(0, 0, 20, 20)
	assert_eq(cells.size(), 9)
