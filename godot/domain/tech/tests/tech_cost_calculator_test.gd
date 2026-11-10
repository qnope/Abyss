extends TestCase
## test/domain/tech/tech_cost_calculator_test.dart: what unlocking a branch
## and researching each of its levels cost.

const MILITARY := TechBranch.Value.MILITARY
const RESOURCES := TechBranch.Value.RESOURCES
const EXPLORER := TechBranch.Value.EXPLORER
const ALGAE := ResourceType.Value.ALGAE
const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const ENERGY := ResourceType.Value.ENERGY
const PEARL := ResourceType.Value.PEARL


func test_unlock_cost_military_costs_ore_30_and_energy_20() -> void:
	assert_eq(TechCostCalculator.unlock_cost(MILITARY), {ORE: 30, ENERGY: 20})


func test_unlock_cost_resources_costs_coral_30_and_algae_20() -> void:
	assert_eq(TechCostCalculator.unlock_cost(RESOURCES), {CORAL: 30, ALGAE: 20})


func test_unlock_cost_explorer_costs_energy_30_and_ore_20() -> void:
	assert_eq(TechCostCalculator.unlock_cost(EXPLORER), {ENERGY: 30, ORE: 20})


func test_research_cost_military_levels_1_5() -> void:
	assert_eq(TechCostCalculator.research_cost(MILITARY, 1), {ORE: 80, ENERGY: 50})
	assert_eq(TechCostCalculator.research_cost(MILITARY, 2), {ORE: 128, ENERGY: 80})
	assert_eq(TechCostCalculator.research_cost(MILITARY, 3), {ORE: 205, ENERGY: 128})
	assert_eq(TechCostCalculator.research_cost(MILITARY, 4), {ORE: 328, ENERGY: 205, PEARL: 5})
	assert_eq(TechCostCalculator.research_cost(MILITARY, 5), {ORE: 524, ENERGY: 328, PEARL: 10})


func test_research_cost_resources_levels_1_5() -> void:
	assert_eq(TechCostCalculator.research_cost(RESOURCES, 1), {CORAL: 80, ALGAE: 50})
	assert_eq(TechCostCalculator.research_cost(RESOURCES, 2), {CORAL: 128, ALGAE: 80})
	assert_eq(TechCostCalculator.research_cost(RESOURCES, 3), {CORAL: 205, ALGAE: 128})
	assert_eq(TechCostCalculator.research_cost(RESOURCES, 4), {CORAL: 328, ALGAE: 205, PEARL: 5})
	assert_eq(
		TechCostCalculator.research_cost(RESOURCES, 5), {CORAL: 524, ALGAE: 328, PEARL: 10}
	)


func test_research_cost_explorer_levels_1_5() -> void:
	assert_eq(TechCostCalculator.research_cost(EXPLORER, 1), {ENERGY: 80, ORE: 50})
	assert_eq(TechCostCalculator.research_cost(EXPLORER, 2), {ENERGY: 128, ORE: 80})
	assert_eq(TechCostCalculator.research_cost(EXPLORER, 3), {ENERGY: 205, ORE: 128})
	assert_eq(TechCostCalculator.research_cost(EXPLORER, 4), {ENERGY: 328, ORE: 205, PEARL: 5})
	assert_eq(TechCostCalculator.research_cost(EXPLORER, 5), {ENERGY: 524, ORE: 328, PEARL: 10})


func test_research_cost_pearl_is_included_only_at_levels_4_and_5() -> void:
	for branch: TechBranch.Value in TechBranch.Value.values():
		for level: int in range(1, 6):
			var cost := TechCostCalculator.research_cost(branch, level)
			assert_eq(cost.has(PEARL), level >= 4, "%d level %d" % [branch, level])


func test_required_lab_level_levels_1_5_return_the_same_value() -> void:
	for level: int in range(1, 6):
		assert_eq(TechCostCalculator.required_lab_level(level), level)


## Not in the Dart file: a cost lists the primary resource of the branch,
## the secondary one, then the pearls, and that order is state.
func test_a_cost_lists_its_resources_in_the_order_of_dart() -> void:
	assert_eq(TechCostCalculator.unlock_cost(MILITARY).keys(), [ORE, ENERGY])
	assert_eq(TechCostCalculator.unlock_cost(RESOURCES).keys(), [CORAL, ALGAE])
	assert_eq(TechCostCalculator.unlock_cost(EXPLORER).keys(), [ENERGY, ORE])
	assert_eq(TechCostCalculator.research_cost(MILITARY, 5).keys(), [ORE, ENERGY, PEARL])
	assert_eq(TechCostCalculator.research_cost(RESOURCES, 4).keys(), [CORAL, ALGAE, PEARL])
	assert_eq(TechCostCalculator.research_cost(EXPLORER, 1).keys(), [ENERGY, ORE])


## Not in the Dart file: a cost handed out can be changed without changing
## the next one.
func test_two_costs_share_no_map() -> void:
	TechCostCalculator.unlock_cost(MILITARY)[ORE] = 1
	assert_eq(TechCostCalculator.unlock_cost(MILITARY), {ORE: 30, ENERGY: 20})
	assert_eq(TechCostCalculator.MAX_RESEARCH_LEVEL, 5)
	assert_eq(TechCostCalculator.research_cost(MILITARY, 0), {})
	assert_eq(TechCostCalculator.research_cost(MILITARY, 6), {})
