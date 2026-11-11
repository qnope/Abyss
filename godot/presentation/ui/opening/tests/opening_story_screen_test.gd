extends UiTestCase
## test/presentation/screens/menu/new_game_opening_test.dart: the story over the
## dimmed world, ended by its last card, "Passer" or going back.

var _finished := 0


func test_opens_on_the_first_card_over_a_veil() -> void:
	var screen := _screen()
	assert_not_null(find_text("Le Grand Naufrage"))
	assert_eq((screen.get_child(0) as Control).theme_type_variation, AbyssSurfaceTheme.SCRIM)
	assert_eq(_finished, 0)
	assert_no_raw_keys()


func test_the_last_card_ends_the_story() -> void:
	_screen()
	for i in 3:
		press("Suivant")
	assert_not_null(find_text("Ton but"))
	press("Plonger")
	assert_eq(_finished, 1)


func test_passer_ends_the_story_at_once() -> void:
	_screen()
	press("Passer")
	assert_eq(_finished, 1)


func test_going_back_skips_the_story_once() -> void:
	var screen := _screen()
	var back := InputEventAction.new()
	back.action = &"ui_cancel"
	back.pressed = true
	screen._unhandled_input(back)
	screen._unhandled_input(back)
	assert_eq(_finished, 1)


func test_another_event_or_a_hidden_screen_does_not_skip_it() -> void:
	var screen := _screen()
	screen._unhandled_input(InputEventKey.new())
	screen.hide()
	var back := InputEventAction.new()
	back.action = &"ui_cancel"
	back.pressed = true
	screen._unhandled_input(back)
	assert_eq(_finished, 0)


func test_follows_the_language() -> void:
	_screen()
	use_language("en")
	assert_not_null(find_text("The Great Sinking"))
	assert_not_null(find_text("Next"))
	press("Next")
	press("Next")
	press("Next")
	assert_not_null(find_text("Dive in"))


func _screen() -> OpeningStoryScreen:
	var screen := mount(OpeningStoryScreen.new()) as OpeningStoryScreen
	screen.finished.connect(func() -> void: _finished += 1)
	return screen
