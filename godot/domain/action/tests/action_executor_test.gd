extends TestCase
## test/domain/action/action_executor_test.dart: the executor on an upgrade
## of the headquarters.

const HQ := BuildingType.Value.HEADQUARTERS

var executor: ActionExecutor
var action: UpgradeBuildingAction


func before_each() -> void:
	executor = ActionExecutor.new()
	action = UpgradeBuildingAction.new(HQ)


func _scenario(coral := 80, ore := 50, hq_level := 0) -> Player:
	return ActionSamples.stocked(ActionSamples.amounts(100, coral, ore, 60, 5), {HQ: hq_level})


func _amount(player: Player, type: ResourceType.Value) -> int:
	return player.resources[type].amount


func test_action_executor_execute_valid_upgrade_building_action_deducts_resources_and_levels_up() -> void:
	var player := _scenario()
	assert_true(executor.execute(action, ActionSamples.game_of(player), player).is_success)
	assert_eq([_amount(player, ActionSamples.CORAL), _amount(player, ActionSamples.ORE)], [20, 10])
	assert_eq(player.buildings[HQ].level, 1)


func test_action_executor_execute_with_insufficient_resources_returns_failure() -> void:
	var player := _scenario(10, 5)
	var result := executor.execute(action, ActionSamples.game_of(player), player)
	assert_false(result.is_success)
	assert_not_null(result.reason)
	assert_eq([_amount(player, ActionSamples.CORAL), _amount(player, ActionSamples.ORE)], [10, 5])
	assert_eq(player.buildings[HQ].level, 0)


func test_action_executor_execute_at_max_level_returns_failure() -> void:
	var player := _scenario(80, 50, 10)
	var result := executor.execute(action, ActionSamples.game_of(player), player)
	assert_false(result.is_success)
	assert_not_null(result.reason)
	assert_eq(player.buildings[HQ].level, 10)
	assert_eq([_amount(player, ActionSamples.CORAL), _amount(player, ActionSamples.ORE)], [80, 50])


func test_integration_full_flow_create_action_execute_verify_state() -> void:
	var player := _scenario()
	assert_true(executor.execute(UpgradeBuildingAction.new(HQ), ActionSamples.game_of(player), player).is_success)
	assert_eq([_amount(player, ActionSamples.CORAL), _amount(player, ActionSamples.ORE)], [20, 10])
	assert_eq(player.buildings[HQ].level, 1)
	assert_eq(_amount(player, ActionSamples.ALGAE), 100)
	assert_eq(_amount(player, ActionSamples.ENERGY), 60)
	assert_eq(_amount(player, ActionSamples.PEARL), 5)


func test_integration_full_flow_same_action_on_identical_scenarios_produces_identical_outcomes() -> void:
	var a := _scenario()
	var b := _scenario()
	var result_a := executor.execute(action, ActionSamples.game_of(a), a)
	var result_b := executor.execute(action, ActionSamples.game_of(b), b)
	assert_eq(result_a.is_success, result_b.is_success)
	for type: ResourceType.Value in ResourceType.Value.values():
		assert_eq(_amount(a, type), _amount(b, type))
	assert_eq(a.buildings[HQ].level, b.buildings[HQ].level)
