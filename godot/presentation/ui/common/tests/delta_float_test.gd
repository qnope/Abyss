extends UiTestCase
## The figure floating up from a value that changed (delta_float_test.dart).

var _anchor: Control
var _float: DeltaFloat


func before_each() -> void:
	_anchor = Control.new()
	_anchor.position = Vector2(100.0, 50.0)
	_anchor.size = Vector2(60.0, 20.0)
	mount(_anchor)
	_float = DeltaFloat.new()
	_anchor.add_child(_float)


func test_is_hidden_and_takes_no_touch_until_something_changes() -> void:
	assert_false(_float.visible)
	assert_false(_float.is_floating())
	assert_eq(_float.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_true(_float.top_level, "above whatever clips or lays out its parent")


func test_a_gain_floats_up_in_the_gain_colour() -> void:
	_float.float_from(_anchor, 30)
	assert_eq(_float.text, "+30")
	assert_eq(_float.get_theme_color(&"font_color"), AbyssColors.SUCCESS)
	assert_true(_float.visible)
	assert_true(_float.is_floating())


func test_a_loss_floats_up_in_the_loss_colour_with_a_true_minus() -> void:
	_float.float_from(_anchor, -12)
	assert_eq(_float.text, "−12")
	assert_eq(_float.get_theme_color(&"font_color"), AbyssColors.ERROR)


func test_the_colours_are_the_owners_to_choose() -> void:
	var own := DeltaFloat.new(Color.WHITE, Color.BLACK)
	_anchor.add_child(own)
	own.float_from(_anchor, 1)
	assert_eq(own.get_theme_color(&"font_color"), Color.WHITE)
	own.float_from(_anchor, -1)
	assert_eq(own.get_theme_color(&"font_color"), Color.BLACK)


func test_starts_at_the_top_centre_of_the_anchor_and_rises_while_it_fades() -> void:
	_float.float_from(_anchor, 5)
	var start := _float.position
	assert_almost_eq(start.y, 50.0, 1e-3)
	assert_almost_eq(start.x + _float.size.x / 2.0, 130.0, 1e-3)
	assert_eq(_float.modulate.a, 1.0)
	_float.tween.custom_step(AbyssMotion.DELTA_FLOAT / 2.0)
	assert_true(_float.position.y < start.y)
	assert_true(_float.modulate.a < 1.0)
	assert_eq(_float.position.x, start.x)


func test_is_gone_when_it_is_done() -> void:
	_float.float_from(_anchor, 5)
	_float.tween.custom_step(AbyssMotion.DELTA_FLOAT + 0.1)
	assert_false(_float.visible)
	assert_false(_float.is_floating())


func test_a_new_change_replaces_the_float_under_way() -> void:
	_float.float_from(_anchor, 5)
	var first := _float.tween
	_float.float_from(_anchor, -2)
	assert_false(first.is_valid())
	assert_eq(_float.text, "−2")
	assert_true(_float.is_floating())


func test_no_change_floats_nothing_and_ends_the_float_under_way() -> void:
	_float.float_from(_anchor, 5)
	_float.float_from(_anchor, 0)
	assert_false(_float.visible)
	assert_false(_float.is_floating())


func test_with_fewer_animations_nothing_floats() -> void:
	_float.reduced_motion = true
	_float.float_from(_anchor, 5)
	assert_false(_float.visible)
	assert_false(_float.is_floating())


func test_outside_the_tree_nothing_floats() -> void:
	var loose := DeltaFloat.new()
	loose.float_from(_anchor, 5)
	assert_false(loose.is_floating())
	loose.free()


func test_leaving_the_tree_ends_the_float() -> void:
	_float.float_from(_anchor, 5)
	_anchor.remove_child(_float)
	assert_false(_float.is_floating())
	_float.free()


func test_its_curves_lift_fast_then_settle_and_fade_slowly_then_fast() -> void:
	assert_eq(DeltaFloat.lift_at(0.0), 0.0)
	assert_eq(DeltaFloat.lift_at(1.0), 1.0)
	assert_true(DeltaFloat.lift_at(0.5) > 0.5)
	assert_eq(DeltaFloat.fade_at(0.0), 1.0)
	assert_almost_eq(DeltaFloat.fade_at(1.0), 0.0, 1e-6)
	assert_true(DeltaFloat.fade_at(0.5) > 0.5)


func test_writes_a_gain_with_a_plus_and_a_loss_with_a_minus() -> void:
	assert_eq(DeltaFloat.label_of(7), "+7")
	assert_eq(DeltaFloat.label_of(0), "+0")
	assert_eq(DeltaFloat.label_of(-7), "−7")
