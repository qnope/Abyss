extends UiTestCase
## test/presentation/widgets/opening/story_pager_test.dart: "Suivant" turns the
## cards, the last button and "Passer" end the story once, a swipe turns both
## ways.

var _done := 0


func test_shows_the_first_page_its_title_and_its_lines() -> void:
	var pager := _pager()
	assert_not_null(find_text("One"))
	assert_not_null(find_text("1a"))
	assert_not_null(find_text("1b"))
	assert_null(find_text("Two"))
	assert_not_null(find_text("Suivant"))
	assert_not_null(find_text("Passer"))
	assert_eq(pager.card.line_labels().size(), 2)
	assert_eq((pager.card.line_labels()[0] as Label).theme_type_variation, LoreText.LARGE)


func test_suivant_turns_the_pages_up_to_the_last_one() -> void:
	var pager := _pager()
	press("Suivant")
	assert_not_null(find_text("Two"))
	assert_null(find_text("One"))
	press("Suivant")
	assert_not_null(find_text("Three"))
	assert_null(find_text("Suivant"))
	assert_null(find_text("Passer"))
	assert_eq(_done, 0)
	assert_eq(pager.next_button.text, "OK")


func test_the_button_of_the_last_page_ends_the_story_once() -> void:
	_pager()
	press("Suivant")
	press("Suivant")
	press("OK")
	press("OK")
	assert_eq(_done, 1)


func test_passer_ends_the_story_at_once() -> void:
	_pager()
	press("Passer")
	assert_eq(_done, 1)


func test_a_swipe_turns_the_pages_both_ways() -> void:
	var pager := _pager()
	_swipe(pager, -200.0)
	assert_eq(pager.index, 1)
	_swipe(pager, 200.0)
	assert_eq(pager.index, 0)
	_swipe(pager, 200.0)
	assert_eq(pager.index, 0, "there is no card before the first")
	_swipe(pager, 20.0)
	_swipe(pager, -20.0)
	assert_eq(pager.index, 0, "a short move is no swipe")
	_swipe(pager, -200.0)
	_swipe(pager, -200.0)
	_swipe(pager, -200.0)
	assert_eq(pager.index, 2, "nor after the last")


func test_another_button_or_another_press_is_no_swipe() -> void:
	var pager := _pager()
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_RIGHT
	pager.gui_input.emit(event)
	pager.gui_input.emit(InputEventKey.new())
	assert_eq(pager.index, 0)


func test_lights_the_dot_of_the_current_card() -> void:
	var pager := _pager()
	var dots := find_type("HBoxContainer", pager.card.footer)[0].get_children()
	assert_eq(dots.size(), 3)
	assert_eq((dots[0] as Control).custom_minimum_size.x, float(StoryPager.CURRENT_DOT_WIDTH))
	assert_eq((dots[1] as Control).custom_minimum_size.x, float(StoryPager.DOT_WIDTH))
	var lit := (dots[0] as Panel).get_theme_stylebox(&"panel") as StyleBoxFlat
	var dim := (dots[1] as Panel).get_theme_stylebox(&"panel") as StyleBoxFlat
	assert_eq(lit.bg_color, AbyssColors.BIOLUM_CYAN)
	assert_eq(dim.bg_color, AbyssColors.DISABLED)
	press("Suivant")
	assert_eq((dots[1] as Control).custom_minimum_size.x, float(StoryPager.CURRENT_DOT_WIDTH))


func test_follows_the_language() -> void:
	var pager := _pager()
	use_language("en")
	assert_eq(pager.next_button.text, "Next")
	assert_eq(pager.skip_button.text, "Skip")
	assert_no_raw_keys()


func _swipe(pager: StoryPager, dx: float) -> void:
	for pressed: bool in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = Vector2(300.0 if pressed else 300.0 + dx, 100.0)
		pager.gui_input.emit(event)


func _pager() -> StoryPager:
	var pager := mount(StoryPager.new(_pages, &"commonOk")) as StoryPager
	pager.done.connect(func() -> void: _done += 1)
	return pager


func _pages() -> Array[StoryPage]:
	var found: Array[StoryPage] = []
	var titles: Array[String] = ["One", "Two", "Three"]
	for at in titles.size():
		found.append(StoryPage.new(func() -> Control: return Control.new(), titles[at],
			PackedStringArray(["%da" % (at + 1), "%db" % (at + 1)])))
	return found
