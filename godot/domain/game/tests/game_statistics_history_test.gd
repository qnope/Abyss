extends TestCase
## test/domain/game/game_statistics_history_test.dart: the statistics a
## game reads from the history.

const PLAYER := CombatSide.Value.PLAYER

var _calculator := GameStatisticsCalculator.new()


func _resources(game: Game) -> int:
	var total := 0
	for stock: GameResource in game.human_player().resources.values():
		total += stock.amount
	return total


func test_game_statistics_calculator_history_capture_entries_are_counted() -> void:
	var game := HistorySamples.statistics_game(1, [
		CaptureEntry.new(1, "Base A", HistorySamples.statistics_fight(PLAYER, 2)),
		CaptureEntry.new(2, "Base B", HistorySamples.statistics_fight(PLAYER, 1)),
	])
	assert_eq(_calculator.compute(game).bases_captured, 2)


func test_game_statistics_calculator_history_a_victory_where_the_admiral_fell_captures_nothing() -> void:
	var game := HistorySamples.statistics_game(1, [
		CaptureEntry.new(1, "Base A", HistorySamples.statistics_fight(PLAYER, 2), false),
	])
	assert_eq(_calculator.compute(game).bases_captured, 0)


func test_game_statistics_calculator_history_collect_entries_sum_resources() -> void:
	var game := HistorySamples.statistics_game(1, [
		CollectEntry.new(1, 0, 0, {ResourceType.Value.ALGAE: 10, ResourceType.Value.CORAL: 5}),
		CollectEntry.new(2, 1, 1, {ResourceType.Value.ORE: 20}),
	])
	# 10 + 5 + 20 from history + current resources from defaults
	assert_eq(_calculator.compute(game).total_resources_collected, 35 + _resources(game))


func test_game_statistics_calculator_history_mixed_history_computes_all_fields() -> void:
	var game := HistorySamples.statistics_game(12, [
		HistorySamples.statistics_combat(true, 3),
		HistorySamples.statistics_combat(false, 2),
		CaptureEntry.new(5, "X", HistorySamples.statistics_fight(PLAYER, 1)),
		CollectEntry.new(6, 0, 0, {ResourceType.Value.ENERGY: 7}),
	])
	var stats := _calculator.compute(game)
	assert_eq([stats.turns_played, stats.monsters_defeated, stats.bases_captured], [12, 3, 1])
	assert_eq(stats.total_resources_collected, 7 + _resources(game))
