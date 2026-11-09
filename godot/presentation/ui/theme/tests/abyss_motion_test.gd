extends TestCase
## The durations and curves of abyss_motion.dart, in seconds and tweens.


func test_keeps_the_flutter_durations_in_seconds() -> void:
	assert_eq(AbyssMotion.TAP, 0.15)
	assert_eq(AbyssMotion.QUICK, 0.25)
	assert_eq(AbyssMotion.EMPHASIS, 0.4)
	assert_eq(AbyssMotion.RECRUIT_ARRIVAL, 0.9)
	assert_eq(AbyssMotion.DELTA_FLOAT, 1.2)
	assert_eq(AbyssMotion.SWIM, 0.9)
	assert_eq(AbyssMotion.EVENT_STEP, 0.3)
	assert_eq(AbyssMotion.FADE, 0.6)
	assert_eq(AbyssMotion.STORY_PAUSE, 0.4)


func test_every_ambient_cycle_divides_the_loop() -> void:
	assert_eq(AbyssMotion.AMBIENT_CYCLES, [4.0, 5.0, 6.0, 3.0, 3.0, 2.0])
	assert_eq(AbyssMotion.AMBIENT_LOOP, 60.0)
	for cycle in AbyssMotion.AMBIENT_CYCLES:
		assert_eq(fmod(AbyssMotion.AMBIENT_LOOP, cycle), 0.0, str(cycle))
	assert_eq(AbyssMotion.AMBIENT_FRAME, 0.033334)


func test_a_swim_lasts_with_the_root_of_its_cells_up_to_three_swims() -> void:
	assert_almost_eq(AbyssMotion.swim_over(0.5), 0.9, 1e-9)
	assert_almost_eq(AbyssMotion.swim_over(4.0), 1.8, 1e-9)
	assert_almost_eq(AbyssMotion.swim_over(16.0), 2.7, 1e-9)


func test_is_instant_when_the_player_asked_for_fewer_animations() -> void:
	assert_eq(AbyssMotion.or_instant(0.4, true), 0.0)
	assert_eq(AbyssMotion.or_instant(0.4, false), 0.4)


func test_maps_the_curves_to_tween_transitions() -> void:
	assert_eq(AbyssMotion.ENTER_TRANS, Tween.TRANS_CUBIC)
	assert_eq(AbyssMotion.ENTER_EASE, Tween.EASE_OUT)
	assert_eq(AbyssMotion.EXIT_TRANS, Tween.TRANS_CUBIC)
	assert_eq(AbyssMotion.EXIT_EASE, Tween.EASE_IN)
	assert_eq(AbyssMotion.TRAVEL_TRANS, Tween.TRANS_CUBIC)
	assert_eq(AbyssMotion.TRAVEL_EASE, Tween.EASE_IN_OUT)
	assert_eq(AbyssMotion.POP_TRANS, Tween.TRANS_BACK)
	assert_eq(AbyssMotion.POP_EASE, Tween.EASE_OUT)

