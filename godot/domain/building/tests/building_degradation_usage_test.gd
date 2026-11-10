extends TestCase
## test/domain/building/building_degradation_usage_test.dart: what a
## degraded building costs its base. The tests that recruit, descend or
## garrison the kernel go with the action module.

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


func test_victory_needs_an_undegraded_noyau_10_refused_when_the_qg_fell_below_10() -> void:
	assert_null(VictoryChecker.check(_kernel_game(9)))


func test_victory_needs_an_undegraded_noyau_10_granted_with_the_qg_at_10() -> void:
	assert_eq(VictoryChecker.check(_kernel_game(10)), GameStatus.Value.VICTORY)


func test_victory_needs_an_undegraded_noyau_10_a_faction_with_a_degraded_noyau_does_not_defeat_the_human() -> void:
	var f := Player.new("F", "f", 0, 0, null, DomainSamples.base(8, {BuildingType.Value.VOLCANIC_KERNEL: 10}))
	assert_null(VictoryChecker.check(GameSamples.game([Player.new("H", "h"), f])))


func _kernel_game(hq: int) -> Game:
	var buildings := DomainSamples.base(hq, {BuildingType.Value.VOLCANIC_KERNEL: 10})
	return GameSamples.game([Player.new("H", "h", 0, 0, null, buildings)])
