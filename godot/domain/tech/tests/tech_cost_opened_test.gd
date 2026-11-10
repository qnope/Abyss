extends TestCase
## test/domain/tech/tech_cost_opened_test.dart: every branch opened beyond
## the first makes the unlocks and the research dearer.

const MILITARY := TechBranch.Value.MILITARY
const ALGAE := ResourceType.Value.ALGAE
const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const ENERGY := ResourceType.Value.ENERGY


func test_opened_branches_surcharge_counts_only_the_unlocked_branches() -> void:
	assert_eq(TechCostCalculator.opened_branches(TechHelpers.tech_branches_with([])), 0)
	var two := TechHelpers.tech_branches_with([
		TechHelpers.researched_branch(MILITARY, 0),
		TechHelpers.researched_branch(TechBranch.Value.EXPLORER, 3),
	])
	assert_eq(TechCostCalculator.opened_branches(two), 2)


func test_opened_branches_surcharge_plus_50_percent_per_branch_opened_beyond_the_first() -> void:
	assert_eq(TechCostCalculator.cost_percent(0), 100)
	assert_eq(TechCostCalculator.cost_percent(1), 100)
	assert_eq(TechCostCalculator.cost_percent(2), 150)
	assert_eq(TechCostCalculator.cost_percent(3), 200)


func test_opened_branches_surcharge_the_first_unlock_is_at_full_price_the_next_ones_cost_more() -> void:
	assert_eq(TechCostCalculator.unlock_cost(MILITARY, 0), {ORE: 30, ENERGY: 20})
	assert_eq(TechCostCalculator.unlock_cost(MILITARY, 1), {ORE: 45, ENERGY: 30})
	assert_eq(TechCostCalculator.unlock_cost(MILITARY, 2), {ORE: 60, ENERGY: 40})


func test_opened_branches_surcharge_research_scales_with_the_opened_branches() -> void:
	var b := TechBranch.Value.RESOURCES
	assert_eq(TechCostCalculator.research_cost(b, 1, 2), {CORAL: 120, ALGAE: 75})
	assert_eq(TechCostCalculator.research_cost(b, 1, 3), {CORAL: 160, ALGAE: 100})


func test_opened_branches_surcharge_pearls_are_never_scaled() -> void:
	var cost := TechCostCalculator.research_cost(TechBranch.Value.EXPLORER, 5, 3)
	assert_eq(cost, {ENERGY: 1048, ORE: 656, ResourceType.Value.PEARL: 10})
