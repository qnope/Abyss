extends UiTestCase
## A picture that rises when its value goes up (increase_pop_test.dart).

const BOX := Vector2(40.0, 40.0)

var _picture: Control
var _pop: IncreasePop


func before_each() -> void:
	_picture = Control.new()
	_pop = IncreasePop.new(_picture, BOX, AbyssColors.BIOLUM_CYAN, 3)
	mount(_pop)
	_pop.size = BOX


func test_holds_its_picture_in_a_box_and_takes_no_touch() -> void:
	assert_eq(_pop.custom_minimum_size, BOX)
	assert_eq(_pop.picture, _picture)
	assert_eq(_picture.get_parent(), _pop)
	assert_eq(_picture.size, BOX, "it fills the box")
	assert_eq(_pop.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_false(_pop.is_rising())


func test_nothing_moves_when_first_shown() -> void:
	assert_eq(_picture.scale, Vector2.ONE)
	assert_eq(_picture.position.y, 0.0)
	assert_eq(_pop.value, 3)


func test_a_value_that_rises_pops_the_picture() -> void:
	_pop.set_value(4)
	assert_true(_pop.is_rising())
	assert_eq(_pop.value, 4)
	assert_almost_eq(_picture.scale.x, IncreasePop.START_SCALE, 1e-5)
	assert_almost_eq(_picture.position.y, BOX.y * IncreasePop.START_DROP, 1e-4)
	assert_eq(_picture.pivot_offset, Vector2(BOX.x / 2.0, BOX.y), "it rises from its foot")


func test_it_settles_back_at_rest() -> void:
	_pop.set_value(4)
	_pop.tween.custom_step(AbyssMotion.EMPHASIS + 0.1)
	assert_false(_pop.is_rising())
	assert_almost_eq(_picture.scale.x, 1.0, 1e-5)
	assert_almost_eq(_picture.position.y, 0.0, 1e-5)


func test_it_passes_its_size_on_the_way() -> void:
	_pop.set_value(4)
	var biggest := 0.0
	for step in 8:
		_pop.tween.custom_step(AbyssMotion.EMPHASIS / 8.0)
		biggest = maxf(biggest, _picture.scale.x)
	assert_true(biggest > 1.0, "the pop overshoots")


func test_a_value_that_stays_or_falls_moves_nothing() -> void:
	_pop.set_value(3)
	assert_false(_pop.is_rising())
	_pop.set_value(1)
	assert_false(_pop.is_rising())
	assert_eq(_pop.value, 1)
	_pop.set_value(2)
	assert_true(_pop.is_rising(), "up from the last value seen")


func test_the_picture_follows_the_box_as_it_is_resized_mid_rise() -> void:
	_pop.set_value(4)
	_pop.size = BOX * 2.0
	assert_eq(_picture.size, BOX * 2.0)
	assert_almost_eq(_picture.position.y, BOX.y * 2.0 * IncreasePop.START_DROP, 1e-4)


func test_a_second_rise_restarts_the_first() -> void:
	_pop.set_value(4)
	var first := _pop.tween
	_pop.set_value(5)
	assert_false(first.is_valid())
	assert_true(_pop.is_rising())


func test_with_fewer_animations_the_final_state_shows_at_once() -> void:
	_pop.reduced_motion = true
	_pop.set_value(4)
	assert_false(_pop.is_rising())
	assert_eq(_picture.scale, Vector2.ONE)
	assert_eq(_pop.value, 4)


func test_outside_the_tree_it_just_changes() -> void:
	var loose := IncreasePop.new(Control.new(), BOX, Color.RED)
	loose.set_value(2)
	assert_false(loose.is_rising())
	assert_eq(loose.value, 2)
	loose.free()


func test_leaving_the_tree_ends_the_rise() -> void:
	_pop.set_value(4)
	host().remove_child(_pop)
	assert_false(_pop.is_rising())
	_pop.free()


func test_the_glow_drifts_up_and_fades_while_the_picture_rises() -> void:
	assert_eq(IncreasePop.glow_at(0.0), IncreasePop.START_GLOW)
	assert_eq(IncreasePop.glow_at(1.0), 0.0)
	assert_true(IncreasePop.glow_at(0.5) < IncreasePop.START_GLOW)
	assert_eq(IncreasePop.glow_at(2.0), 0.0, "past the end it is gone")
	assert_almost_eq(IncreasePop.scale_at(0.0), IncreasePop.START_SCALE, 1e-5)
	assert_almost_eq(IncreasePop.scale_at(1.0), 1.0, 1e-5)
	assert_almost_eq(IncreasePop.drop_at(0.0), IncreasePop.START_DROP, 1e-5)
	assert_almost_eq(IncreasePop.drop_at(1.0), 0.0, 1e-5)


func test_the_glow_is_two_discs_that_climb_and_fade_and_are_gone_at_rest() -> void:
	assert_false(_pop._halo.visible, "nothing shows at rest")
	assert_false(_pop._core.visible)
	_pop._rise(0.0)
	assert_true(_pop._halo.visible and _pop._core.visible)
	assert_eq(_pop._core.size, BOX / 2.0)
	assert_eq(_pop._halo.size, BOX)
	assert_almost_eq(_pop._core.modulate.a, IncreasePop.START_GLOW, 1e-5)
	assert_almost_eq(_pop._halo.modulate.a, IncreasePop.START_GLOW * IncreasePop.HALO_SHARE, 1e-5)
	var low := _pop._core.position.y
	_pop._rise(0.5)
	assert_true(_pop._core.position.y < low, "it drifts up")
	assert_true(_pop._core.modulate.a < IncreasePop.START_GLOW)
	assert_eq(_pop._core.mouse_filter, Control.MOUSE_FILTER_IGNORE)
