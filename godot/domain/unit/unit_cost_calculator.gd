class_name UnitCostCalculator
extends RefCounted
## lib/domain/unit/unit_cost_calculator.dart: what a unit costs, the
## barracks it needs and how many a stock pays for.

const _BASE_COST: Dictionary[UnitType.Value, Dictionary] = {
	UnitType.Value.SCOUT: {ResourceType.Value.ALGAE: 10, ResourceType.Value.CORAL: 5},
	UnitType.Value.HARPOONIST: {
		ResourceType.Value.ALGAE: 15,
		ResourceType.Value.CORAL: 10,
		ResourceType.Value.ORE: 5,
	},
	UnitType.Value.GUARDIAN: {ResourceType.Value.CORAL: 20, ResourceType.Value.ORE: 15},
	UnitType.Value.DOME_BREAKER: {ResourceType.Value.ORE: 25, ResourceType.Value.ENERGY: 15},
	UnitType.Value.ABYSS_ADMIRAL: {
		ResourceType.Value.ALGAE: 20,
		ResourceType.Value.ENERGY: 10,
		ResourceType.Value.PEARL: 2,
	},
	UnitType.Value.SABOTEUR: {
		ResourceType.Value.CORAL: 15,
		ResourceType.Value.ENERGY: 20,
		ResourceType.Value.PEARL: 3,
	},
}
const _UNLOCK_LEVEL: Dictionary[UnitType.Value, int] = {
	UnitType.Value.SCOUT: 1,
	UnitType.Value.HARPOONIST: 1,
	UnitType.Value.GUARDIAN: 3,
	UnitType.Value.DOME_BREAKER: 3,
	UnitType.Value.ABYSS_ADMIRAL: 2,
	UnitType.Value.SABOTEUR: 5,
}


## Cost of one `type`, twice as much when the barracks are `degraded`: a
## map of its own at each call, as in Dart.
func recruitment_cost(
	type: UnitType.Value, degraded := false
) -> Dictionary[ResourceType.Value, int]:
	var base: Dictionary = _BASE_COST[type]
	var cost: Dictionary[ResourceType.Value, int] = {}
	for resource: ResourceType.Value in base:
		var amount: int = base[resource]
		cost[resource] = amount * 2 if degraded else amount
	return cost


func unlock_level(type: UnitType.Value) -> int:
	return _UNLOCK_LEVEL[type]


func is_unlocked(type: UnitType.Value, barracks_level: int) -> bool:
	return barracks_level >= unlock_level(type)


func max_recruitable_count(
	type: UnitType.Value,
	barracks_level: int,
	resources: Dictionary[ResourceType.Value, GameResource],
	degraded := false,
) -> int:
	var costs := recruitment_cost(type, degraded)
	var min_affordable := barracks_level * 100

	for resource: ResourceType.Value in costs:
		var available := GameResource.amount_in(resources, resource)
		var affordable := DartMath.trunc_div(available, costs[resource])
		min_affordable = mini(min_affordable, affordable)

	return maxi(0, min_affordable)
