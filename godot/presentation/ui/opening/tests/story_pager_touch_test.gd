extends UiTestCase
## The pager under a phone's finger, which sends touches, not clicks: a swipe
## turns the cards from anywhere on the pager, and the mouse a touch emulates is
## not a second swipe. Safari on an iPhone numbers its fingers from a running
## count, never from 0: the first finger down is the one followed, whatever its
## number.


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


func test_a_finger_numbered_as_an_iphone_does_turns_the_pages() -> void:
	var pager := _pager()
	pager.size = Vector2(390.0, 600.0)
	var from := pager.get_global_rect().get_center()
	_finger(from, true, 1043)
	_finger(from + Vector2(-200.0, 0.0), false, 1043)
	assert_eq(pager.index, 1)
	_finger(from, true, 1044)
	_finger(from + Vector2(200.0, 0.0), false, 1044)
	assert_eq(pager.index, 0)


func test_a_finger_that_starts_outside_the_pager_is_no_swipe() -> void:
	var pager := _pager()
	pager.size = Vector2(390.0, 600.0)
	var from := pager.get_global_rect().get_center()
	_finger(pager.get_global_rect().position - Vector2(50.0, 50.0), true)
	_finger(from + Vector2(-200.0, 0.0), false)
	assert_eq(pager.index, 0)


func test_a_second_finger_down_with_the_first_is_no_swipe() -> void:
	var pager := _pager()
	pager.size = Vector2(390.0, 600.0)
	var from := pager.get_global_rect().get_center()
	_finger(from, true, 5)
	_finger(from, true, 6)
	_finger(from + Vector2(-200.0, 0.0), false, 6)
	assert_eq(pager.index, 0)
	_finger(from + Vector2(-200.0, 0.0), false, 5)
	assert_eq(pager.index, 1, "the first finger still swipes")


func test_a_hidden_pager_takes_no_swipe_and_follows_the_next_finger_once_shown() -> void:
	var pager := _pager()
	pager.size = Vector2(390.0, 600.0)
	var from := pager.get_global_rect().get_center()
	pager.hide()
	_finger(from, true, 3)
	_finger(from + Vector2(-200.0, 0.0), false, 3)
	assert_eq(pager.index, 0)
	_finger(from, true, 4)
	pager.show()
	_finger(from + Vector2(-200.0, 0.0), false, 4)
	assert_eq(pager.index, 0, "its press was not seen")
	_finger(from, true, 9)
	_finger(from + Vector2(-200.0, 0.0), false, 9)
	assert_eq(pager.index, 1)


func test_a_cancelled_finger_is_no_swipe() -> void:
	var pager := _pager()
	pager.size = Vector2(390.0, 600.0)
	var from := pager.get_global_rect().get_center()
	_finger(from, true, 2)
	var cancel := InputEventScreenTouch.new()
	cancel.index = 2
	cancel.canceled = true
	cancel.position = host().get_viewport().get_final_transform() * (from + Vector2(-200.0, 0.0))
	host().get_viewport().push_input(cancel)
	assert_eq(pager.index, 0)
	_finger(from, true, 8)
	_finger(from + Vector2(-200.0, 0.0), false, 8)
	assert_eq(pager.index, 1)


func test_a_mouse_drag_through_the_window_turns_one_page_only() -> void:
	# Read by the card's own input, not again as a finger.
	var pager := _pager()
	pager.size = Vector2(390.0, 600.0)
	var from := pager.get_global_rect().get_center()
	_mouse(from, true)
	_mouse(from + Vector2(-200.0, 0.0), false)
	assert_eq(pager.index, 1)


func _mouse(at: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = host().get_viewport().get_final_transform() * at
	host().get_viewport().push_input(event)


func _finger(at: Vector2, pressed: bool, index := 0) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
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
