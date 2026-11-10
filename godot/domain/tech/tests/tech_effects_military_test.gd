extends TestCase
## test/domain/tech/tech_effects_military_test.dart: what the Military
## branch gives the units.

const MILITARY := TechBranch.Value.MILITARY
const A := TechOption.Value.A
const B := TechOption.Value.B


func _effects(level: int, options: Array[TechOption.Value]) -> TechEffects:
	return TechHelpers.effects_of([TechHelpers.researched_branch(MILITARY, level, options)])


func _percents(boost: UnitBoost) -> Array[int]:
	return [boost.atk_percent, boost.def_percent, boost.hp_percent]


func test_tech_effects_military_no_research_no_boost_at_all() -> void:
	var tech := TechHelpers.effects_of([])
	assert_eq(tech.perks, {})
	assert_eq(_percents(tech.unit_boost(true, true)), [0, 0, 0])


func test_tech_effects_military_each_tier_gives_plus_20_percent_atk_and_def() -> void:
	var percents: Dictionary[int, int] = {1: 20, 3: 40, 5: 60}
	for level: int in percents:
		var tech := _effects(level, [B, B])
		assert_eq(tech.tiers_of(MILITARY), DartMath.trunc_div(level, 2) + 1)
		assert_eq(tech.def_percent(), percents[level])
		assert_eq(tech.atk_percent(), percents[level])


func test_tech_effects_military_lames_de_corail_adds_plus_35_percent_atk_always() -> void:
	var tech := _effects(2, [A])
	assert_true(tech.has(TechPerk.Value.CORAL_BLADES))
	assert_eq(tech.atk_percent(), 55)
	assert_eq(tech.def_percent(), 20)


func test_tech_effects_military_carapace_de_nacre_adds_plus_35_percent_hp() -> void:
	var tech := _effects(2, [B])
	assert_eq(tech.hp_percent(), 35)
	assert_eq(tech.unit_boost().hp_percent, 35)
	assert_eq(tech.atk_percent(), 20)


func test_tech_effects_military_rempart_vivant_adds_plus_35_percent_def_only_defending_the_base() -> void:
	var tech := _effects(4, [B, A])
	assert_eq(tech.def_percent(), 40)
	assert_eq(tech.def_percent(true), 75)
	assert_eq(tech.unit_boost(false, true).def_percent, 75)
	assert_eq(tech.unit_boost(true).atk_percent, 40)


func test_tech_effects_military_assaut_des_profondeurs_adds_plus_35_percent_atk_only_attacking() -> void:
	var tech := _effects(4, [B, B])
	assert_eq(tech.atk_percent(), 40)
	assert_eq(tech.atk_percent(true), 75)
	assert_eq(tech.unit_boost(true).atk_percent, 75)
	assert_eq(tech.unit_boost(false, true).def_percent, 40)


func test_tech_effects_military_a_full_branch_stacks_tiers_and_options() -> void:
	var boost := _effects(5, [A, B]).unit_boost(true)
	assert_eq(_percents(boost), [60 + 35 + 35, 60, 0])


func test_tech_effects_military_a_locked_branch_counts_for_nothing() -> void:
	var locked := TechHelpers.researched_branch(MILITARY, 5)
	locked.unlocked = false
	var tech := TechHelpers.effects_of([locked])
	assert_eq(tech.atk_percent(true), 0)
	assert_eq(tech.perks, {})


func test_tech_effects_military_other_branches_leave_the_units_untouched() -> void:
	var tech := TechHelpers.effects_of([
		TechHelpers.researched_branch(TechBranch.Value.RESOURCES, 5),
		TechHelpers.researched_branch(TechBranch.Value.EXPLORER, 5),
	])
	assert_eq(_percents(tech.unit_boost(true, true)), [0, 0, 0])


## Not in the Dart file: the research is read once, when the effects are
## built, the perks in the order of the map then of the levels, and a
## branch the map does not hold has no tier.
func test_reads_the_research_once_in_the_order_of_the_map() -> void:
	var military := TechHelpers.researched_branch(MILITARY, 4, [B, A])
	var tech := TechHelpers.effects_of([
		TechHelpers.researched_branch(TechBranch.Value.EXPLORER, 2, [B]), military,
	])
	assert_eq(tech.perks.keys(), [
		TechPerk.Value.NACRE_SHELL, TechPerk.Value.LIVING_RAMPART, TechPerk.Value.SILENT_SWIM,
	])
	military.research_level = 5
	assert_eq(tech.tiers_of(MILITARY), 2)
	assert_false(tech.halved)
	var explorer_first: Dictionary[TechBranch.Value, TechBranchState] = {
		TechBranch.Value.EXPLORER: TechHelpers.researched_branch(TechBranch.Value.EXPLORER, 2, [B]),
		MILITARY: TechHelpers.researched_branch(MILITARY, 2, [B]),
	}
	assert_eq(
		TechEffects.new(explorer_first).perks.keys(),
		[TechPerk.Value.SILENT_SWIM, TechPerk.Value.NACRE_SHELL]
	)
	var none := TechEffects.new({}, true)
	assert_true(none.halved)
	assert_eq(none.tiers_of(MILITARY), 0)
	assert_eq(none.boost_loot({ResourceType.Value.ORE: 3}), {ResourceType.Value.ORE: 3})
