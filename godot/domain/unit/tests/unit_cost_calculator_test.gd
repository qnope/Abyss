extends TestCase
## test/domain/unit/unit_cost_calculator_test.dart: what a unit costs, the
## barracks it needs and how many a stock pays for.

const ALGAE := ResourceType.Value.ALGAE
const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const ENERGY := ResourceType.Value.ENERGY
const PEARL := ResourceType.Value.PEARL
const SCOUT := UnitType.Value.SCOUT
const GUARDIAN := UnitType.Value.GUARDIAN

var _calculator := UnitCostCalculator.new()


## The five stocks, 100 of each but the algae and the coral given.
func _resources(algae: int, coral: int) -> Dictionary[ResourceType.Value, GameResource]:
	return DomainSamples.resources({ALGAE: algae, CORAL: coral, ORE: 100, ENERGY: 100, PEARL: 100})


func test_recruitment_cost_scout_costs_algae_and_coral() -> void:
	assert_eq(_calculator.recruitment_cost(SCOUT), {ALGAE: 10, CORAL: 5})


func test_recruitment_cost_harpoonist_costs_algae_coral_ore() -> void:
	var cost := _calculator.recruitment_cost(UnitType.Value.HARPOONIST)
	assert_eq(cost, {ALGAE: 15, CORAL: 10, ORE: 5})
	assert_eq(cost.keys(), [ALGAE, CORAL, ORE], "in the order of Dart")


func test_recruitment_cost_guardian_costs_coral_and_ore() -> void:
	assert_eq(_calculator.recruitment_cost(GUARDIAN), {CORAL: 20, ORE: 15})


func test_recruitment_cost_dome_breaker_costs_ore_and_energy() -> void:
	assert_eq(_calculator.recruitment_cost(UnitType.Value.DOME_BREAKER), {ORE: 25, ENERGY: 15})


func test_recruitment_cost_abyss_admiral_costs_algae_energy_pearl() -> void:
	assert_eq(
		_calculator.recruitment_cost(UnitType.Value.ABYSS_ADMIRAL),
		{ALGAE: 20, ENERGY: 10, PEARL: 2}
	)


func test_recruitment_cost_saboteur_costs_coral_energy_pearl() -> void:
	assert_eq(
		_calculator.recruitment_cost(UnitType.Value.SABOTEUR), {CORAL: 15, ENERGY: 20, PEARL: 3}
	)


func test_unlock_level_scout_requires_barracks_1() -> void:
	assert_eq(_calculator.unlock_level(SCOUT), 1)


func test_unlock_level_harpoonist_requires_barracks_1() -> void:
	assert_eq(_calculator.unlock_level(UnitType.Value.HARPOONIST), 1)


func test_unlock_level_guardian_requires_barracks_3() -> void:
	assert_eq(_calculator.unlock_level(GUARDIAN), 3)


func test_unlock_level_dome_breaker_requires_barracks_3() -> void:
	assert_eq(_calculator.unlock_level(UnitType.Value.DOME_BREAKER), 3)


func test_unlock_level_abyss_admiral_requires_barracks_2() -> void:
	assert_eq(_calculator.unlock_level(UnitType.Value.ABYSS_ADMIRAL), 2)


func test_unlock_level_saboteur_requires_barracks_5() -> void:
	assert_eq(_calculator.unlock_level(UnitType.Value.SABOTEUR), 5)


func test_is_unlocked_scout_at_barracks_1_is_unlocked() -> void:
	assert_true(_calculator.is_unlocked(SCOUT, 1))


func test_is_unlocked_scout_at_barracks_0_is_locked() -> void:
	assert_false(_calculator.is_unlocked(SCOUT, 0))


func test_is_unlocked_guardian_at_barracks_2_is_locked() -> void:
	assert_false(_calculator.is_unlocked(GUARDIAN, 2))


func test_is_unlocked_guardian_at_barracks_3_is_unlocked() -> void:
	assert_true(_calculator.is_unlocked(GUARDIAN, 3))


func test_max_recruitable_count_scout_with_100_algae_50_coral_barracks_1() -> void:
	assert_eq(_calculator.max_recruitable_count(SCOUT, 1, _resources(100, 50)), 10)


func test_max_recruitable_count_scout_with_100_algae_50_coral_barracks_5() -> void:
	assert_eq(_calculator.max_recruitable_count(SCOUT, 5, _resources(100, 50)), 10)


func test_max_recruitable_count_scout_with_5_algae_5_coral_returns_0() -> void:
	assert_eq(_calculator.max_recruitable_count(SCOUT, 1, _resources(5, 5)), 0)


func test_max_recruitable_count_capped_by_barracks_level() -> void:
	assert_eq(_calculator.max_recruitable_count(SCOUT, 1, _resources(5000, 5000)), 100)
