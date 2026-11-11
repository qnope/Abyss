extends UiTestCase
## test/presentation/screens/menu/load_game_screen_*_test.dart: the saved
## games, ready to be resumed or deleted.

var _chosen: Array[Game] = []
var _deleted: Array[Game] = []
var _new_games := 0
var _backs := 0


func test_shows_the_empty_state_when_there_is_no_save() -> void:
	var screen := _screen([])
	assert_not_null(screen.empty)
	assert_null(screen.list)
	assert_not_null(find_text("Aucune colonie détectée"))
	assert_not_null(find_text("Fondez votre première base dans les abysses."))


func test_sits_on_the_dimmed_world_under_its_title() -> void:
	var screen := _screen([SavedGameSamples.game("Alice")])
	assert_eq(screen.bar.title(), "Charger une partie")
	assert_eq((screen.get_child(0) as Control).theme_type_variation, AbyssSurfaceTheme.VEIL)
	assert_null(screen.empty)


func test_starts_a_new_game_from_the_empty_state() -> void:
	_screen([])
	press("NOUVELLE PARTIE")
	assert_eq(_new_games, 1)


func test_going_back_tells_back() -> void:
	var screen := _screen([])
	press(screen.bar.back_button)
	assert_eq(_backs, 1)


func test_a_touch_on_a_game_resumes_it() -> void:
	var alice := SavedGameSamples.game("Alice")
	var screen := _screen([alice])
	press(screen.list.card_of(alice).tap_button)
	assert_eq(_chosen, [alice] as Array[Game])


func test_asks_before_deleting_a_game() -> void:
	var alice := SavedGameSamples.game("Alice")
	var screen := _screen([alice])
	screen.list.card_of(alice).menu.popup.id_pressed.emit(SaveCardMenu.DELETE_ID)
	assert_eq((current_modal() as AbyssDialog).title(), "Supprimer la partie ?")
	assert_eq(_deleted.size(), 0, "nothing is deleted before the answer")


func test_deletes_the_game_once_confirmed_only() -> void:
	var alice := SavedGameSamples.game("Alice", 1, GameStatus.Value.PLAYING, 1)
	var bob := SavedGameSamples.game("Bob", 1, GameStatus.Value.PLAYING, 2)
	var screen := _screen([alice, bob])
	screen.list.card_of(bob).menu.popup.id_pressed.emit(SaveCardMenu.DELETE_ID)
	press("Supprimer")
	assert_eq(_deleted, [bob] as Array[Game])
	assert_null(current_modal())


func test_cancelling_or_dismissing_keeps_the_game() -> void:
	var alice := SavedGameSamples.game("Alice")
	var screen := _screen([alice])
	screen.list.card_of(alice).menu.popup.id_pressed.emit(SaveCardMenu.DELETE_ID)
	press("Annuler")
	screen.list.card_of(alice).menu.popup.id_pressed.emit(SaveCardMenu.DELETE_ID)
	modals().close_top()
	assert_eq(_deleted.size(), 0)


func test_tells_a_lost_game_by_its_report() -> void:
	var lost := SavedGameSamples.game("Alice", 27, GameStatus.Value.DEFEAT)
	_screen([lost])
	assert_not_null(find_text("Tombée au tour 26 · Surface · Normal"))


func _screen(games: Array[Game]) -> LoadGameScreen:
	var screen := mount(LoadGameScreen.new(SaveSections.of(games), modals(), SavedGameSamples.now())) as LoadGameScreen
	screen.game_chosen.connect(func(game: Game) -> void: _chosen.append(game))
	screen.delete_confirmed.connect(func(game: Game) -> void: _deleted.append(game))
	screen.new_game_requested.connect(func() -> void: _new_games += 1)
	screen.back_pressed.connect(func() -> void: _backs += 1)
	return screen
