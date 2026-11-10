extends TestCase
## test/domain/action/upgrade_building_action_test.dart: upgrading a
## building of the base.

const HQ := BuildingType.Value.HEADQUARTERS

var action: UpgradeBuildingAction


func before_each() -> void:
	action = UpgradeBuildingAction.new(HQ)


func _scenario(coral := 80, ore := 50, level := 0) -> Player:
	return ActionSamples.stocked(ActionSamples.amounts(100, coral, ore, 60, 5), {HQ: level})


func test_properties_type_returns_action_type_upgrade_building() -> void:
	assert_eq(action.type(), ActionType.Value.UPGRADE_BUILDING)


func test_properties_building_type_is_correctly_stored() -> void:
	assert_eq(action.building_type, HQ)


func test_properties_description_returns_a_readable_string() -> void:
	assert_true(action.description().contains("headquarters"))


func test_validate_returns_success_when_resources_sufficient() -> void:
	var player := _scenario()
	assert_true(action.validate(ActionSamples.game_of(player), player).is_success)


func test_validate_returns_failure_when_resources_insufficient() -> void:
	var player := _scenario(10, 5)
	var result := action.validate(ActionSamples.game_of(player), player)
	assert_false(result.is_success)
	assert_not_null(result.reason)


func test_validate_a_building_the_base_does_not_have_cannot_be_upgraded() -> void:
	var player := _scenario()
	var result := UpgradeBuildingAction.new(BuildingType.Value.LABORATORY).execute(
		ActionSamples.game_of(player), player
	)
	assert_eq(result.reason, ActionFailure.Value.BUILDING_NOT_FOUND)
	assert_eq(player.resources[ResourceType.Value.CORAL].amount, 80)
	assert_false(player.buildings.has(BuildingType.Value.LABORATORY))


func test_validate_returns_failure_when_building_at_max_level() -> void:
	var player := _scenario(80, 50, 10)
	var result := action.validate(ActionSamples.game_of(player), player)
	assert_false(result.is_success)
	assert_not_null(result.reason)


func test_execute_deducts_resources_and_increments_level() -> void:
	var player := _scenario()
	assert_true(action.execute(ActionSamples.game_of(player), player).is_success)
	assert_eq(player.resources[ResourceType.Value.CORAL].amount, 20)
	assert_eq(player.resources[ResourceType.Value.ORE].amount, 10)
	assert_eq(player.buildings[HQ].level, 1)


func test_execute_returns_failure_without_modifying_when_resources_insufficient() -> void:
	var player := _scenario(10, 5)
	assert_false(action.execute(ActionSamples.game_of(player), player).is_success)
	assert_eq(player.resources[ResourceType.Value.CORAL].amount, 10)
	assert_eq(player.resources[ResourceType.Value.ORE].amount, 5)
	assert_eq(player.buildings[HQ].level, 0)


func test_execute_returns_failure_without_modifying_when_at_max_level() -> void:
	var player := _scenario(80, 50, 10)
	assert_false(action.execute(ActionSamples.game_of(player), player).is_success)
	assert_eq(player.buildings[HQ].level, 10)


## Not in the Dart file: the busy sites refuse first, and the noise of an
## upgrade is that of the level reached.
func test_busy_sites_refuse_and_the_noise_is_of_the_level_reached() -> void:
	var player := _scenario(80, 50, 3)
	player.worksite.upgrades = 1
	assert_eq(action.validate(ActionSamples.game_of(player), player).reason, ActionFailure.Value.WORKSITES_BUSY)
	assert_eq(action.description(), "Ameliorer BuildingType.headquarters")
	assert_eq(action.noise_made(player), NoiseRules.for_upgrade(HQ, 3))
