extends UiTestCase
## lib/presentation/widgets/turn/story_skip_button.dart: the "Passer ›" over the
## map while a turn's story is told.

var _skips := 0


func _make() -> StorySkipButton:
	var skip := StorySkipButton.new()
	skip.skipped.connect(func() -> void: _skips += 1)
	return skip


func test_it_reads_pass_and_tells_when_it_is_pressed() -> void:
	var skip := _make()
	mount(skip)
	assert_eq(skip.button.text, "Passer ›")
	press("Passer ›")
	assert_eq(_skips, 1)


func test_it_wears_the_theme_of_the_buttons_over_the_map() -> void:
	assert_eq(_make().button.theme_type_variation, &"OverMapButton")


func test_it_follows_the_language() -> void:
	var skip := _make()
	mount(skip)
	use_language("en")
	assert_eq(skip.button.text, text(&"turnStorySkip"))
	assert_ne(skip.button.text, "Passer ›")


func test_it_stands_in_the_bottom_right_corner_of_the_area_it_floats_in() -> void:
	var area := mount(Control.new())
	var skip := _make()
	skip.float_in(area)
	assert_eq(skip.get_parent(), area)
	assert_eq(skip.anchor_left, 1.0)
	assert_eq(skip.anchor_top, 1.0)
	assert_eq(skip.offset_right, -float(StorySkipButton.MARGIN))
	assert_eq(skip.offset_bottom, -float(StorySkipButton.MARGIN))
