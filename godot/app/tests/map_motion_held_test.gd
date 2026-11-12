extends TestCase
## The time of the map's effects (the world's `MapMotion`) is the interface's
## (`AbyssMotion`): the world reads none of the interface, so `app/` holds the
## two together.


func test_the_steps_are_the_interfaces() -> void:
	assert_eq(MapMotion.TAP, AbyssMotion.TAP)
	assert_eq(MapMotion.QUICK, AbyssMotion.QUICK)
	assert_eq(MapMotion.SWIM, AbyssMotion.SWIM)
	assert_eq(MapMotion.EVENT_STEP, AbyssMotion.EVENT_STEP)
	assert_eq(MapMotion.FADE, AbyssMotion.FADE)
	assert_eq(MapMotion.STORY_PAUSE, AbyssMotion.STORY_PAUSE)


func test_a_swim_lasts_longer_over_a_farther_cell_up_to_three_swims() -> void:
	for cells: float in [0.0, 1.0, 2.0, 5.0, 100.0]:
		assert_eq(MapMotion.swim_over(cells), AbyssMotion.swim_over(cells))
	assert_eq(MapMotion.swim_over(100.0), MapMotion.SWIM * 3.0)


