extends TestCase
## test/domain/building/building_cost_calculator_test.dart, its groups
## coralCitadel, descentModule, pressureCapsule, volcanicKernel and
## checkUpgrade volcanicKernel.

const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const ENERGY := ResourceType.Value.ENERGY
const PEARL := ResourceType.Value.PEARL
const HQ := BuildingType.Value.HEADQUARTERS
const CITADEL := BuildingType.Value.CORAL_CITADEL
const MODULE := BuildingType.Value.DESCENT_MODULE
const CAPSULE := BuildingType.Value.PRESSURE_CAPSULE
const KERNEL := BuildingType.Value.VOLCANIC_KERNEL

var _calculator := BuildingCostCalculator.new()


func _cost(type: BuildingType.Value, level: int) -> Dictionary[ResourceType.Value, int]:
	return _calculator.upgrade_cost(type, level)


func _check_kernel(hq: int, captured: bool) -> UpgradeCheck:
	var abundant := DomainSamples.resources({CORAL: 99999, ORE: 99999, ENERGY: 99999, PEARL: 99999})
	return _calculator.check_upgrade(
		KERNEL, 0, abundant, DomainSamples.buildings({HQ: hq}), {}, captured
	)


func test_coral_citadel_level_0_to_1_coral_250_ore_250_energy_125_pearl_5() -> void:
	assert_eq(_cost(CITADEL, 0), {CORAL: 250, ORE: 250, ENERGY: 125, PEARL: 5})


func test_coral_citadel_level_1_to_2_coral_400_ore_400_energy_200_pearl_10() -> void:
	assert_eq(_cost(CITADEL, 1), {CORAL: 400, ORE: 400, ENERGY: 200, PEARL: 10})


func test_coral_citadel_level_2_to_3_coral_640_ore_640_energy_320_pearl_20() -> void:
	assert_eq(_cost(CITADEL, 2), {CORAL: 640, ORE: 640, ENERGY: 320, PEARL: 20})


func test_coral_citadel_level_3_to_4_coral_1024_ore_1024_energy_512_pearl_35() -> void:
	assert_eq(_cost(CITADEL, 3), {CORAL: 1024, ORE: 1024, ENERGY: 512, PEARL: 35})


func test_coral_citadel_level_4_to_5_coral_1638_ore_1638_energy_819_pearl_60() -> void:
	assert_eq(_cost(CITADEL, 4), {CORAL: 1638, ORE: 1638, ENERGY: 819, PEARL: 60})


func test_coral_citadel_at_max_level_5_returns_empty_map() -> void:
	assert_eq(_cost(CITADEL, 5), {})


func test_descent_module_level_0_to_1_coral_200_ore_150_energy_80_pearl_5() -> void:
	assert_eq(_cost(MODULE, 0), {CORAL: 200, ORE: 150, ENERGY: 80, PEARL: 5})


func test_descent_module_at_max_level_1_returns_empty_map() -> void:
	assert_eq(_cost(MODULE, 1), {})


func test_descent_module_prerequisites_hq_level_5() -> void:
	assert_eq(_calculator.prerequisites(MODULE, 1), {HQ: 5})


func test_pressure_capsule_level_0_to_1_coral_400_ore_300_energy_150_pearl_15() -> void:
	assert_eq(_cost(CAPSULE, 0), {CORAL: 400, ORE: 300, ENERGY: 150, PEARL: 15})


func test_pressure_capsule_at_max_level_1_returns_empty_map() -> void:
	assert_eq(_cost(CAPSULE, 1), {})


func test_pressure_capsule_prerequisites_hq_level_8() -> void:
	assert_eq(_calculator.prerequisites(CAPSULE, 1), {HQ: 8})


func test_volcanic_kernel_level_0_to_1_coral_50_ore_40_energy_12_pearl_8() -> void:
	assert_eq(_cost(KERNEL, 0), {CORAL: 50, ORE: 40, ENERGY: 12, PEARL: 8})


func test_volcanic_kernel_at_max_level_10_returns_empty_map() -> void:
	assert_eq(_cost(KERNEL, 10), {})


func test_volcanic_kernel_prerequisites_at_level_1_hq_10() -> void:
	assert_eq(_calculator.prerequisites(KERNEL, 1), {HQ: 10})


func test_volcanic_kernel_prerequisites_at_level_5_hq_10() -> void:
	assert_eq(_calculator.prerequisites(KERNEL, 5), {HQ: 10})


func test_check_upgrade_volcanic_kernel_kernel_not_captured_returns_can_upgrade_false() -> void:
	var result := _check_kernel(10, false)
	assert_false(result.can_upgrade)
	assert_true(result.missing_captured_kernel)


func test_check_upgrade_volcanic_kernel_kernel_captured_hq_10_resources_returns_can_upgrade_true() -> void:
	var result := _check_kernel(10, true)
	assert_true(result.can_upgrade)
	assert_false(result.missing_captured_kernel)


func test_check_upgrade_volcanic_kernel_kernel_captured_but_hq_below_10_returns_can_upgrade_false() -> void:
	var result := _check_kernel(9, true)
	assert_false(result.can_upgrade)
	assert_eq(result.missing_prerequisites, {HQ: 10})
	assert_false(result.missing_captured_kernel)


## Not in the Dart file, which leaves the base to capture to
## upgrade_readiness_test.dart.
func test_check_upgrade_names_the_base_to_capture_first() -> void:
	var rich := DomainSamples.resources({CORAL: 999, ORE: 999, ENERGY: 999, PEARL: 99})
	var base := DomainSamples.buildings({HQ: 8})
	var check := _calculator.check_upgrade(CAPSULE, 0, rich, base)
	assert_false(check.can_upgrade)
	assert_eq(check.missing_captured_base, TransitionBaseType.Value.CHEMINEE)
	var faille := _calculator.check_upgrade(CAPSULE, 0, rich, base, {TransitionBaseType.Value.FAILLE: true})
	assert_eq(faille.missing_captured_base, TransitionBaseType.Value.CHEMINEE)
	var held := _calculator.check_upgrade(CAPSULE, 0, rich, base, {TransitionBaseType.Value.CHEMINEE: true})
	assert_true(held.can_upgrade)
	assert_null(held.missing_captured_base)
