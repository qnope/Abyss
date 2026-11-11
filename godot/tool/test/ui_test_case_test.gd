extends TestCase
## The harness of the UI tests, checked on a probe so that this file's own
## tests stay green: mounting under the theme, finding by text, type and name,
## pressing, the modal on top, the language, and the cleanup afterwards.

const FIXTURE := "res://tool/test/fixtures/texts_error_test.gd"

var _probe: UiTestCase


func before_each() -> void:
	_probe = UiTestCase.new()
	add_cleanup(_probe.run_cleanups)


func test_mounts_a_component_under_the_game_theme_in_a_phone() -> void:
	var label := _probe.mount(Label.new()) as Label
	assert_true(label.is_inside_tree())
	assert_eq(label.get_parent(), _probe.host())
	assert_eq(_probe.host().size, UiTestCase.PHONE)
	assert_eq(_probe.host().theme.get_type_variation_base("HudPanel"), &"PanelContainer")
	assert_eq(_probe.host().auto_translate_mode, Node.AUTO_TRANSLATE_MODE_DISABLED)


func test_frees_what_it_mounted_after_the_test() -> void:
	var label := _probe.mount(Label.new())
	var host := _probe.host()
	_probe.run_cleanups()
	assert_false(is_instance_valid(label))
	assert_false(is_instance_valid(host))
	assert_ne(_probe.host(), host, "a new window next time")


func test_finds_the_visible_node_that_shows_a_text() -> void:
	var column := _probe.mount(VBoxContainer.new())
	var button := Button.new()
	button.text = "Valider"
	var hidden := Label.new()
	hidden.text = "Caché"
	hidden.visible = false
	column.add_child(button)
	column.add_child(hidden)
	assert_eq(_probe.find_text("Valider"), button)
	assert_null(_probe.find_text("Caché"), "hidden")
	assert_null(_probe.find_text("Absent"))
	assert_eq(_probe.find_text("Valider", column), button)
	assert_eq(_probe.texts(), PackedStringArray(["Valider"]))


func test_finds_by_type_and_by_name() -> void:
	var column := _probe.mount(VBoxContainer.new())
	var first := Label.new()
	first.name = "First"
	column.add_child(first)
	column.add_child(Label.new())
	assert_eq(_probe.find_type("Label").size(), 2)
	assert_eq(_probe.find_type("Label", column)[0], first)
	assert_eq(_probe.find_named("First"), first)
	assert_null(_probe.find_named("Missing", column))


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


func test_reads_the_modal_on_top() -> void:
	assert_null(_probe.current_modal())
	var dialog := ModalPanel.new()
	_probe.modals().open(dialog)
	assert_eq(_probe.current_modal(), dialog)
	assert_eq(_probe.modals().get_parent(), _probe.host())


func test_writes_a_text_in_the_language_on_and_puts_french_back() -> void:
	assert_eq(_probe.text(&"commonClose"), "Fermer")
	_probe.use_language("en")
	assert_eq(_probe.text(&"commonClose"), "Close")
	assert_eq(_probe.text(&"commonTurn", {"turn": 7}), "Turn 7")
	_probe.run_cleanups()
	assert_eq(TranslationServer.get_locale(), "fr")


func test_a_raw_key_shown_is_a_failure() -> void:
	var label := _probe.mount(Label.new()) as Label
	label.text = "Fermer"
	_probe.assert_no_raw_keys()
	assert_eq(_probe.failures(), PackedStringArray())
	label.text = "commonClose"
	_probe.assert_no_raw_keys()
	assert_eq(_probe.failures().size(), 1)
	assert_has(_probe.failures()[0], "commonClose")


func test_a_test_that_asks_for_an_unknown_text_fails() -> void:
	# The fixture's errors reach this test's log too: it expects them itself.
	expect_error("Texts: no translation")
	var run := TestSuite.run(PackedStringArray([FIXTURE]))
	assert_eq(run.test_count(), 2)
	var failed := run.failed()
	assert_eq(failed.size(), 1)
	assert_eq(failed[0].name, "test_asks_for_a_key_that_does_not_exist")
	assert_has(failed[0].failures[0], 'Texts: no translation for "noSuchKey"')
