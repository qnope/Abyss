extends TestCase
## test/domain/turn/turn_resolver_objective_test.dart: the objectives
## completed at the end of a turn.


func test_an_exploration_resolved_this_turn_completes_explore() -> void:
	var game := ObjectiveSamples.objective_game()
	game.human_player().pending_explorations.append(ExplorationOrder.new(GridPosition.new(0, 0)))

	var result := TurnResolver.new().resolve(game)

	assert_eq(result.objectives.size(), 1)
	var completion := result.objectives[0]
	assert_eq(completion.objective.id, ObjectiveId.Value.EXPLORE)
	assert_eq(completion.credited, {ResourceType.Value.CORAL: 30, ResourceType.Value.ORE: 20})
	assert_eq(game.human_player().saved_objective_state.completed, [ObjectiveId.Value.EXPLORE])


func test_the_summary_lists_nothing_once_the_objective_is_completed() -> void:
	var game := ObjectiveSamples.objective_game()
	ObjectiveSamples.set_building(game.human_player(), BuildingType.Value.HEADQUARTERS, 1)

	assert_eq(TurnResolver.new().resolve(game).objectives.size(), 1)
	assert_true(TurnResolver.new().resolve(game).objectives.is_empty())


func test_every_player_completes_its_objectives_the_human_summary_its_own() -> void:
	var game := ObjectiveSamples.objective_game()
	var bot := Player.new("Bot", "bot")
	game.players[bot.id] = bot
	ObjectiveSamples.set_building(bot, BuildingType.Value.ALGAE_FARM, 1)

	var result := TurnResolver.new().resolve(game)

	assert_true(result.objectives.is_empty())
	assert_eq(bot.saved_objective_state.completed, [ObjectiveId.Value.ALGAE_FARM])
	# Same start, and the farm makes no coral: the gap is the reward.
	assert_eq(
		bot.resources[ResourceType.Value.CORAL].amount,
		game.human_player().resources[ResourceType.Value.CORAL].amount + 30,
	)
