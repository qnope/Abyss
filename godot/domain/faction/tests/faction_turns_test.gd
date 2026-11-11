extends TestCase
## Not in the Dart files: FactionTurns, which the Dart tests reach through
## the end of a turn (`faction_play_test.dart`, waiting for `turn`): a fallen
## faction and a game over play nothing.


static func _game() -> Game:
	var game := GameFactory.new_game("Nemo", 7, Difficulty.Value.NORMAL, false, 2, null, "human")
	game.turn = 1
	return game


func test_every_standing_faction_plays_its_turn() -> void:
	var game := _game()
	var spy := FactionDigests.Spy.new()

	FactionTurns.play_all(game, spy)

	assert_eq(spy.seen.size(), 2, "each faction raises its headquarters")


func test_a_fallen_faction_plays_nothing() -> void:
	var game := _game()
	game.players[game.factions()[0].id()].saved_fallen = true
	var spy := FactionDigests.Spy.new()

	FactionTurns.play_all(game, spy)

	assert_eq(spy.seen.size(), 1)


func test_nothing_is_played_once_the_game_is_over() -> void:
	var game := _game()
	game.status = GameStatus.Value.DEFEAT
	var spy := FactionDigests.Spy.new()

	FactionTurns.play_all(game, spy)

	assert_eq(spy.seen.size(), 0)
	FactionTurns.play_all(_game())
