class_name CoralCitadelCosts
extends RefCounted
## lib/domain/building/coral_citadel_costs.dart: what each level of the
## Coral Citadel costs and the headquarters it asks for.

const _CITADEL_BASE_COST: Dictionary[ResourceType.Value, int] = {
	ResourceType.Value.CORAL: 250,
	ResourceType.Value.ORE: 250,
	ResourceType.Value.ENERGY: 125,
}
const _CITADEL_PEARLS: Array[int] = [5, 10, 20, 35, 60]
## Headquarters level each level of the Citadel needs, from level 1.
const _CITADEL_HQ_LEVELS: Array[int] = [3, 5, 7, 9, 10]


static func coral_citadel_cost(current_level: int) -> Dictionary[ResourceType.Value, int]:
	if current_level < 0 or current_level >= _CITADEL_PEARLS.size():
		return {}
	var cost := ExponentialCost.exponential_cost(_CITADEL_BASE_COST, current_level)
	cost[ResourceType.Value.PEARL] = _CITADEL_PEARLS[current_level]
	return cost


static func coral_citadel_prereqs(target_level: int) -> Dictionary[BuildingType.Value, int]:
	if target_level < 1 or target_level > _CITADEL_HQ_LEVELS.size():
		return {}
	return {BuildingType.Value.HEADQUARTERS: _CITADEL_HQ_LEVELS[target_level - 1]}
