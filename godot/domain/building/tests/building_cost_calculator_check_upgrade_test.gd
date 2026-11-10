extends TestCase
## test/domain/building/building_cost_calculator_check_upgrade_test.dart:
## whether a building can go up a level, and what is missing.

const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const ENERGY := ResourceType.Value.ENERGY
const PEARL := ResourceType.Value.PEARL
const HQ := BuildingType.Value.HEADQUARTERS
const FARM := BuildingType.Value.ALGAE_FARM
const LABORATORY := BuildingType.Value.LABORATORY
const BARRACKS := BuildingType.Value.BARRACKS
const CITADEL := BuildingType.Value.CORAL_CITADEL


## The check of `type` at `level`, paid from `amounts`, among buildings at
## `levels`.
func _check(
	type: BuildingType.Value,
	level: int,
	amounts: Dictionary[ResourceType.Value, int],
	levels: Dictionary[BuildingType.Value, int],
) -> UpgradeCheck:
	return BuildingCostCalculator.new().check_upgrade(
		type, level, DomainSamples.resources(amounts), DomainSamples.buildings(levels)
	)


func test_check_upgrade_can_upgrade_when_resources_sufficient() -> void:
	var result := _check(HQ, 0, {CORAL: 100, ORE: 100}, {HQ: 0})
	assert_true(result.can_upgrade)
	assert_false(result.is_max_level)
	assert_eq(result.missing_resources, {})
	assert_eq(result.missing_prerequisites, {})


func test_check_upgrade_cannot_upgrade_when_coral_insufficient() -> void:
	var result := _check(HQ, 0, {CORAL: 10, ORE: 100}, {HQ: 0})
	assert_false(result.can_upgrade)
	assert_eq(result.missing_resources[CORAL], 50)


func test_check_upgrade_cannot_upgrade_when_ore_insufficient() -> void:
	var result := _check(HQ, 0, {CORAL: 100, ORE: 5}, {HQ: 0})
	assert_false(result.can_upgrade)
	assert_eq(result.missing_resources[ORE], 35)


func test_check_upgrade_cannot_upgrade_at_max_level_is_max_level_true() -> void:
	var result := _check(HQ, 10, {CORAL: 10000, ORE: 10000}, {HQ: 10})
	assert_false(result.can_upgrade)
	assert_true(result.is_max_level)


func test_check_upgrade_can_upgrade_false_when_both_resources_insufficient() -> void:
	var result := _check(HQ, 0, {CORAL: 0, ORE: 0}, {})
	assert_false(result.can_upgrade)
	assert_eq(result.missing_resources[CORAL], 60)
	assert_eq(result.missing_resources[ORE], 40)


func test_check_upgrade_cannot_upgrade_algae_farm_when_hq_prerequisite_not_met() -> void:
	var result := _check(FARM, 0, {CORAL: 100}, {HQ: 0, FARM: 0})
	assert_false(result.can_upgrade)
	assert_eq(result.missing_prerequisites[HQ], 1)


func test_check_upgrade_can_upgrade_algae_farm_when_hq_and_resources_sufficient() -> void:
	assert_true(_check(FARM, 0, {CORAL: 100}, {HQ: 1, FARM: 0}).can_upgrade)


func test_check_upgrade_cannot_upgrade_laboratory_when_hq_prerequisite_not_met() -> void:
	var result := _check(LABORATORY, 0, {CORAL: 100, ORE: 100}, {HQ: 1, LABORATORY: 0})
	assert_false(result.can_upgrade)
	assert_eq(result.missing_prerequisites[HQ], 2)


func test_check_upgrade_can_upgrade_laboratory_when_hq_and_resources_sufficient() -> void:
	assert_true(_check(LABORATORY, 0, {CORAL: 100, ORE: 100}, {HQ: 2, LABORATORY: 0}).can_upgrade)


func test_check_upgrade_cannot_upgrade_barracks_when_hq_prerequisite_not_met() -> void:
	var result := _check(BARRACKS, 0, {CORAL: 100, ORE: 100, ENERGY: 100}, {HQ: 1, BARRACKS: 0})
	assert_false(result.can_upgrade)
	assert_eq(result.missing_prerequisites[HQ], 2)


func test_check_upgrade_can_upgrade_barracks_when_hq_and_resources_sufficient() -> void:
	var result := _check(BARRACKS, 0, {CORAL: 100, ORE: 100, ENERGY: 100}, {HQ: 2, BARRACKS: 0})
	assert_true(result.can_upgrade)


func test_check_upgrade_cannot_upgrade_coral_citadel_when_pearls_insufficient() -> void:
	var result := _check(
		CITADEL, 0, {CORAL: 1000, ORE: 1000, ENERGY: 1000, PEARL: 2}, {HQ: 3, CITADEL: 0}
	)
	assert_false(result.can_upgrade)
	assert_eq(result.missing_resources[PEARL], 3)


func test_check_upgrade_cannot_upgrade_coral_citadel_when_hq_prerequisite_not_met() -> void:
	var result := _check(
		CITADEL, 0, {CORAL: 1000, ORE: 1000, ENERGY: 1000, PEARL: 100}, {HQ: 2, CITADEL: 0}
	)
	assert_false(result.can_upgrade)
	assert_eq(result.missing_prerequisites[HQ], 3)


func test_check_upgrade_can_upgrade_coral_citadel_when_hq_and_resources_sufficient() -> void:
	var result := _check(
		CITADEL, 0, {CORAL: 1000, ORE: 1000, ENERGY: 1000, PEARL: 100}, {HQ: 3, CITADEL: 0}
	)
	assert_true(result.can_upgrade)
	assert_eq(result.missing_resources, {})
	assert_eq(result.missing_prerequisites, {})


func test_check_upgrade_cannot_upgrade_coral_citadel_at_max_level_is_max_level_true() -> void:
	var result := _check(
		CITADEL, 5, {CORAL: 10000, ORE: 10000, ENERGY: 10000, PEARL: 1000}, {HQ: 10, CITADEL: 5}
	)
	assert_false(result.can_upgrade)
	assert_true(result.is_max_level)
