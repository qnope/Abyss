extends AppFlowCase
## The random events in the game on show (game_screen_event_test.dart): the
## strip that reopens the card of the event waiting, the card that follows the
## summary of a turn that drew one, the warning of the question, and the
## choice that changes the game and saves it.

const Type := RandomEventType.Value


## A game of Alice with survivors waiting for a choice during its turn, on show.
func _play_with_survivors() -> GameHud:
	var game := _save("Alice")
	var state := game.human_player().event_state
	state.schedule(100)
	state.set_pending(Type.SURVIVORS, game.turn)
	state.survivors = 4
	_flow.play(game)
	return _flow.current as GameHud


func _saved_harpoonists() -> int:
	var saved := _repository.load_all().games[0]
	return saved.human_player().units_on_level(1)[UnitType.Value.HARPOONIST].count


func test_the_strip_reopens_the_card_and_the_choice_changes_and_saves_the_game() -> void:
	var hud := _play_with_survivors()
	var before := _saved_harpoonists()
	assert_not_null(find_text("Événement : Survivants — choisir", hud.status_bars))
	press(find_type("Button", hud.status_bars)[0])
	assert_true(current_modal() is EventCard)
	press("Accueillir 4 harponneurs")
	assert_null(current_modal())
	assert_false(hud.game.human_player().event_state.has_pending())
	assert_eq(_saved_harpoonists(), before + 4, "saved by the actions")
	assert_null(find_text("Événement : Survivants — choisir", hud.status_bars), "the strip is redrawn")


func test_the_prudent_option_is_saved_too() -> void:
	var hud := _play_with_survivors()
	var before := _saved_harpoonists()
	press(find_type("Button", hud.status_bars)[0])
	press("Refuser")
	assert_eq(_saved_harpoonists(), before)
	var saved := _repository.load_all().games[0]
	assert_false(saved.human_player().event_state.has_pending())
	var entries := EventSamples.event_entries_of(saved.human_player())
	assert_eq(entries.size(), 1, "the history keeps the choice")
	assert_false(entries[0].accepted)


func test_later_leaves_the_event_waiting_and_the_strip_in_place() -> void:
	var hud := _play_with_survivors()
	press(find_type("Button", hud.status_bars)[0])
	press("Plus tard")
	assert_true(hud.game.human_player().event_state.has_pending())
	assert_not_null(find_text("Événement : Survivants — choisir", hud.status_bars))


func test_the_question_warns_of_the_event_and_the_turn_settles_it_with_its_prudent_option() -> void:
	var hud := _play_with_survivors()
	press("Tour suivant")
	assert_not_null(find_text("Survivants : sans choix, l'option prudente s'appliquera", current_modal()))
	press("Confirmer")
	assert_not_null(find_text("Survivants : option prudente appliquée", current_modal()))
	assert_false(hud.game.human_player().event_state.has_pending())
	press("OK")


func test_the_turn_that_draws_an_event_shows_its_card_after_the_summary() -> void:
	var game := _save("Alice")
	game.human_player().event_state.schedule(1)
	_flow.play(game)
	press("Tour suivant")
	press("Confirmer")
	assert_true(current_modal() is TurnSummary)
	assert_true(game.human_player().event_state.events_seen > 0, "an event was drawn at the end of the turn")
	press("OK")
	var card := current_modal() as EventCard
	assert_not_null(card, "then its card")
	# Each event has its prudent option, or only informs.
	if card.choice_buttons.is_empty():
		press("Compris")
	else:
		press(card.choice_buttons[1])
	assert_null(current_modal())
	assert_true(_flow.current is GameHud)
	assert_false(game.human_player().event_state.has_pending(), "the choice was made")


func test_the_card_and_the_strip_follow_the_language() -> void:
	var hud := _play_with_survivors()
	use_language("en")
	assert_not_null(find_text("Event: Survivors — choose", hud.status_bars))
	press(find_type("Button", hud.status_bars)[0])
	assert_not_null(find_text("Welcome 4 harpooners", current_modal()))
	assert_no_raw_keys(current_modal())
