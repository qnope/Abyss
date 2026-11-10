class_name DomainSamples
extends RefCounted
## Sample states for the tests of godot/domain: the helpers the Dart tests
## repeat in each file (`_buildings`, `_units`, `_base`, `_resources`). Each
## holds the entries given and only them, in the order given.


## Buildings at the levels given.
static func buildings(
	levels: Dictionary[BuildingType.Value, int]
) -> Dictionary[BuildingType.Value, Building]:
	var built: Dictionary[BuildingType.Value, Building] = {}
	for type: BuildingType.Value in levels:
		built[type] = Building.new(type, levels[type])
	return built


## A base: the headquarters at `hq`, then the buildings at the levels given.
static func base(
	hq: int, levels: Dictionary[BuildingType.Value, int] = {}
) -> Dictionary[BuildingType.Value, Building]:
	var built: Dictionary[BuildingType.Value, Building] = {
		BuildingType.Value.HEADQUARTERS: Building.new(BuildingType.Value.HEADQUARTERS, hq),
	}
	built.merge(buildings(levels), true)
	return built


## Units, as many of each type as given.
static func units(counts: Dictionary[UnitType.Value, int]) -> Dictionary[UnitType.Value, Unit]:
	var army: Dictionary[UnitType.Value, Unit] = {}
	for type: UnitType.Value in counts:
		army[type] = Unit.new(type, counts[type])
	return army


## Stocks holding the amounts given, each under the default storage of a
## Resource unless `max_storage` says otherwise.
static func resources(
	amounts: Dictionary[ResourceType.Value, int], max_storage := 500
) -> Dictionary[ResourceType.Value, GameResource]:
	var stocks: Dictionary[ResourceType.Value, GameResource] = {}
	for type: ResourceType.Value in amounts:
		stocks[type] = GameResource.new(type, amounts[type], max_storage)
	return stocks
