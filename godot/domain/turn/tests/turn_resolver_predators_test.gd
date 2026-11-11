extends TestCase
## test/domain/turn/turn_resolver_predators_test.dart: the school of
## predators fought at the end of the turn.


## Game of turn 12 whose predators are faced when `accept` is true, baited
## when false, left without a choice when null.
static func _game(accept: Variant = null, lost_in_a_row := 0) -> Game:
	var player := EventSamples.threatened_player()
	player.raid_state.lost_in_a_row = lost_in_a_row
	var game := Game.single_player(player)
	game.turn = 12
	if accept != null:
		var chosen: bool = accept
		ChooseEventAction.new(chosen).execute(game, player)
	return game


static func _raid_entries(game: Game) -> Array[RaidEntry]:
	var entries: Array[RaidEntry] = []
	for e: HistoryEntry in game.human_player().history_entries:
		if e is RaidEntry:
			entries.append(e as RaidEntry)
	return entries


func test_the_turn_result_carries_the_fight_against_the_predators() -> void:
	var game := _game(true)
	var result := TurnResolver.new().resolve(game, DartRandom.new(2))
	assert_not_null(result.predators)
	assert_eq(result.predators.turn, 12)
	assert_true(result.predators.surprise)
	assert_null(result.raid)
	var entries := _raid_entries(game)
	assert_eq(entries.size(), 1)
	assert_true(entries[0].surprise)


func test_losing_to_them_never_ends_the_game() -> void:
	var game := _game(true, 2)
	var result := TurnResolver.new().resolve(game, DartRandom.new(2))
	assert_false(result.predators.victory)
	assert_eq(game.status, GameStatus.Value.PLAYING)
	assert_eq(game.human_player().raid_state.lost_in_a_row, 2)


func test_no_fight_when_they_are_baited_or_left_without_a_choice() -> void:
	for accept: Variant in [false, null]:
		var game := _game(accept)
		var result := TurnResolver.new().resolve(game, DartRandom.new(2))
		assert_null(result.predators, str(accept))
		assert_true(_raid_entries(game).is_empty())
