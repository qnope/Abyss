extends TestCase
## The time of the map's effects, eased.


func test_a_share_runs_from_zero_to_one_over_its_step() -> void:
	assert_eq(MapMotion.share(0.5, 1.0, 2.0), 0.0)
	assert_eq(MapMotion.share(2.0, 1.0, 2.0), 0.5)
	assert_eq(MapMotion.share(9.0, 1.0, 2.0), 1.0)


func test_a_step_with_no_length_is_done_as_it_starts() -> void:
	assert_eq(MapMotion.share(0.9, 1.0, 0.0), 0.0)
	assert_eq(MapMotion.share(1.0, 1.0, 0.0), 1.0)


func test_the_curves_start_at_zero_end_at_one_and_lean_as_named() -> void:
	for curve: Callable in [MapMotion.enter, MapMotion.exit, MapMotion.travel]:
		assert_eq(curve.call(0.0), 0.0)
		assert_eq(curve.call(1.0), 1.0)
		assert_eq(curve.call(7.0), 1.0, "past its end it stays there")
		assert_eq(curve.call(-1.0), 0.0)
	assert_true(MapMotion.enter(0.25) > 0.25, "arriving is fast first")
	assert_true(MapMotion.exit(0.25) < 0.25, "leaving is slow first")
	assert_almost_eq(MapMotion.travel(0.5), 0.5, 1e-6)


func test_a_swim_over_a_far_cell_never_lasts_more_than_three_swims() -> void:
	assert_eq(MapMotion.swim_over(0.0), MapMotion.SWIM)
	assert_eq(MapMotion.swim_over(100.0), MapMotion.SWIM * 3.0)
	assert_true(MapMotion.swim_over(4.0) > MapMotion.swim_over(1.0))
