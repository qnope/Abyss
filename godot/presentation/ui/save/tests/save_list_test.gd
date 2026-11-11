extends UiTestCase
## test/presentation/screens/menu/load_game_screen_test.dart: the sections and
## their order, the header of an empty section left out, the game to resume
## highlighted.

var _opened: Array[Game] = []
var _deleted: Array[Game] = []


func test_groups_games_in_progress_above_finished_ones_latest_first() -> void:
	var list := _list([
		SavedGameSamples.game("Ancien", 1, GameStatus.Value.PLAYING, 5),
		SavedGameSamples.game("Perdu", 1, GameStatus.Value.DEFEAT, 3),
		SavedGameSamples.game("Recent", 1, GameStatus.Value.PLAYING, 1),
		SavedGameSamples.game("Gagne", 1, GameStatus.Value.VICTORY, 2),
	])
	var shown := texts(list)
	var expected := PackedStringArray(["EN COURS", "Recent", "Ancien", "TERMINÉES", "Gagne", "Perdu"])
	var in_order := PackedStringArray()
	for each in shown:
		if expected.has(each):
			in_order.append(each)
	assert_eq(in_order, expected)


func test_leaves_out_the_header_of_an_empty_section() -> void:
	var list := _list([SavedGameSamples.game("Alice")])
	assert_not_null(find_text("EN COURS", list))
	assert_null(find_text("TERMINÉES", list))


func test_shows_only_finished_games_under_their_header() -> void:
	var list := _list([SavedGameSamples.game("Nemo", 1, GameStatus.Value.VICTORY)])
	assert_null(find_text("EN COURS", list))
	assert_not_null(find_text("TERMINÉES", list))


func test_dates_each_save_from_the_clock_given() -> void:
	var list := _list([SavedGameSamples.game("Alice", 1, GameStatus.Value.PLAYING, 2)])
	assert_not_null(find_text("il y a 2 h", list))


func test_highlights_the_game_in_progress_played_last() -> void:
	var recent := SavedGameSamples.game("Recent", 1, GameStatus.Value.PLAYING, 2)
	var old := SavedGameSamples.game("Ancien", 1, GameStatus.Value.PLAYING, 4)
	var won := SavedGameSamples.game("Gagne", 1, GameStatus.Value.VICTORY, 1)
	var list := _list([won, old, recent])
	assert_eq(list.card_of(recent).panel.theme_type_variation, &"SavePanelHighlighted")
	assert_eq(list.card_of(old).panel.theme_type_variation, &"SavePanel")
	assert_eq(list.card_of(won).panel.theme_type_variation, &"SavePanel")
	assert_eq(list.cards().size(), 3)
	assert_null(list.card_of(SavedGameSamples.game("Other")))


func test_tells_the_game_opened_and_the_game_to_delete() -> void:
	var alice := SavedGameSamples.game("Alice", 1, GameStatus.Value.PLAYING, 1)
	var bob := SavedGameSamples.game("Bob", 1, GameStatus.Value.PLAYING, 2)
	var list := _list([alice, bob])
	press(list.card_of(bob).tap_button)
	list.card_of(alice).menu.popup.id_pressed.emit(SaveCardMenu.DELETE_ID)
	assert_eq(_opened, [bob] as Array[Game])
	assert_eq(_deleted, [alice] as Array[Game])


func test_keeps_the_column_to_its_width_and_the_sides_to_the_gutter() -> void:
	var list := _list([SavedGameSamples.game("Alice")])
	var column := list.cards()[0].get_parent() as Control
	list.fit(Vector2(1280.0, 720.0))
	assert_eq(column.custom_minimum_size.x, SaveList.MAX_WIDTH)
	list.fit(Vector2(320.0, 640.0))
	assert_eq(column.custom_minimum_size.x, 320.0 - 2.0 * SaveList.GUTTER)
	list.size = Vector2(500.0, 600.0)
	assert_eq(column.custom_minimum_size.x, 500.0 - 2.0 * SaveList.GUTTER)


func test_follows_the_language() -> void:
	var list := _list([SavedGameSamples.game("Alice"), SavedGameSamples.game("Nemo", 1, GameStatus.Value.VICTORY)])
	use_language("en")
	assert_not_null(find_text("IN PROGRESS", list))
	assert_not_null(find_text("FINISHED", list))
	assert_no_raw_keys()


func _list(games: Array[Game]) -> SaveList:
	var list := mount(SaveList.new(SaveSections.of(games), SavedGameSamples.now())) as SaveList
	list.game_opened.connect(func(game: Game) -> void: _opened.append(game))
	list.delete_requested.connect(func(game: Game) -> void: _deleted.append(game))
	return list
