extends TipCase
## test/presentation/widgets/tip/tip_stack_test.dart: the tips that arrive
## together, one card after the other.


func _stack(ids: Array[TipId.Value]) -> TipStack:
	var tips: Array[Tip] = []
	for id in ids:
		tips.append(tip(id))
	var stack := TipStack.new(tips)
	modals().open(stack)
	return stack


func test_a_lone_tip_has_no_count_and_closes_on_got_it() -> void:
	var stack := _stack([Id.STORM])
	assert_null(stack.count_label)
	assert_eq(stack.next_button.text, "Compris")
	press("Compris")
	assert_true(stack.is_closed())


func test_several_tips_are_counted_and_gone_through_with_next() -> void:
	var stack := _stack([Id.NOISE_GAUGE, Id.EVENTS, Id.STORM])
	assert_eq(stack.count_label.text, "1 / 3")
	assert_eq(stack.next_button.text, "Suivant")
	assert_eq(stack.card.title_label.text, TipTexts.title(Id.NOISE_GAUGE))
	press("Suivant")
	assert_eq(stack.count_label.text, "2 / 3")
	assert_eq(stack.card.title_label.text, TipTexts.title(Id.EVENTS))
	press("Suivant")
	assert_eq(stack.next_button.text, "Compris")
	assert_false(stack.is_closed())
	press("Compris")
	assert_true(stack.is_closed())


func test_a_swipe_goes_on_and_back_and_stops_at_the_ends() -> void:
	var stack := _stack([Id.NOISE_GAUGE, Id.EVENTS])
	stack.swipe(TipStack.SWIPE)
	assert_eq(stack.index, 0, "nothing before the first")
	stack.swipe(-TipStack.SWIPE)
	assert_eq(stack.index, 1)
	stack.swipe(-TipStack.SWIPE)
	assert_eq(stack.index, 1, "nothing after the last")
	stack.swipe(TipStack.SWIPE)
	assert_eq(stack.index, 0)
	stack.swipe(TipStack.SWIPE / 2.0)
	assert_eq(stack.index, 0, "a short drag is no swipe")


func _touch(pressed: bool, x: float) -> InputEventMouseButton:
	var touch := InputEventMouseButton.new()
	touch.button_index = MOUSE_BUTTON_LEFT
	touch.pressed = pressed
	touch.position = Vector2(x, 0.0)
	return touch


func test_a_touch_drag_is_a_swipe() -> void:
	var stack := _stack([Id.NOISE_GAUGE, Id.EVENTS])
	stack._gui_input(_touch(true, 200.0))
	stack._gui_input(_touch(false, 100.0))
	assert_eq(stack.index, 1)
	stack._gui_input(InputEventMouseButton.new())
	assert_eq(stack.index, 1)


func test_speaks_the_three_languages() -> void:
	var stack := _stack([Id.NOISE_GAUGE, Id.EVENTS])
	use_language("en")
	assert_eq(stack.next_button.text, "Next")
	assert_no_raw_keys(stack)
	use_language("es")
	assert_eq(stack.next_button.text, "Siguiente")
	assert_no_raw_keys(stack)
