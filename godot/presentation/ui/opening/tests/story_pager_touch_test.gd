extends UiTestCase
## The pager under a phone's finger, which sends touches, not clicks: a swipe
## turns the cards from anywhere on the pager, and the mouse a touch emulates is
## not a second swipe.


func test_a_finger_swipe_turns_the_pages_even_from_the_card() -> void:
	var pager := _pager()
	pager.size = Vector2(390.0, 600.0)
	var from := pager.get_global_rect().get_center()
	_finger(from, true)
	_finger(from + Vector2(-200.0, 0.0), false)
	assert_eq(pager.index, 1)
	_emulated_click(pager, true, 300.0)
	_emulated_click(pager, false, 100.0)
	assert_eq(pager.index, 1, "the emulated mouse is the same swipe")
	_finger(from, true)
	_finger(from + Vector2(200.0, 0.0), false)
	assert_eq(pager.index, 0)


func test_a_finger_that_starts_outside_the_pager_or_is_not_the_first_is_no_swipe() -> void:
	var pager := _pager()
	pager.size = Vector2(390.0, 600.0)
	var from := pager.get_global_rect().get_center()
	_finger(pager.get_global_rect().position - Vector2(50.0, 50.0), true)
	_finger(from + Vector2(-200.0, 0.0), false)
	assert_eq(pager.index, 0)
	var second := InputEventScreenTouch.new()
	second.index = 1
	second.pressed = true
	host().get_viewport().push_input(second)
	pager.hide()
	_finger(from, true)
	_finger(from + Vector2(-200.0, 0.0), false)
	assert_eq(pager.index, 0)


func _finger(at: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.position = host().get_viewport().get_final_transform() * at
	event.pressed = pressed
	host().get_viewport().push_input(event)


func _emulated_click(pager: StoryPager, pressed: bool, x: float) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = Vector2(x, 100.0)
	event.device = InputEvent.DEVICE_ID_EMULATION
	pager.gui_input.emit(event)


func _pager() -> StoryPager:
	var pages: Array[StoryPage] = []
	for title: String in ["One", "Two", "Three"]:
		pages.append(StoryPage.new(func() -> Control: return Control.new(), title,
			PackedStringArray()))
	return mount(StoryPager.new(func() -> Array[StoryPage]: return pages, &"commonOk")) as StoryPager
