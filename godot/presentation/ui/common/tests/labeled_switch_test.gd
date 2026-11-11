extends UiTestCase
## The switch with its title and subtitle, the whole row tappable.

var _changes: Array = []


func test_shows_the_title_over_the_subtitle_and_a_switch() -> void:
	var row := _row(false)
	assert_eq(row.title_label.text, "Tips")
	assert_eq(row.title_label.theme_type_variation, &"TitleMedium")
	assert_eq(row.subtitle_label.text, "Short advice now and then")
	assert_eq(row.subtitle_label.theme_type_variation, &"BodySmall")
	assert_eq(row.switch.theme_type_variation, &"Switch")
	assert_eq(row.switch.accessibility_name, "Tips")
	assert_eq(texts(row), PackedStringArray(["Tips", "Short advice now and then"]))


func test_starts_on_or_off() -> void:
	assert_false(_row(false).value())
	assert_true(_row(true).value())


func test_a_touch_on_the_switch_tells_the_new_value() -> void:
	var row := _row(false)
	press(row.switch)
	press(row.switch)
	assert_eq(_changes, [true, false])


func test_a_touch_on_the_row_moves_the_switch_and_tells_it() -> void:
	var row := _row(false)
	row.gui_input.emit(_touch(MOUSE_BUTTON_LEFT, true))
	assert_true(row.value())
	assert_eq(_changes, [true])
	row.gui_input.emit(_touch(MOUSE_BUTTON_LEFT, true))
	assert_eq(_changes, [true, false])


func test_other_events_on_the_row_do_nothing() -> void:
	var row := _row(false)
	row.gui_input.emit(_touch(MOUSE_BUTTON_LEFT, false))
	row.gui_input.emit(_touch(MOUSE_BUTTON_RIGHT, true))
	row.gui_input.emit(InputEventKey.new())
	assert_false(row.value())
	assert_eq(_changes, [])


func test_the_texts_let_the_touches_through_to_the_row() -> void:
	var row := _row(false)
	assert_eq(row.title_label.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(row.subtitle_label.mouse_filter, Control.MOUSE_FILTER_IGNORE)


func test_is_set_from_outside_without_telling() -> void:
	var row := _row(false)
	row.set_value(true)
	assert_true(row.value())
	assert_eq(_changes, [])


func _row(value: bool) -> LabeledSwitch:
	var row := LabeledSwitch.new("Tips", "Short advice now and then", value)
	row.toggled.connect(func(on: bool) -> void: _changes.append(on))
	mount(row)
	return row


static func _touch(button: MouseButton, pressed: bool) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = pressed
	return event
