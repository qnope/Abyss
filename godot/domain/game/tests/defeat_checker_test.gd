extends TestCase
## test/domain/game/defeat_checker_test.dart: the base falls after three
## raids lost in a row.

const Status := GameStatus.Value


func test_defeat_checker_nothing_changes_below_the_limit() -> void:
	assert_null(DefeatChecker.check(_game(2)))


func test_defeat_checker_three_raids_lost_in_a_row_end_the_game() -> void:
	assert_eq(DefeatChecker.check(_game(3)), Status.DEFEAT)


func test_defeat_checker_a_game_already_won_cannot_be_lost() -> void:
	assert_null(DefeatChecker.check(_game(3, Status.FREE_PLAY)))


func test_defeat_checker_the_last_chance_comes_after_two_raids_lost_in_a_row() -> void:
	assert_false(DefeatChecker.is_last_chance(_game(1)))
	assert_true(DefeatChecker.is_last_chance(_game(2)))
	assert_false(DefeatChecker.is_last_chance(_game(2, Status.FREE_PLAY)))


func _game(lost_in_a_row := 0, status := Status.PLAYING) -> Game:
	var player := Player.new("Human", "h")
	player.raid_state.lost_in_a_row = lost_in_a_row
	return GameSamples.game([player], status)
