extends TestCase
## test/domain/resource/consumption_calculator_test.dart, the algae the
## units eat.

const SCOUT := UnitType.Value.SCOUT
const HARPOONIST := UnitType.Value.HARPOONIST
const GUARDIAN := UnitType.Value.GUARDIAN


func test_unit_algae_consumption_scout_consumes_1_algae() -> void:
	assert_eq(ConsumptionCalculator.unit_algae_consumption(SCOUT), 1)


func test_unit_algae_consumption_harpoonist_consumes_2_algae() -> void:
	assert_eq(ConsumptionCalculator.unit_algae_consumption(HARPOONIST), 2)


func test_unit_algae_consumption_guardian_consumes_3_algae() -> void:
	assert_eq(ConsumptionCalculator.unit_algae_consumption(GUARDIAN), 3)


func test_unit_algae_consumption_dome_breaker_consumes_3_algae() -> void:
	assert_eq(ConsumptionCalculator.unit_algae_consumption(UnitType.Value.DOME_BREAKER), 3)


func test_unit_algae_consumption_abyss_admiral_consumes_2_algae() -> void:
	assert_eq(ConsumptionCalculator.unit_algae_consumption(UnitType.Value.ABYSS_ADMIRAL), 2)


func test_unit_algae_consumption_saboteur_consumes_2_algae() -> void:
	assert_eq(ConsumptionCalculator.unit_algae_consumption(UnitType.Value.SABOTEUR), 2)


func test_total_unit_consumption_sums_across_unit_types() -> void:
	var units := DomainSamples.units({SCOUT: 10, GUARDIAN: 5})
	assert_eq(ConsumptionCalculator.total_unit_consumption(units), 25)


func test_total_unit_consumption_zero_count_units_contribute_nothing() -> void:
	var units := DomainSamples.units({SCOUT: 0, HARPOONIST: 0})
	assert_eq(ConsumptionCalculator.total_unit_consumption(units), 0)


func test_total_unit_consumption_empty_map_returns_0() -> void:
	assert_eq(ConsumptionCalculator.total_unit_consumption({}), 0)


func test_total_unit_consumption_all_levels_sums_across_multiple_levels() -> void:
	var units_per_level: Dictionary[int, Dictionary] = {
		1: DomainSamples.units({SCOUT: 10}),
		2: DomainSamples.units({SCOUT: 5, GUARDIAN: 3}),
	}
	# Level 1: 10*1=10, Level 2: 5*1 + 3*3 = 14 => total 24
	assert_eq(ConsumptionCalculator.total_unit_consumption_all_levels(units_per_level), 24)


func test_total_unit_consumption_all_levels_single_level_same_as_total_unit_consumption() -> void:
	var units := DomainSamples.units({HARPOONIST: 5})
	var single := ConsumptionCalculator.total_unit_consumption(units)
	var multi := ConsumptionCalculator.total_unit_consumption_all_levels({1: units})
	assert_eq(multi, single)


func test_total_unit_consumption_all_levels_empty_levels_returns_0() -> void:
	assert_eq(ConsumptionCalculator.total_unit_consumption_all_levels({}), 0)
