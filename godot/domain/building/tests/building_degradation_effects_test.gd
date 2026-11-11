extends TestCase
## test/domain/building/building_degradation_effects_test.dart: what a
## degraded building still does. 'the production bonus of the research is
## halved too' takes the buildings and the research of a Player: the same
## maps are built here.

const HQ := BuildingType.Value.HEADQUARTERS
const FARM := BuildingType.Value.ALGAE_FARM
const MINE := BuildingType.Value.CORAL_MINE
const EXTRACTOR := BuildingType.Value.ORE_EXTRACTOR
const ALGAE := ResourceType.Value.ALGAE
const CORAL := ResourceType.Value.CORAL
## Each production building and the resource it makes; at level 3 each
## needs the headquarters at 4.
const CASES: Dictionary[BuildingType.Value, ResourceType.Value] = {
	BuildingType.Value.ALGAE_FARM: ResourceType.Value.ALGAE,
	BuildingType.Value.CORAL_MINE: ResourceType.Value.CORAL,
	BuildingType.Value.ORE_EXTRACTOR: ResourceType.Value.ORE,
	BuildingType.Value.SOLAR_PANEL: ResourceType.Value.ENERGY,
}


func _made(b: Dictionary[BuildingType.Value, Building], r: ResourceType.Value) -> int:
	return ProductionCalculator.from_buildings(b).get(r, 0)


func test_production_buildings_make_half_when_degraded_each_type() -> void:
	for type: BuildingType.Value in CASES:
		var resource := CASES[type]
		var name := DartEnum.name_of(BuildingType.Value, type)
		var normal := _made(DomainSamples.base(4, {type: 3}), resource)
		var hq_income: int = ProductionCalculator.HEADQUARTERS_INCOME.get(resource, 0)
		var degraded := _made(DomainSamples.base(3, {type: 3}), resource)
		assert_true(normal - hq_income > 0, name)
		assert_eq(degraded - hq_income, DartMath.trunc_div(normal - hq_income, 2), name)


func test_production_buildings_make_half_when_degraded_raising_the_qg_restores_the_full_production() -> void:
	var b := DomainSamples.base(3, {FARM: 3})
	var low := _made(b, ALGAE)
	b[HQ].level = 4
	assert_true(_made(b, ALGAE) > low)


func test_production_buildings_make_half_when_degraded_the_flat_income_of_the_qg_is_untouched() -> void:
	var b := DomainSamples.base(1, {MINE: 3})
	var hq := ProductionCalculator.HEADQUARTERS_INCOME[CORAL]
	var full := _made(DomainSamples.base(4, {MINE: 3}), CORAL)
	assert_eq(_made(b, CORAL) - hq, DartMath.trunc_div(full - hq, 2))


func test_production_buildings_make_half_when_degraded_a_degraded_building_still_burns_its_energy() -> void:
	var b := DomainSamples.base(1, {EXTRACTOR: 3})
	assert_true(BuildingDegradation.is_degraded(b, EXTRACTOR))
	assert_eq(ConsumptionCalculator.total_building_consumption(b), 3 * 1 + 3 * 3)


func test_production_buildings_make_half_when_degraded_turn_production_sees_the_degraded_buildings() -> void:
	var of := func(hq: int) -> Dictionary[ResourceType.Value, int]:
		var farm: Dictionary[BuildingType.Value, int] = {FARM: 3}
		var player := Player.new("P", null, 0, 0, null, DomainSamples.base(hq, farm))
		return TurnProduction.of(player, 1, Difficulty.Value.NORMAL)
	var low: Dictionary[ResourceType.Value, int] = of.call(1)
	var high: Dictionary[ResourceType.Value, int] = of.call(4)
	assert_true(low[ALGAE] < high[ALGAE])


func test_degraded_laboratory_halves_the_research_effects_the_production_bonus_of_the_research_is_halved_too() -> void:
	var branches := TechHelpers.tech_branches_with([
		TechHelpers.researched_branch(TechBranch.Value.MILITARY, 3),
		TechHelpers.researched_branch(TechBranch.Value.RESOURCES, 3),
	])
	var lab: Dictionary[BuildingType.Value, int] = {BuildingType.Value.LABORATORY: 3}
	var full := ProductionCalculator.from_buildings(DomainSamples.base(5, lab), branches)[CORAL]
	var half := ProductionCalculator.from_buildings(DomainSamples.base(4, lab), branches)[CORAL]
	assert_true(half < full)
	# Not in the Dart file: the 15 of the headquarters at +75 % (two tiers and
	# Culture intensive, the option of an old save), then at +37 %.
	assert_eq([full, half], [26, 20])


func test_degraded_laboratory_halves_the_research_effects_tech_effects_of_halves_the_percentages() -> void:
	var full := TechEffects.of(_researcher(5))
	var half := TechEffects.of(_researcher(4))
	assert_true(full.atk_percent() > 0)
	assert_eq(half.atk_percent(), DartMath.trunc_div(full.atk_percent(), 2))
	assert_eq(half.def_percent(), DartMath.trunc_div(full.def_percent(), 2))
	assert_eq(
		half.production_percent(ResourceType.Value.ORE),
		DartMath.trunc_div(full.production_percent(ResourceType.Value.ORE), 2),
	)


func test_degraded_laboratory_halves_the_research_effects_raising_the_qg_restores_it() -> void:
	var p := _researcher(4)
	p.buildings[HQ].level = 5
	assert_eq(TechEffects.of(p).atk_percent(), TechEffects.of(_researcher(5)).atk_percent())


## `player(hq)` of the Dart group: military and resources researched to 3,
## the laboratory at 3 under the headquarters at `hq`.
func _researcher(hq: int) -> Player:
	var branches := TechHelpers.tech_branches_with([
		TechHelpers.researched_branch(TechBranch.Value.MILITARY, 3),
		TechHelpers.researched_branch(TechBranch.Value.RESOURCES, 3),
	])
	var lab: Dictionary[BuildingType.Value, int] = {BuildingType.Value.LABORATORY: 3}
	return Player.new("P", null, 0, 0, null, DomainSamples.base(hq, lab), branches)
