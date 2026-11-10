extends TestCase
## test/domain/building/building_degradation_usage_test.dart: what a
## degraded building costs its base. The tests that descend or garrison
## the kernel go with DescendValidator and GarrisonKernelAction.

const CITADEL := BuildingType.Value.CORAL_CITADEL
const SCOUT := UnitType.Value.SCOUT
const ALGAE := ResourceType.Value.ALGAE


func _barracks_player(hq: int, algae: int) -> Player:
	var p := Player.new("P", "p", 0, 0, null, DomainSamples.base(hq, {BuildingType.Value.BARRACKS: 1}))
	p.resources[ALGAE].amount = algae
	p.resources[ResourceType.Value.CORAL].amount = 100
	return p


func test_degraded_barracks_doubles_the_unit_cost_cost_x2() -> void:
	var calc := UnitCostCalculator.new()
	for type: UnitType.Value in UnitType.Value.values():
		var normal := calc.recruitment_cost(type)
		var doubled := calc.recruitment_cost(type, true)
		assert_eq(doubled.keys(), normal.keys())
		for resource: ResourceType.Value in normal:
			assert_eq(doubled[resource], normal[resource] * 2)


func test_degraded_barracks_doubles_the_unit_cost_recruiting_charges_twice_and_refuses_without_the_funds() -> void:
	var p := _barracks_player(1, 25)
	var game := GameSamples.game([p])
	var action := RecruitUnitAction.new(SCOUT, 2)
	# 2 scouts = 40 algae when doubled.
	assert_eq(action.validate(game, p).reason, ActionFailure.Value.NOT_ENOUGH_RESOURCES)
	p.resources[ALGAE].amount = 40
	assert_true(action.execute(game, p).is_success)
	assert_eq(p.resources[ALGAE].amount, 0)


func test_degraded_barracks_doubles_the_unit_cost_with_the_qg_at_2_the_cost_is_normal() -> void:
	var p := _barracks_player(2, 20)
	assert_true(RecruitUnitAction.new(SCOUT, 2).execute(GameSamples.game([p]), p).is_success)
	assert_eq(p.resources[ALGAE].amount, 0)


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
