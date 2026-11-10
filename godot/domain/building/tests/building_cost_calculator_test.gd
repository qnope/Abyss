extends TestCase
## test/domain/building/building_cost_calculator_test.dart, its group
## upgradeCost. The other groups are in building_cost_calculator_levels_test.gd
## and building_cost_calculator_special_test.gd.

const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const ENERGY := ResourceType.Value.ENERGY
const HQ := BuildingType.Value.HEADQUARTERS
const FARM := BuildingType.Value.ALGAE_FARM
const MINE := BuildingType.Value.CORAL_MINE
const EXTRACTOR := BuildingType.Value.ORE_EXTRACTOR
const PANEL := BuildingType.Value.SOLAR_PANEL
const LABORATORY := BuildingType.Value.LABORATORY
const BARRACKS := BuildingType.Value.BARRACKS

var _calculator := BuildingCostCalculator.new()


func _cost(type: BuildingType.Value, level: int) -> Dictionary[ResourceType.Value, int]:
	return _calculator.upgrade_cost(type, level)


func test_upgrade_cost_hq_level_0_to_1_coral_60_ore_40() -> void:
	assert_eq(_cost(HQ, 0), {CORAL: 60, ORE: 40})


func test_upgrade_cost_hq_level_1_to_2_coral_96_ore_64() -> void:
	assert_eq(_cost(HQ, 1), {CORAL: 96, ORE: 64})


func test_upgrade_cost_hq_level_5_to_6_coral_629_ore_419() -> void:
	assert_eq(_cost(HQ, 5), {CORAL: 629, ORE: 419})


func test_upgrade_cost_hq_level_9_to_10_coral_4123_ore_2749() -> void:
	assert_eq(_cost(HQ, 9), {CORAL: 4123, ORE: 2749})


func test_upgrade_cost_hq_at_max_level_10_empty() -> void:
	assert_eq(_cost(HQ, 10), {})


func test_upgrade_cost_algae_farm_level_0_to_1_coral_80() -> void:
	assert_eq(_cost(FARM, 0), {CORAL: 80})


func test_upgrade_cost_algae_farm_level_2_to_3_coral_205() -> void:
	assert_eq(_cost(FARM, 2), {CORAL: 205})


func test_upgrade_cost_algae_farm_at_max_level_5_empty() -> void:
	assert_eq(_cost(FARM, 5), {})


func test_upgrade_cost_coral_mine_level_0_to_1_ore_60() -> void:
	assert_eq(_cost(MINE, 0), {ORE: 60})


func test_upgrade_cost_coral_mine_level_3_to_4_ore_246() -> void:
	assert_eq(_cost(MINE, 3), {ORE: 246})


func test_upgrade_cost_ore_extractor_level_0_to_1_coral_75_energy_45() -> void:
	assert_eq(_cost(EXTRACTOR, 0), {CORAL: 75, ENERGY: 45})


func test_upgrade_cost_ore_extractor_level_1_to_2_coral_120_energy_72() -> void:
	assert_eq(_cost(EXTRACTOR, 1), {CORAL: 120, ENERGY: 72})


func test_upgrade_cost_solar_panel_level_0_to_1_coral_60_ore_45() -> void:
	assert_eq(_cost(PANEL, 0), {CORAL: 60, ORE: 45})


func test_upgrade_cost_solar_panel_level_4_to_5_coral_393_ore_295() -> void:
	assert_eq(_cost(PANEL, 4), {CORAL: 393, ORE: 295})


func test_upgrade_cost_laboratory_level_0_to_1_coral_75_ore_60() -> void:
	assert_eq(_cost(LABORATORY, 0), {CORAL: 75, ORE: 60})


func test_upgrade_cost_laboratory_at_max_level_5_empty() -> void:
	assert_eq(_cost(LABORATORY, 5), {})


func test_upgrade_cost_barracks_level_0_to_1_coral_60_ore_75_energy_30() -> void:
	assert_eq(_cost(BARRACKS, 0), {CORAL: 60, ORE: 75, ENERGY: 30})
	assert_eq(_cost(BARRACKS, 0).keys(), [CORAL, ORE, ENERGY], "in the order of Dart")


func test_upgrade_cost_barracks_at_max_level_5_empty() -> void:
	assert_eq(_cost(BARRACKS, 5), {})


func test_upgrade_cost_every_level_costs_1_6_times_the_previous_one() -> void:
	for level: int in range(1, 5):
		var previous := _cost(MINE, level - 1)
		var cost := _cost(MINE, level)
		assert_almost_eq(DartMath.quotient(cost[ORE], previous[ORE]), 1.6, 0.02)
