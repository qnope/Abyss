extends TestCase
## test/domain/objective/current_objective_test.dart: the objective a player
## is on.

const Id := ObjectiveId.Value


func test_current_objective_of_is_the_first_objective_of_a_new_game() -> void:
	var game := ObjectiveSamples.objective_game()
	assert_eq(CurrentObjective.of(game, game.human_player()).id, Id.HQ_LEVEL_1)


func test_current_objective_of_is_the_first_objective_not_completed_met_or_not() -> void:
	var game := ObjectiveSamples.objective_game()
	game.human_player().saved_objective_state = ObjectiveState.new([Id.HQ_LEVEL_1, Id.MINES])
	ObjectiveSamples.set_building(game.human_player(), BuildingType.Value.ALGAE_FARM, 1)
	assert_eq(CurrentObjective.of(game, game.human_player()).id, Id.ALGAE_FARM)


func test_current_objective_of_is_null_once_every_objective_is_completed() -> void:
	var game := ObjectiveSamples.objective_game()
	var every: Array[Id] = []
	every.assign(Id.values())
	game.human_player().saved_objective_state = ObjectiveState.new(every)
	assert_null(CurrentObjective.of(game, game.human_player()))
