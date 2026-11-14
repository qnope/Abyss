extends AppFlowCase
## The ways out of the game on show: a change still waiting for the next
## frame to be saved is written at once when the game is left, whatever takes
## its place, and when the app goes away; a game left is never written again.


func test_a_change_of_the_game_waits_for_the_next_frame() -> void:
	var session := _play_and_change()
	assert_eq(_saved_turn(), 1)
	assert_true(session.is_save_waiting())


func test_a_menu_in_place_of_the_game_writes_the_save_that_waits() -> void:
	var session := _play_and_change()
	_flow.show_menu()
	assert_eq(_saved_turn(), 9)
	assert_false(session.is_save_waiting())


func test_another_game_played_writes_the_save_of_the_first() -> void:
	_play_and_change()
	_flow.play(_save("Bob"))
	assert_eq(_saved_turn(), 9)
	assert_eq((_flow.current as GameHud).game.human_player().name, "Bob")


func test_saving_and_quitting_writes_the_game_once() -> void:
	var session := _play_and_change()
	var before := _clock
	_save_and_quit()
	assert_eq(_saved_turn(), 9)
	assert_eq(_clock, before + SavedGameSamples.HOUR, "one save, none left for the next frame")
	assert_false(session.is_save_waiting())


func test_the_app_going_away_writes_the_save_that_waits() -> void:
	var session := _play_and_change()
	_flow.flush()
	assert_eq(_saved_turn(), 9)
	assert_false(session.is_save_waiting())
	assert_eq(_flow.controller.session, session, "the game goes on")
	var before := _clock
	_flow.flush()
	assert_eq(_clock, before, "nothing waits, nothing is written")


func test_the_app_going_away_from_a_menu_writes_nothing() -> void:
	_flow.show_menu()
	_flow.flush()
	assert_eq(_repository.load_all().games.size(), 0)


func test_a_game_deleted_once_left_is_never_written_back() -> void:
	var session := _play_and_change()
	_flow.show_load_game()
	_card_of("Alice").menu.popup.id_pressed.emit(SaveCardMenu.DELETE_ID)
	press("Supprimer")
	session.actions.mark(func(game: Game) -> void: game.turn = 10)
	session.flush()
	assert_false(session.is_save_waiting())
	assert_eq(DirAccess.get_files_at(_repository.folder), PackedStringArray())


## Plays a game of Alice and changes it: its turn is 9, the disk's still 1.
func _play_and_change() -> GameSession:
	_flow.play(_save("Alice"))
	var session := _flow.controller.session
	session.actions.mark(func(game: Game) -> void: game.turn = 9)
	return session


## The turn of Alice's game as the disk holds it.
func _saved_turn() -> int:
	return _repository.load_all().games[0].turn
