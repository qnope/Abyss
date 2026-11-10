extends TestCase
## test/domain/event/event_resolver_test.dart: when the random events are
## drawn at the end of a turn.

const CARAVAN := RandomEventType.Value.CARAVAN


func _resolve(player: Player, turn: int, seed_: int) -> EventTurnOutcome:
	return EventResolver.resolve(EventSamples.event_game(player, turn), player, turn, DartRandom.new(seed_))


func test_a_new_game_schedules_its_first_draw_on_turns_5_to_8() -> void:
	var turns := {}
	for seed_: int in 100:
		var player := EventSamples.event_player()
		var outcome := _resolve(player, 1, seed_)
		assert_null(outcome.drawn)
		assert_false(player.event_state.has_pending())
		turns[player.event_state.next_draw_turn] = true
	assert_eq(turns.size(), 4)
	for turn: int in [5, 6, 7, 8]:
		assert_true(turns.has(turn))


func test_nothing_is_drawn_before_the_scheduled_turn() -> void:
	var player := EventSamples.event_player()
	player.event_state.schedule(10)
	assert_null(_resolve(player, 9, 1).drawn)
	assert_eq(player.event_state.next_draw_turn, 10)
	assert_eq(player.event_state.events_seen, 0)


func test_a_draw_waits_for_a_choice_next_turn_the_next_one_5_to_8_later() -> void:
	var next_turns := {}
	for seed_: int in 100:
		var player := EventSamples.event_player()
		player.event_state.schedule(12)
		var drawn: RandomEventType.Value = _resolve(player, 12, seed_).drawn
		var state := player.event_state
		assert_eq([state.last_drawn, state.events_seen], [drawn, 1])
		if RandomEventChoice.has_choice(drawn):
			assert_eq([state.pending, state.pending_turn], [drawn, 13])
		next_turns[state.next_draw_turn] = true
	assert_eq(next_turns.size(), 4)
	for turn: int in [17, 18, 19, 20]:
		assert_true(next_turns.has(turn))


func test_an_event_still_waiting_for_a_choice_postpones_the_draw() -> void:
	var player := EventSamples.event_player()
	player.event_state.schedule(12)
	player.event_state.set_pending(CARAVAN, 13)
	assert_null(_resolve(player, 12, 1).drawn)
	assert_eq(player.event_state.pending, CARAVAN)
	assert_eq(player.event_state.next_draw_turn, 13)


func test_a_lasting_effect_postpones_the_draw_until_it_ends() -> void:
	var player := EventSamples.event_player()
	player.event_state.schedule(12)
	player.event_state.activate(RandomEventType.Value.WARM_CURRENT, 14)
	var game := EventSamples.event_game(player, 12)
	var random := DartRandom.new(1)
	for turn: int in [12, 13]:
		assert_null(EventResolver.resolve(game, player, turn, random).drawn)
		assert_eq(player.event_state.next_draw_turn, turn + 1)
	var outcome := EventResolver.resolve(game, player, 14, random)
	assert_null(player.event_state.active)
	assert_not_null(outcome.drawn)


func test_a_lasting_effect_ends_once_its_last_turn_is_over() -> void:
	var player := EventSamples.event_player()
	player.event_state.schedule(30)
	player.event_state.activate(RandomEventType.Value.STORM, 9)
	var game := EventSamples.event_game(player, 8)
	EventResolver.resolve(game, player, 8, DartRandom.new(1))
	assert_eq(player.event_state.active, RandomEventType.Value.STORM)
	EventResolver.resolve(game, player, 9, DartRandom.new(1))
	assert_null(player.event_state.active)
