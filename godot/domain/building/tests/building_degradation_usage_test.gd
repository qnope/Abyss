extends TestCase
## test/domain/building/building_degradation_usage_test.dart: what a
## degraded building costs its base. The tests that recruit, descend,
## garrison the kernel or check the victory go with the action and game
## modules.

const CITADEL := BuildingType.Value.CORAL_CITADEL


func test_degraded_barracks_doubles_the_unit_cost_cost_x2() -> void:
	var calc := UnitCostCalculator.new()
	for type: UnitType.Value in UnitType.Value.values():
		var normal := calc.recruitment_cost(type)
		var doubled := calc.recruitment_cost(type, true)
		assert_eq(doubled.keys(), normal.keys())
		for resource: ResourceType.Value in normal:
			assert_eq(doubled[resource], normal[resource] * 2)


func test_degraded_citadel_halves_the_rampart_combatant() -> void:
	var normal := CoralCitadelRampart.combatant_for(3)
	var half := CoralCitadelRampart.combatant_for(3, true)
	assert_eq(half.max_hp, DartMath.trunc_div(normal.max_hp, 2))
	assert_eq(half.def, DartMath.trunc_div(normal.def, 2))
	assert_null(CoralCitadelRampart.combatant_for(0, true))


func test_degraded_citadel_halves_the_rampart_of_the_buildings_of_a_base() -> void:
	var ok := DomainSamples.base(7, {CITADEL: 3})
	var low := DomainSamples.base(6, {CITADEL: 3})
	assert_eq(CoralCitadelRampart.combatant_of(ok).max_hp, 120)
	assert_eq(CoralCitadelRampart.combatant_of(low).max_hp, 60)
	assert_null(CoralCitadelRampart.combatant_of(DomainSamples.base(7)))
