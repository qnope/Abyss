extends UiTestCase
## The row above the tabs: the settings, the turn counter and the next turn
## button (game_bottom_bar_test.dart).

var _settings := 0
var _end_turns := 0


func test_shows_the_turn_number() -> void:
	var bar := _bar(3)
	assert_eq(bar.turn_label.text, "Tour 3")
	assert_eq(bar.turn_label.theme_type_variation, &"HudTurn")
	bar.set_turn(4)
	assert_eq(bar.turn_label.text, "Tour 4")
	assert_no_raw_keys()


func test_the_next_turn_button_only_asks_for_the_end_of_the_turn() -> void:
	_bar(1)
	press("Tour suivant")
	assert_eq(_end_turns, 1)
	assert_eq(_settings, 0)


func test_the_settings_button_asks_for_the_settings() -> void:
	var bar := _bar(1)
	press(bar.settings_button)
	assert_eq(_settings, 1)
	assert_eq(_end_turns, 0)


func test_the_buttons_have_their_icons_and_a_name_for_a_screen_reader() -> void:
	var bar := _bar(1)
	assert_eq(bar.next_turn_button.icon.resource_path, UiIcon.glyph_path(&"skip_next"))
	assert_eq(bar.settings_button.accessibility_name, "Paramètres")
	assert_true(bar.settings_button.custom_minimum_size.x >= AbyssHudTheme.TOUCH_SIZE)


func test_follows_the_language() -> void:
	var bar := _bar(2)
	use_language("en")
	assert_eq(bar.turn_label.text, "Turn 2")
	assert_eq(bar.next_turn_button.text, "Next turn")
	assert_eq(bar.settings_button.accessibility_name, "Settings")


func _bar(turn: int) -> TurnBar:
	var bar := mount(TurnBar.new(turn)) as TurnBar
	bar.settings_requested.connect(func() -> void: _settings += 1)
	bar.end_turn_requested.connect(func() -> void: _end_turns += 1)
	return bar
