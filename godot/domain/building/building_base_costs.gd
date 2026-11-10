class_name BuildingBaseCosts
extends RefCounted
## lib/domain/building/building_base_costs.dart: the cost of the first level
## of each building whose upgrades grow by ×1.6 per level (see
## ExponentialCost).

## `buildingBaseCosts`. GDScript types no map inside a map: of() gives the
## cost of a building as the typed map the rules take.
const BUILDING_BASE_COSTS: Dictionary[BuildingType.Value, Dictionary] = {
	BuildingType.Value.HEADQUARTERS: {ResourceType.Value.CORAL: 60, ResourceType.Value.ORE: 40},
	BuildingType.Value.ALGAE_FARM: {ResourceType.Value.CORAL: 80},
	BuildingType.Value.CORAL_MINE: {ResourceType.Value.ORE: 60},
	BuildingType.Value.ORE_EXTRACTOR: {
		ResourceType.Value.CORAL: 75, ResourceType.Value.ENERGY: 45,
	},
	BuildingType.Value.SOLAR_PANEL: {ResourceType.Value.CORAL: 60, ResourceType.Value.ORE: 45},
	BuildingType.Value.LABORATORY: {ResourceType.Value.CORAL: 75, ResourceType.Value.ORE: 60},
	BuildingType.Value.BARRACKS: {
		ResourceType.Value.CORAL: 60,
		ResourceType.Value.ORE: 75,
		ResourceType.Value.ENERGY: 30,
	},
}


## `buildingBaseCosts[type]` as a typed map of its own; empty where Dart
## reads null, for a building BUILDING_BASE_COSTS does not hold.
static func of(type: BuildingType.Value) -> Dictionary[ResourceType.Value, int]:
	var cost: Dictionary[ResourceType.Value, int] = {}
	var listed: Dictionary = BUILDING_BASE_COSTS.get(type, {})
	cost.assign(listed)
	return cost
