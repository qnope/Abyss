extends TestCase
## test/domain/game/game_last_played_test.dart.


func _build_game() -> Game:
	var player := Player.new("A", "a")
	return Game.new(player.id, {player.id: player}, 1, DateSamples.at(2026, 3, 15, 14, 30))


func test_a_game_never_saved_was_last_played_when_it_was_created() -> void:
	var game := _build_game()
	assert_null(game.saved_last_played_at)
	assert_eq(game.last_played_at(), DateSamples.at(2026, 3, 15, 14, 30))


func test_a_stamped_game_was_last_played_at_the_stamp() -> void:
	var game := _build_game()
	game.saved_last_played_at = DateSamples.at(2026, 4, 1, 8, 5)
	assert_eq(game.last_played_at(), DateSamples.at(2026, 4, 1, 8, 5))


func test_the_last_play_can_be_given_when_building_the_game() -> void:
	var player := Player.new("A", "a")
	var game := Game.new(
		player.id, {player.id: player}, 1, null, {}, GameStatus.Value.PLAYING, null, Difficulty.Value.NORMAL,
		DateSamples.at(2026, 5, 2),
	)
	assert_eq(game.last_played_at(), DateSamples.at(2026, 5, 2))
