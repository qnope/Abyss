extends MapTestCase
## A scout's token: its swim lasts as long as Flutter's (longer over a farther
## cell), it shrinks onto its cell as it arrives, and leaves with the fog.

const FROM := Vector3(0.5, 0.0, 0.5)


func _token(to: Vector3, swims := true) -> ScoutToken:
	var token := ScoutToken.new(FROM, to, swims)
	add_cleanup(token.free)
	return token


func test_the_swim_lasts_longer_over_a_farther_cell() -> void:
	var near := _token(FROM + Vector3(1.0, 0.0, 0.0))
	var far := _token(FROM + Vector3(4.0, 0.0, 3.0))
	assert_eq(near.swim, MapMotion.SWIM)
	assert_eq(far.swim, MapMotion.swim_over(5.0))
	assert_true(far.swim > near.swim)


func test_it_shrinks_onto_its_cell_as_it_arrives() -> void:
	var token := _token(FROM + Vector3(2.0, 0.0, 0.0))
	assert_eq(token.scale, Vector3.ONE)
	token.advance(token.swim)
	assert_almost_eq(token.scale.x, ScoutToken.REST_SCALE, 1e-6)
	assert_false(token.is_swimming())
	assert_almost_eq(_token(FROM, false).scale.x, ScoutToken.REST_SCALE, 1e-6, "one that waits is small")


func test_it_rises_and_shrinks_away_as_it_leaves() -> void:
	var token := _token(FROM, false)
	var waiting := token.position
	token.leave(0.5)
	assert_true(token.position.y > waiting.y)
	assert_true(token.scale.x < ScoutToken.REST_SCALE)
	token.leave(7.0)
	assert_eq(token.gone, 1.0)
	assert_true(token.scale.x > 0.0, "never nothing at all")
	assert_almost_eq(token.position.y, waiting.y + ScoutToken.LEAVE_RISE, 1e-6)
	token.leave(0.0)
	assert_eq(token.position, waiting)
