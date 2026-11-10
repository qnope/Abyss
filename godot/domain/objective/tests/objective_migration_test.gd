extends TestCase
## test/domain/objective/objective_migration_test.dart: a player saved
## before the objectives, `saved_objective_state` null, which no Godot save
## holds but a test can set.

const Id := ObjectiveId.Value
const Type := BuildingType.Value


func test_objective_migration_an_old_save_gets_the_objectives_already_met_in_catalog_order() -> void:
	var game := _legacy_game()
	var state := ObjectiveMigration.legacy_state(game, game.human_player())
	assert_eq(state.completed, [Id.HQ_LEVEL_1, Id.ALGAE_FARM, Id.HQ_LEVEL_2] as Array[Id])
	assert_false(state.tutorial_enabled)
	assert_false(state.tips_enabled)


func test_objective_migration_the_legacy_state_is_computed_without_touching_the_game() -> void:
	var game := _legacy_game()
	ObjectiveMigration.legacy_state(game, game.human_player())
	assert_null(game.human_player().saved_objective_state)


func test_objective_migration_migrate_fills_the_missing_state_without_paying_any_reward() -> void:
	var game := _legacy_game()
	var coral := game.human_player().resources[ResourceType.Value.CORAL].amount
	ObjectiveMigration.migrate(game)
	var state := game.human_player().saved_objective_state
	assert_eq(state.completed.size(), 3)
	assert_false(state.tutorial_enabled)
	assert_eq(game.human_player().resources[ResourceType.Value.CORAL].amount, coral)


func test_objective_migration_migrate_leaves_a_state_already_saved_untouched() -> void:
	var game := ObjectiveSamples.objective_game()
	var saved := ObjectiveState.new([], true)
	game.human_player().saved_objective_state = saved
	ObjectiveSamples.set_building(game.human_player(), Type.HEADQUARTERS, 1)
	ObjectiveMigration.migrate(game)
	assert_true(game.human_player().saved_objective_state == saved)
	assert_true(saved.completed.is_empty())
	assert_true(saved.tutorial_enabled)


func test_objective_migration_state_of_migrates_a_missing_state_once_then_returns_it() -> void:
	var game := _legacy_game()
	var state := ObjectiveMigration.state_of(game, game.human_player())
	assert_true(game.human_player().saved_objective_state == state)
	assert_true(ObjectiveMigration.state_of(game, game.human_player()) == state)


## `_legacyGame`: a player saved before the objectives, no state, the first
## buildings up.
func _legacy_game() -> Game:
	var game := ObjectiveSamples.objective_game()
	var player := game.human_player()
	player.saved_objective_state = null
	ObjectiveSamples.set_building(player, Type.ALGAE_FARM, 1)
	ObjectiveSamples.set_building(player, Type.HEADQUARTERS, 2)
	return game
