extends TestCase
## test/domain/tech/tech_energy_reachable_test.dart: no research asks for
## more energy than a base can store. The Dart test reads the storage of a
## new Player, which comes with the game module: the port reads the same
## storage from VectorInputs.STORAGE, which the startingStocks vectors will
## hold against PlayerDefaults.

const ENERGY := ResourceType.Value.ENERGY


func test_every_research_and_unlock_fits_in_the_energy_storage() -> void:
	var cap := GameResource.new(ENERGY, 0, VectorInputs.STORAGE[ENERGY]).max_storage
	assert_eq(cap, 2000)
	for branch: TechBranch.Value in TechBranch.Value.values():
		for level: int in range(1, TechCostCalculator.MAX_RESEARCH_LEVEL + 1):
			var cost := TechCostCalculator.research_cost(branch, level, 3)
			var energy: int = cost.get(ENERGY, 0)
			assert_true(energy <= cap, "%d level %d" % [branch, level])
		var unlock := TechCostCalculator.unlock_cost(branch, 2)
		var unlock_energy: int = unlock.get(ENERGY, 0)
		assert_true(unlock_energy <= cap)
