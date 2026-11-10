extends TestCase
## test/domain/resource/production_calculator_test.dart: what the buildings
## of a base make each turn, and what the research adds to it.

const HQ := BuildingType.Value.HEADQUARTERS
const FARM := BuildingType.Value.ALGAE_FARM
const MINE := BuildingType.Value.CORAL_MINE
const EXTRACTOR := BuildingType.Value.ORE_EXTRACTOR
const PANEL := BuildingType.Value.SOLAR_PANEL
const ALGAE := ResourceType.Value.ALGAE
const CORAL := ResourceType.Value.CORAL
const ORE := ResourceType.Value.ORE
const ENERGY := ResourceType.Value.ENERGY


func _all_buildings_at_level(level: int) -> Dictionary[BuildingType.Value, Building]:
	var levels: Dictionary[BuildingType.Value, int] = {}
	for type: BuildingType.Value in BuildingType.Value.values():
		levels[type] = level
	return DomainSamples.buildings(levels)


func _made(levels: Dictionary[BuildingType.Value, int]) -> Dictionary[ResourceType.Value, int]:
	return ProductionCalculator.from_buildings(DomainSamples.buildings(levels))


## The algae of a farm at level 1 (90*1 - 40 = 50) under one branch of the
## research, unlocked at `level`.
func _with_branch(branch: TechBranch.Value, level: int) -> Dictionary[ResourceType.Value, int]:
	var branches: Dictionary[TechBranch.Value, TechBranchState] = {
		branch: TechBranchState.new(branch, true, level),
	}
	return ProductionCalculator.from_buildings(DomainSamples.buildings({FARM: 1}), branches)


func test_production_calculator_from_buildings_all_buildings_at_level_0_returns_empty_map() -> void:
	assert_eq(ProductionCalculator.from_buildings(_all_buildings_at_level(0)), {})


func test_production_calculator_from_buildings_algae_farm_at_level_3_produces_230_algae() -> void:
	assert_eq(_made({FARM: 3}), {ALGAE: 230})


func test_production_calculator_from_buildings_coral_mine_at_level_2_produces_100_coral() -> void:
	assert_eq(_made({MINE: 2}), {CORAL: 100})


func test_production_calculator_from_buildings_ore_extractor_at_level_1_produces_30_ore() -> void:
	assert_eq(_made({EXTRACTOR: 1}), {ORE: 30})


func test_production_calculator_from_buildings_solar_panel_at_level_4_produces_138_energy() -> void:
	assert_eq(_made({PANEL: 4}), {ENERGY: 138})


func test_production_calculator_from_buildings_multiple_buildings_cumulate_correctly() -> void:
	assert_eq(
		_made({FARM: 2, MINE: 3, EXTRACTOR: 1, PANEL: 2}),
		{ALGAE: 140, CORAL: 160, ORE: 30, ENERGY: 59}
	)


func test_production_calculator_from_buildings_a_built_headquarters_gives_the_same_flat_income_at_any_level() -> void:
	for level: int in [1, 5, 10]:
		assert_eq(_made({HQ: level}), {CORAL: 15, ORE: 10})


func test_production_calculator_from_buildings_headquarters_income_adds_to_the_buildings_production() -> void:
	assert_eq(_made({HQ: 2, MINE: 1}), {CORAL: 55, ORE: 10})


func test_production_calculator_from_buildings_pearl_is_never_in_the_result() -> void:
	var production := ProductionCalculator.from_buildings(_all_buildings_at_level(3))
	assert_false(production.has(ResourceType.Value.PEARL))


func test_with_tech_branches_no_tech_branches_null_returns_same_as_before() -> void:
	assert_eq(_made({FARM: 1}), {ALGAE: 50})


func test_with_tech_branches_resources_branch_level_1_one_tier_applies_plus_20_percent() -> void:
	# 50 * 1.2 = 60
	assert_eq(_with_branch(TechBranch.Value.RESOURCES, 1), {ALGAE: 60})


func test_with_tech_branches_level_5_with_culture_intensive_applies_plus_95_percent_on_algae() -> void:
	# 3 tiers (+60%) + Culture intensive (+35%), option A by default:
	# 50 * 1.95 = 97
	assert_eq(_with_branch(TechBranch.Value.RESOURCES, 5), {ALGAE: 97})


func test_with_tech_branches_military_branch_level_3_has_no_effect_on_production() -> void:
	assert_eq(_with_branch(TechBranch.Value.MILITARY, 3), {ALGAE: 50})


func test_with_tech_branches_unlocked_but_level_0_has_no_effect() -> void:
	assert_eq(_with_branch(TechBranch.Value.RESOURCES, 0), {ALGAE: 50})


## Not in the Dart file: the production lists the resources in the order
## the buildings first make them, then those of the headquarters' income,
## and that order is state.
func test_lists_the_resources_in_the_order_the_buildings_make_them() -> void:
	assert_eq(_made({PANEL: 1, HQ: 1, FARM: 1}).keys(), [ENERGY, ALGAE, CORAL, ORE])
	assert_eq(_made({EXTRACTOR: 1, HQ: 1}).keys(), [ORE, CORAL])
	assert_eq(ProductionCalculator.HEADQUARTERS_INCOME.keys(), [CORAL, ORE])


## Not in the Dart file: Dart applies no research to a null map; the empty
## map that stands for it here gives the same amounts, as it does in Dart.
func test_an_empty_research_changes_nothing() -> void:
	var buildings := _all_buildings_at_level(3)
	var plain := ProductionCalculator.from_buildings(buildings)
	assert_eq(ProductionCalculator.from_buildings(buildings, {}), plain)
	var locked := TechHelpers.tech_branches_with([])
	assert_eq(ProductionCalculator.from_buildings(buildings, locked), plain)
	assert_eq(ProductionCalculator.from_buildings(buildings, locked).keys(), plain.keys())
