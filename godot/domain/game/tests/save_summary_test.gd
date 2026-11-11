extends TestCase
## test/domain/game/save_summary_test.dart, the tests of SaveOutcome
## included.

const Status := GameStatus.Value
const Outcome := SaveOutcome.Value


static func _map(cell: MapCell = null) -> GameMap:
	var cells: Array[MapCell] = [cell if cell != null else MapCell.new(TerrainType.Value.PLAIN)]
	return GameMap.new(1, 1, cells, 1)


static func _game(status := Status.PLAYING, levels: Dictionary[int, GameMap] = {}) -> Game:
	var player := Player.new("Nemo", "nemo")
	return Game.new(
		player.id, {player.id: player}, 12, DateSamples.at(2026, 3, 1), levels, status, null, Difficulty.Value.HARD,
	)


func test_sums_up_who_plays_which_turn_and_at_which_difficulty() -> void:
	var summary := SaveSummary.of(_game())
	assert_eq(summary.player_name, "Nemo")
	assert_eq(summary.turn, 12)
	assert_eq(summary.difficulty, Difficulty.Value.HARD)


func test_a_lost_game_shows_the_turn_its_base_fell_on() -> void:
	assert_eq(SaveSummary.of(_game(Status.DEFEAT)).turn, 11)


func test_a_won_game_shows_its_current_turn() -> void:
	assert_eq(SaveSummary.of(_game(Status.VICTORY)).turn, 12)


func test_sorts_each_status_into_its_outcome() -> void:
	assert_eq(SaveSummary.of(_game(Status.PLAYING)).outcome, Outcome.IN_PROGRESS)
	assert_eq(SaveSummary.of(_game(Status.VICTORY)).outcome, Outcome.VICTORY)
	assert_eq(SaveSummary.of(_game(Status.FREE_PLAY)).outcome, Outcome.FREE_PLAY)
	assert_eq(SaveSummary.of(_game(Status.DEFEAT)).outcome, Outcome.DEFEAT)


func test_only_a_won_or_lost_game_is_finished() -> void:
	assert_false(SaveOutcome.is_finished(Outcome.IN_PROGRESS))
	assert_false(SaveOutcome.is_finished(Outcome.FREE_PLAY))
	assert_true(SaveOutcome.is_finished(Outcome.VICTORY))
	assert_true(SaveOutcome.is_finished(Outcome.DEFEAT))


func test_a_game_in_free_play_has_been_won() -> void:
	assert_false(SaveOutcome.is_won(Outcome.IN_PROGRESS))
	assert_true(SaveOutcome.is_won(Outcome.FREE_PLAY))
	assert_true(SaveOutcome.is_won(Outcome.VICTORY))
	assert_false(SaveOutcome.is_won(Outcome.DEFEAT))


## Not in the Dart file: the names of the outcomes, in the Dart order.
func test_the_outcomes_in_the_dart_order() -> void:
	assert_eq(DartEnum.names(Outcome), PackedStringArray(["inProgress", "freePlay", "victory", "defeat"]))


func test_the_deepest_level_is_the_deepest_map_generated() -> void:
	var game := _game(Status.PLAYING, {1: _map(), 3: _map(), 2: _map()})
	assert_eq(SaveSummary.of(game).deepest_level, 3)


func test_a_game_without_any_map_is_still_at_the_surface() -> void:
	assert_eq(SaveSummary.of(_game()).deepest_level, 1)


func test_gives_the_headquarters_level() -> void:
	var game := _game()
	game.human_player().buildings[BuildingType.Value.HEADQUARTERS].level = 4
	assert_eq(SaveSummary.of(game).headquarters_level, 4)


func test_a_player_without_headquarters_is_at_level_0() -> void:
	var game := _game()
	game.human_player().buildings.erase(BuildingType.Value.HEADQUARTERS)
	assert_eq(SaveSummary.of(game).headquarters_level, 0)


func test_gives_every_resource_amount_in_the_resource_order() -> void:
	var game := _game()
	var stocks := game.human_player().resources
	stocks[ResourceType.Value.PEARL].amount = 42
	stocks.erase(ResourceType.Value.ENERGY)
	var resources := SaveSummary.of(game).resources
	assert_eq(resources.keys(), ResourceType.Value.values())
	assert_eq(resources[ResourceType.Value.PEARL], 42)
	assert_eq(resources[ResourceType.Value.ENERGY], 0)
	assert_eq(resources[ResourceType.Value.ALGAE], stocks[ResourceType.Value.ALGAE].amount)
	assert_true(resources.is_read_only())


func test_gives_when_the_game_was_last_played() -> void:
	var game := _game()
	game.saved_last_played_at = DateSamples.at(2026, 4, 2, 9)
	assert_eq(SaveSummary.of(game).last_played_at, DateSamples.at(2026, 4, 2, 9))


func test_tells_whether_the_player_conquered_the_volcanic_kernel() -> void:
	assert_true(_captured_with("nemo"))
	assert_false(_captured_with("rival"))
	assert_false(_captured_with(null))
	assert_false(SaveSummary.of(_game()).volcanic_kernel_captured)


## `by`: who collected the kernel, a String or null.
static func _captured_with(by: Variant) -> bool:
	var kernel := MapCell.new(TerrainType.Value.PLAIN, CellContentType.Value.VOLCANIC_KERNEL, null, by)
	return SaveSummary.of(_game(Status.PLAYING, {1: _map(), 3: _map(kernel)})).volcanic_kernel_captured
