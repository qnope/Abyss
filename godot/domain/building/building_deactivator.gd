class_name BuildingDeactivator
extends RefCounted
## lib/domain/building/building_deactivator.dart: the buildings shut down
## when the energy runs short.

## Priority order: buildings later in this list are disabled first.
## HQ is never disabled (index 0, never reached).
const _PRIORITY: Array[BuildingType.Value] = [
	BuildingType.Value.HEADQUARTERS,  # 0 - never disabled
	BuildingType.Value.VOLCANIC_KERNEL,  # 1 - second to last disabled
	BuildingType.Value.CORAL_CITADEL,  # 2
	BuildingType.Value.SOLAR_PANEL,  # 3
	BuildingType.Value.DESCENT_MODULE,  # 4
	BuildingType.Value.PRESSURE_CAPSULE,  # 5
	BuildingType.Value.BARRACKS,  # 6
	BuildingType.Value.LABORATORY,  # 7
	BuildingType.Value.ALGAE_FARM,  # 8
	BuildingType.Value.CORAL_MINE,  # 9
	BuildingType.Value.ORE_EXTRACTOR,  # 10 - disabled first
]


## Returns list of buildings that must be deactivated.
static func deactivate(
	buildings: Dictionary[BuildingType.Value, Building],
	energy_production: int,
	energy_stock: int,
) -> Array[BuildingType.Value]:
	var consumption := ConsumptionCalculator.total_building_consumption(buildings)
	var available := energy_production + energy_stock
	var deactivated: Array[BuildingType.Value] = []

	if consumption <= available:
		return deactivated

	for i: int in range(_PRIORITY.size() - 1, 0, -1):
		if consumption <= available:
			break

		var type := _PRIORITY[i]
		var building: Building = buildings.get(type)
		if building == null or building.level == 0:
			continue

		deactivated.append(type)
		consumption -= ConsumptionCalculator.building_energy_consumption(type, building.level)

	return deactivated
