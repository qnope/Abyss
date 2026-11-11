extends TestCase
## What UiTestCase.press does to a button (ui_test_case_test.gd holds the rest
## of the harness), checked on a probe so that this file's tests stay green.

var _probe: UiTestCase


func before_each() -> void:
	_probe = UiTestCase.new()
	add_cleanup(_probe.run_cleanups)


func test_presses_a_button_or_the_text_of_one() -> void:
	var presses := []
	var button := Button.new()
	button.text = "Go"
	button.pressed.connect(func() -> void: presses.append("go"))
	_probe.mount(button)
	_probe.press(button)
	_probe.press("Go")
	assert_eq(presses, ["go", "go"])
	assert_eq(_probe.failures(), PackedStringArray())


func test_presses_the_button_a_label_is_drawn_over() -> void:
	var presses := []
	var button := Button.new()
	button.pressed.connect(func() -> void: presses.append("go"))
	var label := Label.new()
	label.text = "Over"
	button.add_child(label)
	_probe.mount(button)
	_probe.press("Over")
	_probe.mount(Label.new()).set("text", "Alone")
	_probe.press("Alone")
	assert_eq(presses, ["go"])
	assert_eq(_probe.failures().size(), 1)


func test_a_toggle_changes_state_as_a_touch_does() -> void:
	var toggle := Button.new()
	toggle.toggle_mode = true
	var states := []
	toggle.toggled.connect(func(on: bool) -> void: states.append(on))
	_probe.mount(toggle)
	_probe.press(toggle)
	_probe.press(toggle)
	assert_eq(states, [true, false])


func test_a_player_cannot_press_what_is_disabled_hidden_or_not_a_button() -> void:
	var disabled := Button.new()
	disabled.disabled = true
	var hidden := Button.new()
	hidden.visible = false
	_probe.mount(disabled)
	_probe.mount(hidden)
	_probe.press(disabled)
	_probe.press(hidden)
	_probe.press("Nowhere")
	var label := Label.new()
	_probe.press(label)
	label.free()
	assert_eq(_probe.failures().size(), 4)
	assert_has(_probe.failures()[0], "disabled")
	assert_has(_probe.failures()[1], "hidden")
	assert_has(_probe.failures()[2], 'no button for "Nowhere"')
	assert_has(_probe.failures()[3], "no button for")
