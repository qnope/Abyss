class_name PlayerDefaults
extends RefCounted
## lib/domain/game/player_defaults.dart: what a new player holds. Each call
## builds new objects, in the order Dart builds them: that order is state.


static func resources() -> Dictionary[ResourceType.Value, GameResource]:
	return {
		ResourceType.Value.ALGAE: GameResource.new(ResourceType.Value.ALGAE, 100, 5000),
		ResourceType.Value.CORAL: GameResource.new(ResourceType.Value.CORAL, 300, 5000),
		ResourceType.Value.ORE: GameResource.new(ResourceType.Value.ORE, 150, 5000),
		ResourceType.Value.ENERGY: GameResource.new(
			ResourceType.Value.ENERGY, 100, GameResource.MIN_ENERGY_STORAGE
		),
		ResourceType.Value.PEARL: GameResource.new(ResourceType.Value.PEARL, 5, 100),
	}


static func tech_branches() -> Dictionary[TechBranch.Value, TechBranchState]:
	return {
		TechBranch.Value.MILITARY: TechBranchState.new(TechBranch.Value.MILITARY),
		TechBranch.Value.RESOURCES: TechBranchState.new(TechBranch.Value.RESOURCES),
		TechBranch.Value.EXPLORER: TechBranchState.new(TechBranch.Value.EXPLORER),
	}


## Every building at level 0, in the order of BuildingType, as Dart lists
## them.
static func buildings() -> Dictionary[BuildingType.Value, Building]:
	var built: Dictionary[BuildingType.Value, Building] = {}
	for type: BuildingType.Value in [
		BuildingType.Value.HEADQUARTERS,
		BuildingType.Value.ALGAE_FARM,
		BuildingType.Value.CORAL_MINE,
		BuildingType.Value.ORE_EXTRACTOR,
		BuildingType.Value.SOLAR_PANEL,
		BuildingType.Value.LABORATORY,
		BuildingType.Value.BARRACKS,
		BuildingType.Value.CORAL_CITADEL,
		BuildingType.Value.DESCENT_MODULE,
		BuildingType.Value.PRESSURE_CAPSULE,
		BuildingType.Value.VOLCANIC_KERNEL,
	]:
		built[type] = Building.new(type, 0)
	return built


## No unit of any type on level 1; each inner map is a
## `Dictionary[UnitType.Value, Unit]`.
static func units_per_level() -> Dictionary[int, Dictionary]:
	var units: Dictionary[UnitType.Value, Unit] = {}
	for type: UnitType.Value in UnitType.Value.values():
		units[type] = Unit.new(type)
	return {1: units}
