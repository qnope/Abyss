extends TestCase
## test/domain/building/volcanic_kernel_costs_test.dart: what each level of
## the volcanic kernel costs.

const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const ENERGY := ResourceType.Value.ENERGY
const PEARL := ResourceType.Value.PEARL


func test_volcanic_kernel_cost_level_0_coral_50_ore_40_energy_12_pearl_8() -> void:
	var cost := VolcanicKernelCosts.volcanic_kernel_cost(0)
	assert_eq(cost, {CORAL: 50, ORE: 40, ENERGY: 12, PEARL: 8})
	assert_eq(cost.keys(), [CORAL, ORE, ENERGY, PEARL])


func test_volcanic_kernel_cost_level_9_coral_4100_ore_3280_energy_984_pearl_35() -> void:
	var cost := VolcanicKernelCosts.volcanic_kernel_cost(9)
	assert_eq(cost, {CORAL: 4100, ORE: 3280, ENERGY: 984, PEARL: 35})


func test_volcanic_kernel_cost_all_costs_from_level_0_9_are_within_storage_caps() -> void:
	var caps := {CORAL: 5000, ORE: 5000, ENERGY: 1000, PEARL: 100}
	for level: int in 10:
		var cost := VolcanicKernelCosts.volcanic_kernel_cost(level)
		for type: ResourceType.Value in cost:
			var cap: int = caps[type]
			assert_true(
				cost[type] <= cap,
				"%s cost at level %d is %d, cap is %d"
				% [DartEnum.name_of(ResourceType.Value, type), level, cost[type], cap]
			)
