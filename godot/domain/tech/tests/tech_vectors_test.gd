extends VectorTestCase
## reference/vectors/tech.json: what the research costs, the state of a
## branch and what the research changes in the rules, as Dart answers.

const NOISES: Array[int] = [0, 1, 3, 7]
const LOOT: Dictionary[ResourceType.Value, int] = {
	ResourceType.Value.ALGAE: 333, ResourceType.Value.CORAL: 1, ResourceType.Value.PEARL: 3,
}

var _vectors := VectorFile.new("tech")


func _branch(case: Dictionary) -> TechBranch.Value:
	return VectorInputs.value(TechBranch.Value, case["branch"]) as TechBranch.Value


func test_unlock_cost() -> void:
	var cases := _vectors.cases("unlockCost")
	assert_eq(cases.size(), 12)
	for case: Dictionary in cases:
		var opened: int = case["opened"]
		assert_same(TechCostCalculator.cost_percent(opened), case["percent"], str(case))
		var cost := TechCostCalculator.unlock_cost(_branch(case), opened)
		assert_same(VectorInputs.named(ResourceType.Value, cost), case["out"], str(case))


func test_research_cost() -> void:
	var cases := _vectors.cases("researchCost")
	assert_eq(cases.size(), 84)
	for case: Dictionary in cases:
		var level: int = case["level"]
		var opened: int = case["opened"]
		var cost := TechCostCalculator.research_cost(_branch(case), level, opened)
		assert_same(VectorInputs.named(ResourceType.Value, cost), case["out"], str(case))


func test_branch_state() -> void:
	var cases := _vectors.cases("branchState")
	assert_eq(cases.size(), 84)
	for case: Dictionary in cases:
		var unlocked: bool = case["unlocked"]
		var level: int = case["level"]
		var taken: Array = case["choices"]
		var choices: Array[int] = []
		choices.assign(taken)
		var state := TechBranchState.new(_branch(case), unlocked, level, choices)
		var options := []
		for node: int in range(1, TechTree.MAX_LEVEL + 1):
			options.append(VectorInputs.name_or_null(TechOption.Value, state.option_at(node)))
		var out := {
			"options": options,
			"perks": VectorInputs.names(TechPerk.Value, state.perks().keys()),
			"tiers": state.tiers(),
		}
		assert_same(out, case["out"], str(case))


## The keys of `out` are the getters reference/vectors/README.md lists.
func test_effects() -> void:
	var cases := _vectors.cases("effects")
	assert_eq(cases.size(), 92)
	for case: Dictionary in cases:
		var halved: bool = case["halved"]
		var effects := TechEffects.new(VectorInputs.tech(case["tech"]), halved)
		var production: Dictionary[ResourceType.Value, int] = {}
		for type: ResourceType.Value in ResourceType.Value.values():
			production[type] = effects.production_percent(type)
		var out := {
			"atk": effects.atk_percent(),
			"atkAttacking": effects.atk_percent(true),
			"boostLoot": VectorInputs.named(ResourceType.Value, effects.boost_loot(LOOT)),
			"def": effects.def_percent(),
			"defBase": effects.def_percent(true),
			"hp": effects.hp_percent(),
			"lootPercent": effects.loot_percent(),
			"muffle": NOISES.map(effects.muffle),
			"pillageRate": effects.pillage_rate(),
			"production": VectorInputs.named(ResourceType.Value, production),
			"raidWarningTurns": effects.raid_warning_turns(),
			"revealSide": effects.reveal_side(),
			"upgradeDiscount": effects.upgrade_discount_percent(),
		}
		assert_same(out, case["out"], str(case))
		var boost := effects.unit_boost(true, true)
		var percents := [boost.atk_percent, boost.def_percent, boost.hp_percent]
		assert_eq(percents, [out["atkAttacking"], out["defBase"], out["hp"]], str(case))
