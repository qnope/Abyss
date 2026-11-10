extends TestCase
## test/domain/game/game_statistics_calculator_test.dart: the statistics of
## a game.

var _calculator := GameStatisticsCalculator.new()


func test_game_statistics_calculator_empty_history_returns_zeroes_and_turns_played() -> void:
	var stats := _calculator.compute(HistorySamples.statistics_game(7))
	assert_eq([stats.turns_played, stats.monsters_defeated, stats.bases_captured], [7, 0, 0])


func test_game_statistics_calculator_a_lost_game_counts_the_turn_the_base_fell_on_as_the_last() -> void:
	var game := HistorySamples.statistics_game(28)
	game.status = GameStatus.Value.DEFEAT
	assert_eq(_calculator.compute(game).turns_played, 27)


func test_game_statistics_calculator_raid_outcomes_come_from_the_raid_state() -> void:
	var game := HistorySamples.statistics_game()
	var raids := game.human_player().raid_state
	raids.record_outcome(true)
	raids.record_outcome(false)
	raids.record_outcome(false)
	var stats := _calculator.compute(game)
	assert_eq([stats.raids_repelled, stats.raids_lost], [1, 2])


func test_game_statistics_calculator_combat_victories_count_initial_monsters() -> void:
	var game := HistorySamples.statistics_game(1, [
		HistorySamples.statistics_combat(true, 5), HistorySamples.statistics_combat(true, 3)
	])
	assert_eq(_calculator.compute(game).monsters_defeated, 8)


func test_game_statistics_calculator_combat_defeats_do_not_count_monsters() -> void:
	var game := HistorySamples.statistics_game(1, [HistorySamples.statistics_combat(false, 4)])
	assert_eq(_calculator.compute(game).monsters_defeated, 0)


## Not in the Dart file: the history of the player given, the raids of the
## human.
func test_reads_the_history_of_the_player_given_and_the_raids_of_the_human() -> void:
	var game := HistorySamples.statistics_game()
	var rival := GameSamples.player("rival")
	rival.add_history_entry(HistorySamples.statistics_combat(true, 6))
	rival.raid_state.record_outcome(true)
	game.players[rival.id] = rival
	var stats := _calculator.compute(game, rival)
	assert_eq([stats.monsters_defeated, stats.raids_repelled], [6, 0])
