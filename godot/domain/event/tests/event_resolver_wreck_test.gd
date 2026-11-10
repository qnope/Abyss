extends TestCase
## test/domain/event/event_resolver_wreck_test.dart: the wreck at the end
## of a turn. The `subtitle` of an entry, always null, is not ported.

const WRECK := CellContentType.Value.WRECK


func _content(game: Game, at: GridPosition) -> CellContentType.Value:
	return game.current_map().cell_at(at.x, at.y).content


## A wreck drawn at the end of turn 12 with Random(2) on the map of `game`.
func _drawn(game: Game, player: Player, seed_ := 2) -> GridPosition:
	WreckEffect.new().on_draw(game, player, 12, DartRandom.new(seed_))
	return player.event_state.wreck_position


func test_a_drawn_wreck_sinks_at_once_without_waiting_for_a_choice() -> void:
	var wrecks := 0
	for seed_: int in 60:
		var player := EventSamples.wreck_player()
		player.event_state.schedule(12)
		var game := EventSamples.wreck_game(player)
		if EventResolver.resolve(game, player, 12, DartRandom.new(seed_)).drawn != RandomEventType.Value.WRECK:
			continue
		wrecks += 1
		var state := player.event_state
		assert_false(state.has_pending())
		assert_null(state.active)
		assert_eq([state.last_drawn, state.wreck_until_turn], [RandomEventType.Value.WRECK, 12 + EventRules.WRECK_TURNS])
		assert_eq(_content(game, state.wreck_position), WRECK)
		var entries := EventSamples.event_entries_of(player)
		assert_eq(entries.size(), 1)
		assert_true(entries[0].accepted)
	assert_true(wrecks > 0)


func test_a_wreck_left_alone_sinks_out_of_reach_after_the_end_of_turn_17() -> void:
	var player := EventSamples.wreck_player()
	var game := EventSamples.wreck_game(player)
	var at := _drawn(game, player)
	for turn: int in range(13, 17):
		EventResolver.resolve(game, player, turn, DartRandom.new(turn))
		assert_eq(_content(game, at), WRECK)
	EventResolver.resolve(game, player, 17, DartRandom.new(17))
	assert_eq(_content(game, at), CellContentType.Value.EMPTY)
	assert_null(player.event_state.wreck_position)
	assert_null(player.event_state.wreck_until_turn)


func test_a_wreck_on_the_map_neither_holds_back_the_next_draw_nor_repeats() -> void:
	for seed_: int in 40:
		var player := EventSamples.wreck_player()
		var game := EventSamples.wreck_game(player)
		_drawn(game, player, seed_)
		player.event_state.schedule(14)
		var drawn: Variant = EventResolver.resolve(game, player, 14, DartRandom.new(seed_)).drawn
		assert_not_null(drawn, "seed %d" % seed_)
		assert_ne(drawn, RandomEventType.Value.WRECK)
		assert_not_null(player.event_state.wreck_position)


func test_the_end_of_turn_17_tells_the_sunk_wreck_and_its_last_turn() -> void:
	var player := EventSamples.wreck_player()
	var game := EventSamples.wreck_game(player)
	_drawn(game, player)
	for turn: int in range(13, 17):
		assert_null(EventResolver.resolve(game, player, turn).wreck)
	var ending := EventResolver.resolve(game, player, 17).wreck
	assert_false(ending.searched)
	assert_eq(ending.until_turn, 17)


func test_a_wreck_searched_during_the_turn_is_told_at_its_end_once() -> void:
	var player := EventSamples.wreck_player()
	var game := EventSamples.wreck_game(player, null, 14)
	var at := _drawn(game, player)
	player.add_revealed_cell(1, at)
	var search := CollectTreasureAction.new(at.x, at.y)
	assert_true(ActionExecutor.new().execute(search, game, player).is_success)
	assert_null(player.event_state.wreck_position)

	var ending := EventResolver.resolve(game, player, 14).wreck

	assert_true(ending.searched)
	assert_eq(ending.until_turn, 17)
	assert_null(player.event_state.wreck_until_turn)
	assert_null(EventResolver.resolve(game, player, 15).wreck)
