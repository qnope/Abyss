extends UiTestCase
## The amount of a resource: it flashes green when it grows and red when it
## falls, and pops, then settles back to its own colour
## (animated_resource_amount.dart).

const Base := AbyssColors.ALGAE_GREEN


func test_shows_its_amount_in_the_colour_of_its_resource() -> void:
	var amount := _amount(120)
	assert_eq(amount.text, "120")
	assert_eq(amount.get_theme_color(&"font_color"), Base)
	assert_eq(amount.scale, Vector2.ONE)
	assert_false(amount.is_flashing())


func test_flashes_green_and_pops_when_it_grows() -> void:
	var amount := _amount(100)
	amount.set_amount(130)
	assert_eq(amount.text, "130")
	assert_eq(amount.get_theme_color(&"font_color"), AbyssColors.SUCCESS)
	assert_eq(amount.scale, Vector2.ONE * AnimatedAmount.POP)
	assert_true(amount.is_flashing())


func test_flashes_red_when_it_falls() -> void:
	var amount := _amount(100)
	amount.set_amount(40)
	assert_eq(amount.get_theme_color(&"font_color"), AbyssColors.ERROR)


func test_settles_back_to_its_colour_and_size() -> void:
	var amount := _amount(100)
	amount.set_amount(130)
	amount.tween.custom_step(AbyssMotion.EMPHASIS + AbyssMotion.QUICK)
	assert_eq(amount.get_theme_color(&"font_color"), Base)
	assert_eq(amount.scale, Vector2.ONE)
	assert_false(amount.is_flashing())


func test_a_second_change_restarts_the_flash() -> void:
	var amount := _amount(100)
	amount.set_amount(130)
	var first := amount.tween
	amount.set_amount(90)
	assert_false(first.is_valid())
	assert_eq(amount.get_theme_color(&"font_color"), AbyssColors.ERROR)


func test_the_same_amount_changes_nothing() -> void:
	var amount := _amount(100)
	amount.set_amount(100)
	assert_false(amount.is_flashing())
	assert_eq(amount.get_theme_color(&"font_color"), Base)


func test_with_fewer_animations_it_just_changes() -> void:
	var amount := _amount(100)
	amount.reduced_motion = true
	amount.set_amount(130)
	assert_eq(amount.text, "130")
	assert_eq(amount.get_theme_color(&"font_color"), Base)
	assert_eq(amount.scale, Vector2.ONE)
	assert_false(amount.is_flashing())


func test_outside_the_tree_it_just_changes() -> void:
	var amount := AnimatedAmount.new(Base, 1)
	amount.set_amount(2)
	assert_eq(amount.text, "2")
	assert_false(amount.is_flashing())
	amount.free()


func _amount(start: int) -> AnimatedAmount:
	return mount(AnimatedAmount.new(Base, start)) as AnimatedAmount
