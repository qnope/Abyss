class_name BuildingCostCalculator
extends RefCounted
## lib/domain/building/building_cost_calculator.dart: what an upgrade costs,
## how far a building goes, what it asks for first, and whether it can go
## up a level now.

const _HQ := BuildingType.Value.HEADQUARTERS
const _MAX_LEVEL: Dictionary[BuildingType.Value, int] = {
	BuildingType.Value.HEADQUARTERS: 10,
	BuildingType.Value.ALGAE_FARM: 5,
	BuildingType.Value.CORAL_MINE: 5,
	BuildingType.Value.ORE_EXTRACTOR: 5,
	BuildingType.Value.SOLAR_PANEL: 5,
	BuildingType.Value.LABORATORY: 5,
	BuildingType.Value.BARRACKS: 5,
	BuildingType.Value.CORAL_CITADEL: 5,
	BuildingType.Value.DESCENT_MODULE: 1,
	BuildingType.Value.PRESSURE_CAPSULE: 1,
	BuildingType.Value.VOLCANIC_KERNEL: 10,
}

## Discount on every upgrade, in percent (Chantiers économes).
var discount_percent: int


func _init(discount_percent_ := 0) -> void:
	discount_percent = discount_percent_


func upgrade_cost(
	type: BuildingType.Value, current_level: int
) -> Dictionary[ResourceType.Value, int]:
	var full := _full_cost(type, current_level)
	var cost: Dictionary[ResourceType.Value, int] = {}
	for resource: ResourceType.Value in full:
		cost[resource] = DartMath.trunc_div(full[resource] * (100 - discount_percent), 100)
	return cost


func max_level(type: BuildingType.Value) -> int:
	return _MAX_LEVEL[type]


func prerequisites(
	type: BuildingType.Value, target_level: int
) -> Dictionary[BuildingType.Value, int]:
	match type:
		BuildingType.Value.HEADQUARTERS: return {}
		BuildingType.Value.LABORATORY: return _hq_prereq(target_level, [2, 3, 5, 7, 10])
		BuildingType.Value.BARRACKS: return _hq_prereq(target_level, [2, 4, 6, 8, 10])
		BuildingType.Value.CORAL_CITADEL:
			return CoralCitadelCosts.coral_citadel_prereqs(target_level)
		BuildingType.Value.DESCENT_MODULE: return {_HQ: 5}
		BuildingType.Value.PRESSURE_CAPSULE: return {_HQ: 8}
		BuildingType.Value.VOLCANIC_KERNEL: return {_HQ: 10}
	# algaeFarm, coralMine, oreExtractor, solarPanel.
	return _hq_prereq(target_level, [1, 2, 4, 6, 10])


func requires_captured_kernel(type: BuildingType.Value) -> bool:
	return type == BuildingType.Value.VOLCANIC_KERNEL


## The TransitionBaseType.Value to hold before building `type`, or null.
func required_captured_base(type: BuildingType.Value) -> Variant:
	match type:
		BuildingType.Value.DESCENT_MODULE: return TransitionBaseType.Value.FAILLE
		BuildingType.Value.PRESSURE_CAPSULE: return TransitionBaseType.Value.CHEMINEE
	return null


## `captured_base_types` is a set of the kinds of posts the player holds.
func check_upgrade(
	type: BuildingType.Value,
	current_level: int,
	resources: Dictionary[ResourceType.Value, GameResource],
	all_buildings: Dictionary[BuildingType.Value, Building],
	captured_base_types: Dictionary[TransitionBaseType.Value, bool] = {},
	is_volcanic_kernel_captured := false,
) -> UpgradeCheck:
	if current_level >= max_level(type):
		return UpgradeCheck.new(false, true)

	var costs := upgrade_cost(type, current_level)
	var missing_resources: Dictionary[ResourceType.Value, int] = {}
	for resource: ResourceType.Value in costs:
		var available := GameResource.amount_in(resources, resource)
		if available < costs[resource]:
			missing_resources[resource] = costs[resource] - available

	var prereqs := prerequisites(type, current_level + 1)
	var missing_prereqs: Dictionary[BuildingType.Value, int] = {}
	for needed: BuildingType.Value in prereqs:
		if Building.level_in(all_buildings, needed) < prereqs[needed]:
			missing_prereqs[needed] = prereqs[needed]

	var req_base: Variant = required_captured_base(type)
	var missing_base: Variant = null
	if req_base != null and not captured_base_types.has(req_base):
		missing_base = req_base

	var missing_kernel := requires_captured_kernel(type) and not is_volcanic_kernel_captured

	return UpgradeCheck.new(
		missing_resources.is_empty()
		and missing_prereqs.is_empty()
		and missing_base == null
		and not missing_kernel,
		false,
		missing_resources,
		missing_prereqs,
		missing_base,
		missing_kernel,
	)


func _full_cost(
	type: BuildingType.Value, current_level: int
) -> Dictionary[ResourceType.Value, int]:
	if current_level >= max_level(type):
		return {}
	if BuildingBaseCosts.BUILDING_BASE_COSTS.has(type):
		return ExponentialCost.exponential_cost(BuildingBaseCosts.of(type), current_level)
	match type:
		BuildingType.Value.CORAL_CITADEL:
			return CoralCitadelCosts.coral_citadel_cost(current_level)
		BuildingType.Value.DESCENT_MODULE: return DescentCosts.descent_module_cost()
		BuildingType.Value.PRESSURE_CAPSULE: return DescentCosts.pressure_capsule_cost()
	# volcanicKernel, the last building without a base cost.
	return VolcanicKernelCosts.volcanic_kernel_cost(current_level)


func _hq_prereq(target_level: int, levels: Array[int]) -> Dictionary[BuildingType.Value, int]:
	var hq_level := 0
	if target_level >= 1 and target_level <= levels.size():
		hq_level = levels[target_level - 1]
	if hq_level > 0:
		return {_HQ: hq_level}
	return {}
