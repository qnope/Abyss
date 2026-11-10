extends TestCase
## test/domain/game/victory_checker_test.dart and victory_winner_test.dart:
## who tamed the volcano.

const Status := GameStatus.Value


func test_victory_checker_returns_null_when_no_player_has_kernel_at_level_10() -> void:
	assert_null(VictoryChecker.check(_game(_player("h", 5))))


func test_victory_checker_returns_victory_when_human_kernel_is_level_10() -> void:
	assert_eq(VictoryChecker.check(_game(_player("h", 10))), Status.VICTORY)


func test_victory_checker_returns_defeat_when_non_human_kernel_is_level_10() -> void:
	var game := _game(_player("h", 3), [_player("e", 10)])
	assert_eq(VictoryChecker.check(game), Status.DEFEAT)


func test_victory_checker_returns_null_when_game_status_is_free_play() -> void:
	assert_null(VictoryChecker.check(_game(_player("h", 10), [], Status.FREE_PLAY)))


func test_victory_checker_returns_null_when_game_status_is_already_victory() -> void:
	assert_null(VictoryChecker.check(_game(_player("h", 10), [], Status.VICTORY)))


func test_victory_checker_returns_null_when_kernel_is_level_9() -> void:
	assert_null(VictoryChecker.check(_game(_player("h", 9))))


func test_the_winner_is_whoever_raised_the_kernel_to_level_10() -> void:
	var faction := _player("f", 10)
	assert_true(VictoryChecker.winner_of(_game(_player("h", 4), [faction])) == faction)


func test_nobody_wins_before_the_kernel_reaches_level_10() -> void:
	assert_null(VictoryChecker.winner_of(_game(_player("h", 9), [_player("f", 7)])))


## Not in the Dart files: a degraded kernel tames nothing, and a player
## without one never wins.
func test_a_degraded_or_missing_kernel_does_not_win() -> void:
	var degraded := GameSamples.player_with(
		"h", {BuildingType.Value.HEADQUARTERS: 1, BuildingType.Value.VOLCANIC_KERNEL: 10}
	)
	assert_null(VictoryChecker.winner_of(_game(degraded, [GameSamples.player_with("f", {})])))


func _player(id: String, kernel: int) -> Player:
	return GameSamples.player_with(id, {BuildingType.Value.VOLCANIC_KERNEL: kernel})


func _game(human: Player, others: Array[Player] = [], status := Status.PLAYING) -> Game:
	var players: Array[Player] = [human]
	players.append_array(others)
	return GameSamples.game(players, status)
