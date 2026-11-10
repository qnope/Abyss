extends TestCase
## test/domain/tech/tech_energy_reachable_test.dart: no research asks for
## more energy than a base can store.

const ENERGY := ResourceType.Value.ENERGY


func test_every_research_and_unlock_fits_in_the_energy_storage() -> void:
	var cap := Player.new("A").resources[ENERGY].max_storage
	assert_eq(cap, 2000)
	for branch: TechBranch.Value in TechBranch.Value.values():
		for level: int in range(1, TechCostCalculator.MAX_RESEARCH_LEVEL + 1):
			var cost := TechCostCalculator.research_cost(branch, level, 3)
			var energy: int = cost.get(ENERGY, 0)
			assert_true(energy <= cap, "%d level %d" % [branch, level])
		var unlock := TechCostCalculator.unlock_cost(branch, 2)
		var unlock_energy: int = unlock.get(ENERGY, 0)
		assert_true(unlock_energy <= cap)
