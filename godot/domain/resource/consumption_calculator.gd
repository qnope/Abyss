class_name ConsumptionCalculator
extends RefCounted
## lib/domain/resource/consumption_calculator.dart: the energy the buildings
## burn and the algae the units eat, each turn.

## Energy a building burns for each of its levels.
const _ENERGY_PER_LEVEL: Dictionary[BuildingType.Value, int] = {
	BuildingType.Value.HEADQUARTERS: 3,
	BuildingType.Value.ALGAE_FARM: 2,
	BuildingType.Value.CORAL_MINE: 2,
	BuildingType.Value.ORE_EXTRACTOR: 3,
	BuildingType.Value.SOLAR_PANEL: 1,
	BuildingType.Value.CORAL_CITADEL: 1,
	BuildingType.Value.LABORATORY: 4,
	BuildingType.Value.BARRACKS: 3,
	BuildingType.Value.DESCENT_MODULE: 2,
	BuildingType.Value.PRESSURE_CAPSULE: 2,
	BuildingType.Value.VOLCANIC_KERNEL: 0,
}
## Algae one unit eats.
const _ALGAE_PER_UNIT: Dictionary[UnitType.Value, int] = {
	UnitType.Value.SCOUT: 1,
	UnitType.Value.HARPOONIST: 2,
	UnitType.Value.GUARDIAN: 3,
	UnitType.Value.DOME_BREAKER: 3,
	UnitType.Value.ABYSS_ADMIRAL: 2,
	UnitType.Value.SABOTEUR: 2,
}


static func building_energy_consumption(type: BuildingType.Value, level: int) -> int:
	if level == 0:
		return 0
	return _ENERGY_PER_LEVEL[type] * level


## The energy of the built buildings, those of `excluded` (a set) apart.
static func total_building_consumption(
	buildings: Dictionary[BuildingType.Value, Building],
	excluded: Dictionary[BuildingType.Value, bool] = {},
) -> int:
	var total := 0
	for building: Building in buildings.values():
		if building.level == 0:
			continue
		if excluded.has(building.type):
			continue
		total += building_energy_consumption(building.type, building.level)
	return total


static func unit_algae_consumption(type: UnitType.Value) -> int:
	return _ALGAE_PER_UNIT[type]


static func total_unit_consumption(units: Dictionary[UnitType.Value, Unit]) -> int:
	var total := 0
	for unit: Unit in units.values():
		total += unit_algae_consumption(unit.type) * unit.count
	return total


## `units_per_level` holds a `Dictionary[UnitType.Value, Unit]` per level.
static func total_unit_consumption_all_levels(units_per_level: Dictionary[int, Dictionary]) -> int:
	var total := 0
	for level: int in units_per_level:
		var units: Dictionary[UnitType.Value, Unit] = units_per_level[level]
		total += total_unit_consumption(units)
	return total
