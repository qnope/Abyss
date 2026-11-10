extends TestCase
## test/domain/action/explore_action_execute_test.dart: what an exploration
## takes and orders.


func test_explore_action_execute_consumes_1_scout() -> void:
	var game := ActionSamples.explore_game(3)
	var player := game.human_player()
	assert_true(ExploreAction.new(2, 2).execute(game, player).is_success)
	assert_eq(player.units_on_level(1)[UnitType.Value.SCOUT].count, 2)


func test_explore_action_execute_adds_exploration_order_with_correct_target() -> void:
	var game := ActionSamples.explore_game()
	var player := game.human_player()
	ExploreAction.new(4, 3).execute(game, player)
	assert_eq(player.pending_explorations.size(), 1)
	var order := player.pending_explorations[0]
	assert_eq([order.target.x, order.target.y], [4, 3])


func test_explore_action_execute_multiple_executions_consume_scouts_and_add_orders() -> void:
	var game := ActionSamples.explore_game(3)
	var player := game.human_player()
	ExploreAction.new(2, 2).execute(game, player)
	ExploreAction.new(4, 4).execute(game, player)
	assert_eq(player.units_on_level(1)[UnitType.Value.SCOUT].count, 1)
	assert_eq(player.pending_explorations.size(), 2)
	assert_eq([player.pending_explorations[0].target.x, player.pending_explorations[0].target.y], [2, 2])
	assert_eq([player.pending_explorations[1].target.x, player.pending_explorations[1].target.y], [4, 4])


## Not in the Dart file: a refused exploration takes no scout, the noise of
## a scout is muffled by the research, and the description says where.
func test_an_exploration_is_noise_and_says_where() -> void:
	var game := ActionSamples.explore_game()
	assert_eq(ExploreAction.new(3, 3).execute(game, game.human_player()).reason, ActionFailure.Value.CELL_NOT_ELIGIBLE)
	assert_eq(game.human_player().units_on_level(1)[UnitType.Value.SCOUT].count, 3)
	var action := ExploreAction.new(4, 5)
	assert_eq(action.noise_made(game.human_player()), NoiseRules.PER_EXPLORATION)
	assert_eq([action.type(), action.description()], [ActionType.Value.EXPLORE, "Explorer (4, 5)"])
