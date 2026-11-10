extends TestCase
## test/domain/building/building_cost_calculator_test.dart, its groups
## maxLevel and requiresCapturedKernel.

var _calculator := BuildingCostCalculator.new()


func test_max_level_hq_is_10() -> void:
	assert_eq(_calculator.max_level(BuildingType.Value.HEADQUARTERS), 10)


func test_max_level_algae_farm_is_5() -> void:
	assert_eq(_calculator.max_level(BuildingType.Value.ALGAE_FARM), 5)


func test_max_level_coral_mine_is_5() -> void:
	assert_eq(_calculator.max_level(BuildingType.Value.CORAL_MINE), 5)


func test_max_level_ore_extractor_is_5() -> void:
	assert_eq(_calculator.max_level(BuildingType.Value.ORE_EXTRACTOR), 5)


func test_max_level_solar_panel_is_5() -> void:
	assert_eq(_calculator.max_level(BuildingType.Value.SOLAR_PANEL), 5)


func test_max_level_laboratory_is_5() -> void:
	assert_eq(_calculator.max_level(BuildingType.Value.LABORATORY), 5)


func test_max_level_barracks_is_5() -> void:
	assert_eq(_calculator.max_level(BuildingType.Value.BARRACKS), 5)


func test_max_level_coral_citadel_is_5() -> void:
	assert_eq(_calculator.max_level(BuildingType.Value.CORAL_CITADEL), 5)


func test_max_level_descent_module_is_1() -> void:
	assert_eq(_calculator.max_level(BuildingType.Value.DESCENT_MODULE), 1)


func test_max_level_pressure_capsule_is_1() -> void:
	assert_eq(_calculator.max_level(BuildingType.Value.PRESSURE_CAPSULE), 1)


func test_max_level_volcanic_kernel_is_10() -> void:
	assert_eq(_calculator.max_level(BuildingType.Value.VOLCANIC_KERNEL), 10)


func test_requires_captured_kernel_true_for_volcanic_kernel() -> void:
	assert_true(_calculator.requires_captured_kernel(BuildingType.Value.VOLCANIC_KERNEL))


func test_requires_captured_kernel_false_for_headquarters() -> void:
	assert_false(_calculator.requires_captured_kernel(BuildingType.Value.HEADQUARTERS))
