extends UiTestCase
## The placeholder of the game screen: the game being played and the way back
## to the menu.

var _quits := 0


func test_tells_the_game_being_played() -> void:
	var screen := _screen(SavedGameSamples.game("Alice", 14))
	assert_eq(screen.title_label.text, "Partie en cours")
	assert_eq(screen.game_label.text, "Alice · Tour 14 · Normal")
	assert_eq(screen.quit_button.text, "Sauvegarder et quitter")
	assert_no_raw_keys()


func test_quits_back_to_the_menu() -> void:
	_screen(SavedGameSamples.game("Alice"))
	press("Sauvegarder et quitter")
	assert_eq(_quits, 1)


func test_follows_the_language() -> void:
	var screen := _screen(SavedGameSamples.game("Alice", 2))
	use_language("en")
	assert_eq(screen.title_label.text, "Current game")
	assert_eq(screen.game_label.text, "Alice · Turn 2 · Normal")
	assert_eq(screen.quit_button.text, "Save and quit")


func test_lets_the_touches_through_to_the_world() -> void:
	var screen := _screen(SavedGameSamples.game("Alice"))
	assert_eq(screen.mouse_filter, Control.MOUSE_FILTER_IGNORE)


func _screen(game: Game) -> GamePlaceholderScreen:
	var screen := mount(GamePlaceholderScreen.new(game)) as GamePlaceholderScreen
	screen.quit_requested.connect(func() -> void: _quits += 1)
	return screen
