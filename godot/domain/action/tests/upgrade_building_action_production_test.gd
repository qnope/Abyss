extends TestCase
## test/domain/action/upgrade_building_action_production_test.dart:
## upgrading the buildings that produce.

const HQ := BuildingType.Value.HEADQUARTERS
const FARM := BuildingType.Value.ALGAE_FARM


func _scenario(hq_level := 1, farm_level := 0) -> Player:
	return ActionSamples.stocked(
		ActionSamples.amounts(200, 400, 200, 200, 5),
		{
			HQ: hq_level, FARM: farm_level, BuildingType.Value.CORAL_MINE: 0,
			BuildingType.Value.ORE_EXTRACTOR: 0, BuildingType.Value.SOLAR_PANEL: 0,
		},
	)


func _upgrade(player: Player, type := FARM) -> ActionResult:
	return UpgradeBuildingAction.new(type).execute(ActionSamples.game_of(player), player)


func test_validate_succeeds_for_algae_farm_with_sufficient_resources_and_hq() -> void:
	var player := _scenario()
	assert_true(UpgradeBuildingAction.new(FARM).validate(ActionSamples.game_of(player), player).is_success)


func test_validate_fails_for_algae_farm_when_hq_level_too_low() -> void:
	var player := _scenario(0)
	var result := UpgradeBuildingAction.new(FARM).validate(ActionSamples.game_of(player), player)
	assert_false(result.is_success)
	assert_not_null(result.reason)


func test_execute_algae_farm_deducts_coral_and_increments_level() -> void:
	var player := _scenario()
	_upgrade(player)
	assert_eq(player.resources[ResourceType.Value.CORAL].amount, 320)
	assert_eq(player.buildings[FARM].level, 1)


func test_execute_algae_farm_increases_production_via_calculator() -> void:
	var player := _scenario()
	_upgrade(player)
	assert_eq(ProductionCalculator.from_buildings(player.buildings)[ResourceType.Value.ALGAE], 50)


func test_execute_algae_farm_twice_cumulates_production() -> void:
	var player := _scenario(2)
	_upgrade(player)
	player.worksite.clear()
	_upgrade(player)
	assert_eq(ProductionCalculator.from_buildings(player.buildings)[ResourceType.Value.ALGAE], 140)


func test_execute_hq_does_not_affect_production() -> void:
	var player := _scenario()
	var before := ProductionCalculator.from_buildings(player.buildings)
	_upgrade(player, HQ)
	assert_eq(ProductionCalculator.from_buildings(player.buildings), before)


func test_validate_fails_for_algae_farm_at_max_level_5() -> void:
	var player := _scenario(1, 5)
	var result := UpgradeBuildingAction.new(FARM).validate(ActionSamples.game_of(player), player)
	assert_false(result.is_success)
	assert_not_null(result.reason)
