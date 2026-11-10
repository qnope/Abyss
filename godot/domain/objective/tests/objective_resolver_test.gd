extends TestCase
## test/domain/objective/objective_resolver_test.dart: the objectives met at
## the end of a turn, completed and paid once.

const Id := ObjectiveId.Value
const Type := BuildingType.Value
const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE


func test_objective_resolver_nothing_met_nothing_completed_nor_credited() -> void:
	var game := ObjectiveSamples.objective_game()
	var coral := _amount(game, CORAL)
	assert_true(ObjectiveResolver.resolve(game, game.human_player()).is_empty())
	assert_eq(_amount(game, CORAL), coral)


func test_objective_resolver_an_objective_met_is_completed_and_its_reward_credited_once() -> void:
	var game := ObjectiveSamples.objective_game()
	var coral := _amount(game, CORAL)
	var ore := _amount(game, ORE)
	ObjectiveSamples.set_building(game.human_player(), Type.HEADQUARTERS, 1)
	var completions := ObjectiveResolver.resolve(game, game.human_player())
	assert_eq(completions.size(), 1)
	assert_eq(completions[0].objective.id, Id.HQ_LEVEL_1)
	assert_eq(completions[0].credited, {CORAL: 30, ORE: 20})
	assert_eq(_amount(game, CORAL), coral + 30)
	assert_eq(_amount(game, ORE), ore + 20)
	assert_eq(game.human_player().saved_objective_state.completed, [Id.HQ_LEVEL_1] as Array[Id])
	assert_eq(_resolve(game), [])
	assert_eq(_amount(game, CORAL), coral + 30)


func test_objective_resolver_several_objectives_met_together_complete_in_catalog_order() -> void:
	var game := ObjectiveSamples.objective_game()
	var coral := _amount(game, CORAL)
	ObjectiveSamples.set_building(game.human_player(), Type.ALGAE_FARM, 1)
	ObjectiveSamples.set_building(game.human_player(), Type.HEADQUARTERS, 2)
	assert_eq(_resolve(game), [Id.HQ_LEVEL_1, Id.ALGAE_FARM, Id.HQ_LEVEL_2])
	assert_eq(_amount(game, CORAL), coral + 90)


func test_objective_resolver_a_completion_stays_when_its_progress_drops_never_paid_again() -> void:
	var game := ObjectiveSamples.objective_game()
	var player := game.human_player()
	ObjectiveSamples.set_building(player, Type.BARRACKS, 1)
	RaidSamples.set_units(player, UnitType.Value.SCOUT, 2)
	assert_eq(_resolve(game), [Id.BARRACKS_AND_SCOUTS])
	var coral := _amount(game, CORAL)
	RaidSamples.set_units(player, UnitType.Value.SCOUT, 1)
	assert_eq(_resolve(game), [])
	RaidSamples.set_units(player, UnitType.Value.SCOUT, 2)
	assert_eq(_resolve(game), [])
	assert_true(player.saved_objective_state.is_completed(Id.BARRACKS_AND_SCOUTS))
	assert_eq(_amount(game, CORAL), coral)


func test_objective_resolver_the_reward_stops_at_the_storage_cap() -> void:
	var game := ObjectiveSamples.objective_game()
	var coral := game.human_player().resources[CORAL]
	coral.amount = coral.max_storage - 10
	ObjectiveSamples.set_building(game.human_player(), Type.HEADQUARTERS, 1)
	var completion := ObjectiveResolver.resolve(game, game.human_player())
	assert_eq(coral.amount, coral.max_storage)
	assert_eq(completion[0].credited[CORAL], 10)
	assert_eq(completion[0].credited[ORE], 20)


func test_objective_resolver_a_player_saved_before_the_objectives_is_migrated_not_paid() -> void:
	var game := ObjectiveSamples.objective_game()
	var player := game.human_player()
	player.saved_objective_state = null
	ObjectiveSamples.set_building(player, Type.HEADQUARTERS, 1)
	var coral := _amount(game, CORAL)
	assert_eq(_resolve(game), [])
	assert_eq(player.saved_objective_state.completed, [Id.HQ_LEVEL_1] as Array[Id])
	assert_eq(_amount(game, CORAL), coral)


func _amount(game: Game, type: ResourceType.Value) -> int:
	return game.human_player().resources[type].amount


func _resolve(game: Game) -> Array:
	var ids: Array = []
	for completion: ObjectiveCompletion in ObjectiveResolver.resolve(game, game.human_player()):
		ids.append(completion.objective.id)
	return ids
