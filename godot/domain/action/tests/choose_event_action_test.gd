extends TestCase
## test/domain/action/choose_event_action_test.dart: the player's choice for
## a random event.

const CARAVAN := RandomEventType.Value.CARAVAN


func test_is_a_french_choice_of_the_event_action_type() -> void:
	assert_eq(ChooseEventAction.new(true).type(), ActionType.Value.CHOOSE_EVENT)
	assert_eq(ChooseEventAction.new(true).description(), "Accepter l'événement")
	assert_eq(ChooseEventAction.new(false).description(), "Refuser l'événement")


func test_fails_when_no_event_waits_for_a_choice() -> void:
	var player := EventSamples.event_player()
	var result := ChooseEventAction.new(true).validate(EventSamples.event_game(player, 12), player)
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.NO_PENDING_EVENT)


func test_fails_outside_the_turn_of_the_choice() -> void:
	var player := EventSamples.event_player()
	player.event_state.set_pending(CARAVAN, 13)
	var result := ChooseEventAction.new(true).validate(EventSamples.event_game(player, 12), player)
	assert_false(result.is_success)
	assert_eq(result.reason, ActionFailure.Value.NOT_THIS_CHOICE_TURN)


func test_settles_the_event_once_chosen() -> void:
	for accept: bool in [true, false]:
		var player := EventSamples.event_player()
		player.event_state.set_pending(CARAVAN, 12)
		var game := EventSamples.event_game(player, 12)
		var result := ActionExecutor.new().execute(ChooseEventAction.new(accept), game, player)
		assert_true(result.is_success)
		assert_false(player.event_state.has_pending())
		assert_eq(player.event_state.last_drawn, CARAVAN)
		var entries := EventSamples.event_entries_of(player)
		assert_eq(entries.size(), 1)
		assert_eq([entries[0].turn, entries[0].type, entries[0].accepted, entries[0].defaulted], [12, CARAVAN, accept, false])


func test_the_choice_is_written_in_the_replay_journal() -> void:
	var player := EventSamples.event_player()
	player.event_state.set_pending(RandomEventType.Value.SURVIVORS, 12)
	var game := EventSamples.event_game(player, 12)
	game.replay = ReplayJournal.new(1, "Test")

	ActionExecutor.new().execute(ChooseEventAction.new(false), game, player)

	assert_eq(game.replay.actions_of(12), [{"do": "event", "accept": false}] as Array[Dictionary])
	assert_true(game.replay.exact)


func test_a_second_choice_in_the_same_turn_fails() -> void:
	var player := EventSamples.event_player()
	player.event_state.set_pending(RandomEventType.Value.SURVIVORS, 12)
	var game := EventSamples.event_game(player, 12)
	var executor := ActionExecutor.new()
	executor.execute(ChooseEventAction.new(true), game, player)
	assert_false(executor.execute(ChooseEventAction.new(true), game, player).is_success)
	assert_eq(EventSamples.event_entries_of(player).size(), 1)


## Not in the Dart file: executed alone, a choice without an event fails.
func test_executed_without_an_event_the_choice_fails() -> void:
	var player := EventSamples.event_player()
	var result := ChooseEventAction.new(false).execute(EventSamples.event_game(player, 12), player)
	assert_eq([result.is_success, result.reason], [false, ActionFailure.Value.NO_PENDING_EVENT])
