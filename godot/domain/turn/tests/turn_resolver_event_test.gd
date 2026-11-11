extends TestCase
## test/domain/turn/turn_resolver_event_test.dart: the random events in the
## result of an end of turn.


static func _game(player: Player, turn: int) -> Game:
	var game := Game.single_player(player)
	game.turn = turn
	return game


func test_the_first_turn_schedules_the_first_event_and_draws_nothing() -> void:
	var player := Player.new("Nemo", "human")
	var result := TurnResolver.new().resolve(_game(player, 1), DartRandom.new(3))
	assert_null(result.event)
	assert_null(result.defaulted_event)
	var next: int = player.event_state.next_draw_turn
	assert_true(next >= 5 and next <= 8, str(next))


func test_the_turn_result_carries_the_event_drawn_for_the_human() -> void:
	var player := Player.new("Nemo", "human")
	player.event_state.schedule(12)
	var result := TurnResolver.new().resolve(_game(player, 12), DartRandom.new(3))
	assert_not_null(result.event)
	assert_eq(result.event, player.event_state.last_drawn)


func test_the_turn_result_carries_the_event_left_without_a_choice() -> void:
	var player := Player.new("Nemo", "human")
	player.event_state.schedule(30)
	player.event_state.set_pending(RandomEventType.Value.SURVIVORS, 12)
	var result := TurnResolver.new().resolve(_game(player, 12), DartRandom.new(3))
	assert_eq(result.defaulted_event, RandomEventType.Value.SURVIVORS)
	assert_null(result.event)
	var entries := EventSamples.event_entries_of(player)
	assert_eq(entries.size(), 1)
	assert_true(entries[0].defaulted)


func test_the_events_of_a_bot_stay_out_of_the_human_turn_result() -> void:
	var human := Player.new("Nemo", "human")
	human.event_state.schedule(30)
	var bot := Player.new("Bot", "bot")
	bot.event_state.schedule(12)
	var game := Game.new(human.id, {human.id: human, bot.id: bot}, 12)
	var result := TurnResolver.new().resolve(game, DartRandom.new(3))
	assert_null(result.event)
	assert_not_null(bot.event_state.last_drawn)
