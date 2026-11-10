class_name TechCostCalculator
extends RefCounted
## lib/domain/tech/tech_cost_calculator.dart: what unlocking a branch and
## researching a node cost, and whether a player can do either now.

const MAX_RESEARCH_LEVEL := TechTree.MAX_LEVEL
## Extra cost of every unlock and research per branch opened beyond the
## first, in percent.
const PER_OPENED_BRANCH_PERCENT := 50
const _LABORATORY := BuildingType.Value.LABORATORY
const _RESEARCH_PEARLS: Array[int] = [0, 0, 0, 5, 10]
## What unlocking a branch costs while no other is opened.
const _UNLOCK_COST: Dictionary[TechBranch.Value, Dictionary] = {
	TechBranch.Value.MILITARY: {ResourceType.Value.ORE: 30, ResourceType.Value.ENERGY: 20},
	TechBranch.Value.RESOURCES: {ResourceType.Value.CORAL: 30, ResourceType.Value.ALGAE: 20},
	TechBranch.Value.EXPLORER: {ResourceType.Value.ENERGY: 30, ResourceType.Value.ORE: 20},
}
## The resources the research of a branch is paid in: primary, secondary.
const _RESEARCH_RESOURCES: Dictionary[TechBranch.Value, Array] = {
	TechBranch.Value.MILITARY: [ResourceType.Value.ORE, ResourceType.Value.ENERGY],
	TechBranch.Value.RESOURCES: [ResourceType.Value.CORAL, ResourceType.Value.ALGAE],
	TechBranch.Value.EXPLORER: [ResourceType.Value.ENERGY, ResourceType.Value.ORE],
}


## Branches already unlocked in `tech_branches`.
static func opened_branches(tech_branches: Dictionary[TechBranch.Value, TechBranchState]) -> int:
	var opened := 0
	for state: TechBranchState in tech_branches.values():
		if state.unlocked:
			opened += 1
	return opened


## Cost multiplier, in percent, once `opened` branches are unlocked.
static func cost_percent(opened: int) -> int:
	return 100 + PER_OPENED_BRANCH_PERCENT * maxi(0, opened - 1)


## Cost to unlock `branch` when `opened` branches already are.
static func unlock_cost(
	branch: TechBranch.Value, opened := 0
) -> Dictionary[ResourceType.Value, int]:
	return _scale(_UNLOCK_COST[branch], opened + 1)


## Cost of research `level` of `branch` with `opened` branches unlocked.
static func research_cost(
	branch: TechBranch.Value, level: int, opened := 1
) -> Dictionary[ResourceType.Value, int]:
	var paid_in: Array = _RESEARCH_RESOURCES[branch]
	var primary: ResourceType.Value = paid_in[0]
	var secondary: ResourceType.Value = paid_in[1]
	return _scale(_scaled_cost(primary, secondary, level), opened)


static func required_lab_level(research_level: int) -> int:
	return research_level


static func check_unlock(
	branch: TechBranch.Value,
	resources: Dictionary[ResourceType.Value, GameResource],
	buildings: Dictionary[BuildingType.Value, Building],
	tech_branches: Dictionary[TechBranch.Value, TechBranchState],
) -> TechCheck:
	var state: TechBranchState = tech_branches.get(branch)
	if state != null and state.unlocked:
		return TechCheck.new(false)

	var lab_level := Building.level_in(buildings, _LABORATORY)
	if lab_level < 1:
		return TechCheck.new(false, false, {}, 1, lab_level)

	var costs := unlock_cost(branch, opened_branches(tech_branches))
	var missing := _missing_resources(costs, resources)
	return TechCheck.new(missing.is_empty(), false, missing, 1, lab_level)


static func check_research(
	branch: TechBranch.Value,
	target_level: int,
	resources: Dictionary[ResourceType.Value, GameResource],
	buildings: Dictionary[BuildingType.Value, Building],
	tech_branches: Dictionary[TechBranch.Value, TechBranchState],
) -> TechCheck:
	var state: TechBranchState = tech_branches.get(branch)
	if state == null or not state.unlocked:
		return TechCheck.new(false, false, {}, 0, 0, true)
	if target_level > MAX_RESEARCH_LEVEL:
		return TechCheck.new(false, true)
	if target_level > 1 and state.research_level < target_level - 1:
		return TechCheck.new(false, false, {}, 0, 0, false, true)

	var lab_level := Building.level_in(buildings, _LABORATORY)
	var req_lab := required_lab_level(target_level)
	if lab_level < req_lab:
		return TechCheck.new(false, false, {}, req_lab, lab_level)

	var costs := research_cost(branch, target_level, opened_branches(tech_branches))
	var missing := _missing_resources(costs, resources)
	return TechCheck.new(missing.is_empty(), false, missing, req_lab, lab_level)


## Pearls are rare: only resources grow with the opened branches. A new
## map, in the order of `cost`.
static func _scale(cost: Dictionary, opened: int) -> Dictionary[ResourceType.Value, int]:
	var scaled: Dictionary[ResourceType.Value, int] = {}
	for type: ResourceType.Value in cost:
		var amount: int = cost[type]
		var is_pearl := type == ResourceType.Value.PEARL
		scaled[type] = amount if is_pearl else DartMath.trunc_div(amount * cost_percent(opened), 100)
	return scaled


static func _missing_resources(
	costs: Dictionary[ResourceType.Value, int],
	resources: Dictionary[ResourceType.Value, GameResource],
) -> Dictionary[ResourceType.Value, int]:
	var missing: Dictionary[ResourceType.Value, int] = {}
	for type: ResourceType.Value in costs:
		var available := GameResource.amount_in(resources, type)
		if available < costs[type]:
			missing[type] = costs[type] - available
	return missing


static func _scaled_cost(
	primary: ResourceType.Value, secondary: ResourceType.Value, level: int
) -> Dictionary[ResourceType.Value, int]:
	if level < 1 or level > MAX_RESEARCH_LEVEL:
		return {}
	var cost := ExponentialCost.exponential_cost({primary: 80, secondary: 50}, level - 1)
	var pearl := _RESEARCH_PEARLS[level - 1]
	if pearl > 0:
		cost[ResourceType.Value.PEARL] = pearl
	return cost
